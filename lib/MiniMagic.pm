###############################################################################
#
# MiniMagic.pm: module to download MIME types from the official libmagic repository,
# list the available MIME types and filter the tests in the MIME type definitions
# depending on a list of MIME types.
#
# Copyright (c) 2021 Open Systems AG, Switzerland
# All Rights Reserved.
#
# This module implements utilities to download and list all MIME types available
# at https://github.com/file/file/tree/FILE5_39/magic/Magdir. It also allows to
# filter the tests in the MIME type definitions depending on a list of MIME types
#
###############################################################################

package MiniMagic;

use v5.28;
use warnings;

use Log::Any qw($log);
use Const::Fast;
use File::Path;
use LWP::Simple qw(get);
use IPC::Run qw(run);
use File::Slurper qw(write_binary);
use Archive::Extract;
use File::Copy::Recursive qw(dircopy);

# URL of the MIME type definitions for libmagic
const my $FILE_REPO_URL => 'http://ftp.astron.com/pub/file/';

# https://tools.ietf.org/html/rfc6838#section-4.2
const my $MIME_TYPE_REGEX => qr"\w[-!#\$&^+.\w]{0,126}\/\w[-!#\$&^+.\w]{0,126}";

# download_magic_files downloads the MIME type definitions from the file repository
# where the arguments of the function are:
# - $src_dir: the location of the directory where the MIME type definitions are located
# - $version: the libmagic version corresponding to the MIME type definitions
sub download_magic_files {

    my ( $src_dir, $version ) = @_;

    if ( -d $src_dir ) {
        rmtree($src_dir)
          or die "Could not remove MIME type source directory $src_dir: $!";
    }

    my $file_dir = "file-$version";
    my $tar_file = "$file_dir.tar.gz";

    my $url = $FILE_REPO_URL . $tar_file;
    $log->debug("going to download $url");
    write_binary($tar_file, get($url));
    $log->debug("file from $url saved at $tar_file");

    # Extract Magdir to source
    $log->debug("extract $file_dir/magic/Magdir to $src_dir");
    my $ae = Archive::Extract->new(archive => $tar_file);
    $ae->extract() or die "Could not extract $file_dir: $!";
    dircopy("$file_dir/magic/Magdir/", $src_dir) or die "Could not copy $file_dir/magic/Magdir/ to $src_dir: $!";

    # clean downloaded files
    rmtree($file_dir) or die "Could not remove downloaded $file_dir directory: $!";
    unlink($tar_file) or die "Could not remove downloaded $tar_file file: $!";

    return;
}


#list_mime_types creates a list of all MIME types available
# The arguments of the function are:
# - $src_dir: the path of the directory where the MIME type definitions are located
# It returns a reference to a list (with no duplicates) containing the MIME types
sub list_mime_types {
    my ($src_dir) = @_;

    # Create set of MIME types to avoid duplicates
    my %mime_types;

    my @files = glob("$src_dir/*");
    for my $file (@files) {
        open( my $fh, '<', $file ) or die $!;

        # for each line, check if the line starts with !:mime and extract the MIME type
        while ( my $line = readline($fh) ) {
            if ( $line =~ /^!:mime/ ) {
                if ($line =~ /($MIME_TYPE_REGEX)/) {
                    $mime_types{$1} = 1;
                }
            }
        }

        close($fh);
    }

    my @mime_list = keys %mime_types;
    return \@mime_list;
}

#print_list_mime_types prints a list of all MIME types that are in the directory containing all the MIME type definitions
# where the arguments of the function are:
# - $src_dir: the location of the directory where the MIME type definitions are located
sub print_list_mime_types {

    my ($src_dir) = @_;

    if ( !-d $src_dir ) {
        die "$src_dir was not found, impossible to list the MIME types contained in it";
    }

    # Create set of MIME types to avoid duplicates
    my $mime_types = list_mime_types($src_dir);

    my $size = @$mime_types;
    $log->debug("$size MIME type definitions found at $src_dir");

    for ( sort @$mime_types ) {
        say $_;
    }

    return;
}

# create_mini_magic_file creates a magic file containing all tests needed to detect all the desired MIME types
# where the arguments of the function are:
# - $mime_array: the reference of the array containing the desired MIME types
# - $src_dir: the location of the directory where the MIME type definitions are located
# - $magic_file: the name of the created (minimal) magic file
sub create_mini_magic_file {

    my ( $mime_array, $src_dir, $magic_filename ) = @_;

    # Check if the directory with the MIME type definitions exists
    if ( !-d $src_dir ){
        die "$src_dir was not found, impossible to list the MIME types contained in it" ;
    }

    # Remove existing magic file
    if ( -e $magic_filename ) {
        unlink $magic_filename or die "impossible to remove $magic_filename: $!";
    }

    # parsing magic files from $src_dir
    my $tests = _parse_mime_files($src_dir);

    # removing all tests that are not necessary to detect MIME types in $mime_array
    my $tests_to_save = _filter_tests($tests, $mime_array);

    # create new magic file with the necessary tests
    _save_magic_file($tests_to_save, $magic_filename);

    return;

}

# _parse_mime_files is an helper function that parses the files containing the MIME type definition.
# The arguments of the function are:
# - $src_dir: the path of the directory where the MIME type definitions are located
# It returns an array containing the structures created for the parsed tests (more details below)
sub _parse_mime_files {

    my $src_dir = shift;

    # Array containing all (references of the hash of) the tests that were not filtered out
    my @tests;

    $log->debug("parsing files from $src_dir");
    for my $file (glob("$src_dir/*")) {
        my $read_handler;
        open( $read_handler, '<', $file ) or die $!;

        # Create new test hash reference
        my $current_test = {
            body                => '',  # Contains the test (text)
            mimes               => [],  # The MIME types of the test
            name                => [],  # Name(s) of the test.
                                        # A test might contain more than one type "name" (see x8192 in pgp)
            use                 => [],  # The names of the tests that $current_test calls
            saved               => 0,   # Indicates if the test was already saved to the magic file.
            has_desired_mime    => 0,   # Indicates if the test has one of the desired MIME types.
        };

        while ( my $line = readline($read_handler) ) {

            # Skip comments and blank lines
            next if ( $line =~ /^#|^\s+#/ || $line =~ /^\n|\r/ );

            my @split_line = split /\s+/, $line;

            # End of a test
            if ( $line =~ /^\d/ && $current_test->{'body'} ) {
                push @tests, $current_test;

                # Reset state
                $current_test = {
                    body                => '',
                    mimes               => [],
                    name                => [],
                    use                 => [],
                    saved               => 0,
                    has_desired_mime    => 0,
                };

            }

            # Type of the line is use, i.e., the test calls another test
            # Example: >0	use		pdf
            if ( $split_line[1] && $split_line[2] && $split_line[1] eq 'use' ) {

                my $test_name = $split_line[2];

                # remove endianness
                $test_name =~ s/^\^//;   # This follows the documentation to switch endianness
                $test_name =~ s/^\\\^//; # In practice it seems to follow this format to switch endianness

                push @{ $current_test->{'use'} }, $test_name;

            }

            # Type of the line is name, i.e., the test can be called by another test
            # Example: 0	name	pdf
            if ( $split_line[1] && $split_line[2] && $split_line[1] eq 'name' ) {
                push @{ $current_test->{'name'} }, $split_line[2];
            }

            # Indicates mime type covered by the test
            # Example: !:mime	application/pdf
            if ( $line =~ /^!:mime/ ) {
                if($line =~ /($MIME_TYPE_REGEX)/){
                    push @{ $current_test->{'mimes'} }, $1;
                }
            }

            $current_test->{'body'} .= $line;
        }

        push @tests, $current_test;
        close($read_handler);
    }
    my $nbr_tests = @tests;
    $log->debug("$nbr_tests tests were found in $src_dir");

    return \@tests;
}

# _filter_tests removes all the unnecessay tests to detect the desired MIME types.
# It works in 2 traversals:
# 1) Go through the parsed tests and only keep the tests that either have one of the desired MIME types, call or are called by another test
# 2) Traverse the trees formed by the tests calling each other and keep the whole tree if at least one test must be saved.
# It takes as arguments:
# $tests: an array containing the structures of the parsed tests
# $mime_array: an array containing the desired MIME types
# It returns an array containing the bodies of the tests that we want to save
sub _filter_tests {
    my ($tests, $mime_array) = @_;
    
    # Maps the name of a named test to its hash structure (same reference as in the array @tests)
    my %named_tests;

    # Create set of MIME types used for filtering
    # The value of the hash is only for debugging
    # 0 means that no test was found among $tests for this MIME type
    my %mime_types;
    for my $mime (@$mime_array) {
        $mime_types{$mime} = 0;
    }

    # decides wether or not we must keep a test
    # only keep a test if it has a desired MIME type, it calls another test or it is called by another test
    # if a test is called by another test we add it to %named_tests
    my @filtered_tests;
    for my $test (@$tests){
        
        # check if the test has one of the desired MIME type
        for my $mime (@{$test->{'mimes'}}){
            if(exists( $mime_types{$mime})){
                $test->{'has_desired_mime'} = 1;
                $mime_types{$mime} = 1;
            }
        }

        if ( $test->{'has_desired_mime'}|| @{ $test->{'name'} } || @{ $test->{'use'} } ) {
            push @filtered_tests, $test;
            
            if ( @{ $test->{'name'} } ) {
                for my $name ( @{ $test->{'name'} } ) {
                    $named_tests{$name} = $test;
                }
            }
        }   
    }

    my $nbr_filtered_tests = @filtered_tests;
    $log->debug("$nbr_filtered_tests remaining tests after first filtering");
    for my $mime ( keys %mime_types ) {
        if ( !$mime_types{$mime} ) {
            $log->debug( "No test for $mime was found" );
        }
    }

    # traverse tests trees and decide if the tests in a tree must be saved or not
    my @tests_to_save;
    for my $test (@filtered_tests){
        # Test only contains a listed MIME type and neither calls or is called by another test
        if ( $test->{'has_desired_mime'} && !$test->{'saved'} && !@{ $test->{'use'} } && !@{ $test->{'name'} } ) {
            push @tests_to_save, $test->{'body'};
            $test->{'saved'} = 1;
        }

        # Test is the root of the tree test.
        # This means that this test calls at least another test (that might call another test etc).
        # We need to check wether or not one (or more) test(s) in the tree starting at the root must be saved, and if it is the case all tests in the tree are saved.
        if ( @{ $test->{'use'} } && !@{ $test->{'name'} } ) {
            my ( $save, $discovered ) = _traverse_tests_tree( $test, \%named_tests );

            if ($save) {

                for my $name ( sort keys %$discovered ) {
                    my $called_test = $named_tests{$name};

                    if ( !$called_test->{'saved'} ) {
                        push @tests_to_save, $called_test->{'body'};
                        $called_test->{'saved'} = 1;
                    }
                }

                if ( !$test->{'saved'} ) {
                    push @tests_to_save, $test->{'body'};
                    $test->{'saved'} = 1;
                }
            }
        }
    }

    my $nbr_tests = @tests_to_save;
    $log->debug("$nbr_tests tests must be saved");

    return \@tests_to_save;
}

# _traverse_tests_tree applies BFS on the graph of interconnected tests (test that call each other) and decide if all the tests in the graph
# must be saved to the magic file or not.
# The arguments of the function are:
# - $root: the reference to the test that only calls other tests (has at least one use type and no name type). It is the root of the BFS algorithm.
# - $named_tests: the reference to the hash that maps a name to the test structure that have a name type
# It returns a tuple with:
# - boolean value that indicates wether or not to save the tests
# - all the tests visited by BFS
sub _traverse_tests_tree {
    my ( $root, $named_tests ) = @_;

    my $save = 0;

    if ( $root->{'has_desired_mime'} ) {
        $save = 1;
    }

    my @queue;
    my %discovered;

    for my $sub_name ( @{ $root->{'use'} } ) {
        if ( !defined( $discovered{$sub_name} ) ) {
            $discovered{$sub_name} = 1;
            push @queue, $sub_name;
        }
    }

    # BFS loop. It traverses the graph formed by the tests. Each test is traversed once (and only once).
    while (@queue) {
        my $name        = shift @queue;
        my $called_test = $named_tests->{$name};

        # Check if we need to save all tests in the graph
        if ( $called_test->{'has_desired_mime'} ) {
            $save = 1;
        }

        # Enqueue all children tests that were not traversed yet.
        for my $sub_name ( @{ $called_test->{'use'} } ) {
            if ( !defined( $discovered{$sub_name} ) ) {
                $discovered{$sub_name} = 1;
                push @queue, $sub_name;
            }
        }
    }

    return ( $save, \%discovered );

}

# _save_magic_file saves the tests to a file
# It takes as argument:
# $test_to_save: an array containing the bodies of the tests that we want to save
# $magic_filename: the path to the magic_filename where we want to save the tests
sub _save_magic_file {
    my ($tests_to_save, $magic_filename) = @_;
    $log->debug("writing tests to $magic_filename");

    open(my $fh, '>>', $magic_filename) or die "could not open $magic_filename to save the tests: $!";
    for my $test_body (@$tests_to_save){
        print $fh $test_body . "\n";
    }
    close($fh);
    return;
}

1;
