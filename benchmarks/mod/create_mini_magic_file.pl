#!/usr/bin/perl
###############################################################################
#
# benchmark.pl: benchmark script for MimeType::create_mini_magic_file
#
# Copyright (c) 2021 Open Systems AG, Switzerland
# All Rights Reserved.
#
###############################################################################

use v5.28;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use MimeType;
use Const::Fast;
use File::Path;
use List::Util 'shuffle';
use Benchmark qw(cmpthese);

const my $TMP_FILE => "$Bin/.tmp";
const my $MAGDIR   => "$TMP_FILE/Magdir";

my $time = 5;
my $step = 100;

sub _clean {

    if ( -d $TMP_FILE ) {
        rmtree($TMP_FILE) or die "Impossible to delete directory $TMP_FILE: $!";
    }
}

# Set up temporary directories
_clean();
mkdir($TMP_FILE) or die "Impossible to create directory $TMP_FILE: $!";

# Get all MIME types version 5.39
MimeType::download_magic_files( $MAGDIR, "5.39" );
my $mime_list     = MimeType::list_mime_types($MAGDIR);
my @shuffled_list = shuffle(@$mime_list);
my $nbr_mimes     = @shuffled_list;

# Create benchmark
my $benchs = {};

my $max_offset = int( $nbr_mimes / $step );

for my $offset ( 1 .. $max_offset ) {
    my $last_index = $offset * $step;
    my @sub        = @shuffled_list[ 0 .. $last_index ];
    $benchs->{$last_index} = sub {
        MimeType::create_mini_magic_file( \@sub, $MAGDIR,
            "$TMP_FILE/$last_index" );
    };
}

if ( $max_offset * $step < $nbr_mimes ) {
    $benchs->{"all"} = sub {
        MimeType::create_mini_magic_file( \@shuffled_list, $MAGDIR,
            "$TMP_FILE/all" );
    };
}

cmpthese( -$time, $benchs );

_clean();
