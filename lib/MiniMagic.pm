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
                $line =~ /($MIME_TYPE_REGEX)/;
                $mime_types{$1} = 1 if($1);
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

    my ( $mime_array, $src_dir, $magic_file ) = @_;

    # Check if the directory with the MIME type definitions exists
    if ( !-d $src_dir ){
        die "$src_dir was not found, impossible to list the MIME types contained in it" ;
    }

    # Remove existing magic file
    if ( -e $magic_file ) {
        unlink $magic_file or die "impossible to remove $magic_file: $!";
    }

    # Create set of MIME types used for filtering
    my %mime_types = ();
    for my $mime (@$mime_array) {
        $mime_types{$mime} = 0;
    }

    # Array containing all (references of the hash of) the tests that were not filtered out
    my @tests;

    # Maps the name of a named test to its hash structure (same reference as in the array @tests)
    my %named_tests;

    my $total_nbr_tests = _parse_mime_files( \@tests, \%named_tests, \%mime_types, $src_dir );

    my $nbr_tests       = @tests;
    my $nbr_named_tests = keys %named_tests;
    $log->debug( "$nbr_tests tests remaining after first traversal where $nbr_named_tests have type name" );

    for my $mime ( keys %mime_types ) {
        if ( !$mime_types{$mime} ) {
            $log->debug( "No test for " . $mime . " was found" );
        }
    }

    my $nbr_saved_tests = _save_tests( \@tests, \%named_tests, $magic_file );
    $log->info( "$nbr_saved_tests/$total_nbr_tests tests were save to $magic_file" );

    return $nbr_saved_tests;
}

# _save_tests saves the test to the magic file.
# The arguments of the function are:
# - $tests: the reference to the array containing all tests that are still relevant
# - $named_tests: (the reference of) the hash mapping a name of a test to its reference
# - $magic_file: the path where to save the magic file
# It returns:
# - the number of saved tests
sub _save_tests {
    my ( $tests, $named_tests, $magic_file ) = @_;
    my $saved_tests = 0;

    my $write_handler;
    open( $write_handler, ">>", $magic_file ) or die $!;
    for my $test (@$tests) {

        # Test only contains a listed MIME type and neither calls or is called by another test
        if ( $test->{"mime"} && !$test->{"saved"} && !@{ $test->{"use"} } && !@{ $test->{"name"} } ) {
            print $write_handler $test->{"body"} . "\n";
            $test->{"saved"} = 1;
            $saved_tests++;
        }

        # Test is the root of the tree test.
        # This means that this test calls at least another test (that might call another test etc).
        # We need to check wether or not one (or more) test(s) in the tree starting at the root must be saved, and if it is the case all tests in the tree are saved.
        if ( @{ $test->{"use"} } && !@{ $test->{"name"} } ) {
            my ( $save, $discovered ) = _traverse_tests_tree( $test, $named_tests );

            if ($save) {

                for my $name ( keys %$discovered ) {
                    my $called_test = $named_tests->{$name};

                    if ( !$called_test->{"saved"} ) {
                        print $write_handler $called_test->{"body"} . "\n";
                        $called_test->{"saved"} = 1;
                        $saved_tests++;
                    }
                }

                if ( !$test->{"saved"} ) {
                    print $write_handler $test->{"body"} . "\n";
                    $test->{"saved"} = 1;
                    $saved_tests++;
                }
            }
        }
    }
    close($write_handler);

    return $saved_tests;

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

    if ( $root->{"mime"} ) {
        $save = 1;
    }

    my @queue;
    my %discovered;

    for my $sub_name ( @{ $root->{"use"} } ) {
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
        if ( $called_test->{"mime"} ) {
            $save = 1;
        }

        # Enqueue all children tests that were not traversed yet.
        for my $sub_name ( @{ $called_test->{"use"} } ) {
            if ( !defined( $discovered{$sub_name} ) ) {
                $discovered{$sub_name} = 1;
                push @queue, $sub_name;
            }
        }
    }

    return ( $save, \%discovered );

}

# _filter_test decides wether a test is kept or not.
# If a test is not filtered, it is added to the relevant structure.
# The arguments are:
# - $current_test: the test for which the decision is done.
# - $tests: the reference to the array containing all tests that are still relevant
# - $named_tests: (the reference of) the hash mapping a name of a test to its reference
sub _filter_test {

    my ( $current_test, $named_tests, $tests ) = @_;

    # Only keep a test if it has a desired MIME type, it calls another test or it is called by another test
    if ( $current_test->{"mime"} || @{ $current_test->{"name"} } || @{ $current_test->{"use"} } ) {
        push @$tests, $current_test;
        if ( @{ $current_test->{"name"} } ) {
            for my $name ( @{ $current_test->{"name"} } ) {
                $named_tests->{$name} = $current_test;
            }
        }
    }
}

# _parse_mime_files is an helper function that parses the files containing the MIME type definition.
# It removes the tests that can be already identified as useless for the listed MIME types.
# It only keeps tests that:
# - call other tests (has type "use")
# - are called by other tests (has type "name")
# - have a listed MIME type
# The arguments of the function are:
# - $tests: the reference to the array containing all tests that are still relevant
# - $named_tests: (the reference of) the hash mapping a name of a test to its reference (more details about the structure in the function)
# - $mime_types: the reference to the set of desired MIME types
# - $src_dir: the path of the directory where the MIME type definitions are located
# It returns the total number of tests
sub _parse_mime_files {

    my ( $tests, $named_tests, $mime_types, $src_dir ) = @_;
    my $total_nbr_tests = 0;

    $log->debug("parsing files at $src_dir");
    for my $file (glob("$src_dir/*")) {
        my $read_handler;
        open( $read_handler, "<", $file ) or die $!;

        # Create new test hash reference
        my $current_test = {
            "body"  => "",  # Contains the test (text)
            "mime"  => "",  # The MIME type of the test (only if it is one of the listed ones)
            "name"  => [],  # Name(s) of the test.
                            # A test might contain more than one type "name" (see x8192 in pgp)
            "use"   => [],  # The names of the tests that $current_test calls
            "saved" =>0,    # Indicates if the test was already saved to the magic file.
        };

        while ( my $line = readline($read_handler) ) {

            # Skip comments and blank lines
            if ( !( $line =~ /^#|^\s+#/ || $line =~ /^\n|\r/ ) ) {
                my @split_line = split /\s+/, $line;

                # End of a test
                if ( $line =~ /^\d/ && $current_test->{"body"} ) {
                    $total_nbr_tests++;

                    _filter_test( $current_test, $named_tests, $tests );

                    # Reset state
                    $current_test = {
                        "body"  => "",
                        "mime"  => "",
                        "name"  => [],
                        "use"   => [],
                        "saved" => 0,
                    };

                }

                # Type of the line is use, i.e., the test calls another test
                # Ex: >0	use		pdf
                if ( $split_line[1] && $split_line[2] && $split_line[1] eq "use" ) {
                    #This follows the documentation to switch endianness
                    if ( $split_line[2] && $split_line[2] =~ /^\^/ ) {
                        push @{ $current_test->{"use"} },
                          substr( $split_line[2], 1 );
                    #In practice it seems to follow this format to switch endianness
                    }
                    elsif ( $split_line[2] && $split_line[2] =~ /^\\\^/ ) {
                        push @{ $current_test->{"use"} },
                          substr( $split_line[2], 2 );
                    }
                    else {
                        push @{ $current_test->{"use"} }, $split_line[2];
                    }

                }

                # Type of the line is name, i.e., the test can be called by another test
                # Ex: 0	name	pdf
                if ( $split_line[1] && $split_line[2] && $split_line[1] eq "name" ) {
                    push @{ $current_test->{"name"} }, $split_line[2];
                }

                # Indicates mime type covered by the test
                # Ex: !:mime	application/pdf
                if ( $line =~ /^!:mime/ ) {
                    $line =~ /($MIME_TYPE_REGEX)/;

                    # Keep only if it's one of the desired MIME type
                    if ( $1 && exists( $mime_types->{$1} ) ) {
                        $current_test->{"mime"} = $1;
                        $mime_types->{$1} = 1;
                    }
                }

                $current_test->{"body"} = $current_test->{"body"} . $line;
            }

        }

        # Do the checks for the last test
        _filter_test( $current_test, $named_tests, $tests );

        close($read_handler);
    }

    return $total_nbr_tests;
}
 1;
