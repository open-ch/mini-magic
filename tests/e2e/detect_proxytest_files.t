#!/usr/bin/perl
###############################################################################
#
# test.pl: Test for MimeType module
#
# Copyright (c) 2021 Open Systems AG, Switzerland
# All Rights Reserved.
#
# This test compares the results of the file command with a custom magic db against
# the default one on the files from http://content.proxytest.labs.open.ch/mime
#
# Know issue: with the version 5.36 of libmagic 2 test cases are failing,
# content.proxytest.labs.open.ch/mime/application-octet-stream.dmg and
# content.proxytest.labs.open.ch/mime/application-x-chrome-extension.crx.
#
###############################################################################

use v5.28;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Const::Fast;
use File::Path;
use File::Copy;
use MimeType;
use Test::More;

const my $TEST_FILES => "content.proxytest.labs.open.ch";
const my $DIR_MIME   => "$TEST_FILES/mime";
const my $URL        => "http://$DIR_MIME/";
const my $DEFAULT_DB => "test_default.mgc";
const my $MIME_FILE  => "test_magic";
const my $MINI_DB    => "$MIME_FILE.mgc";
const my $MAGDIR     => "test_Magdir";

sub _get_file_version {
    my ( $input, $output, $error );
    my $file_version = ( split "\n", `file -version` )[0];
    return ( split "-", $file_version )[1];
}

# clean removes the files created during the test
sub _clean {
    if ( -d $TEST_FILES ) {
        system("rm -rf $TEST_FILES");
    }

    if ( -d $MAGDIR ) {
        system("rm -rf $MAGDIR");
    }

    if ( -e $MIME_FILE ) {
        unlink $MIME_FILE;
    }

    if ( -e $DEFAULT_DB ) {
        unlink $DEFAULT_DB;
    }

    if ( -e $MINI_DB ) {
        unlink $MINI_DB;
    }
}

my $file_version = _get_file_version();

# Download test files
_clean();
system( 'wget -q -r -np -R "index.html*" ' . $URL )
  ;    #or die "downloading test files from $URL failed: $!";

# Download MIME type definitions
MimeType::download_magic_files( $MAGDIR, $file_version );

# Compile magic database with all definitions
system("file -C -m $MAGDIR; mv $MAGDIR.mgc $DEFAULT_DB")
  ; #or die "impossible to compile magic database with all MIME type definitions: $!";

# Determine minimal DB (testing with duplicates)
my @files      = <$DIR_MIME/*>;
my @mime_types = ();
my $nbr_tests  = 0;
for my $file (@files) {
    my $mime = ( split ";", `file -m $DEFAULT_DB $file -i -b` )[0];
    push( @mime_types, $mime );
    $nbr_tests++;
}

# Create minimal DB
MimeType::create_mini_magic_file( \@mime_types, $MAGDIR, $MIME_FILE );
system("file -C -m $MIME_FILE")
  ; # or die "impossible to compile minimal magic database with MIME type definitions at $MIME_FILE: $!";

#Test minimal magic database against default one
my $failed = 0;
for my $file (@files) {
    my $default = ( split ";", `file -m $DEFAULT_DB $file -i -b` )[0];
    my $custom  = ( split ";", `file -m $MINI_DB $file -i -b` )[0];

    is( $custom, $default, $file );
}

done_testing($nbr_tests);

_clean();
