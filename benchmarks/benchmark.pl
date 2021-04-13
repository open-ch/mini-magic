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
use lib "$Bin/../lib";
use MimeType;
use Benchmark;
use Getopt::Long qw(:config posix_default no_ignore_case);
use File::Path;

# Print command line usage help text
sub print_help {
    print "Usage:
    OPTIONAL PARAMETERS:
    
    -i index                        Indicates the number of MIME types used for the benchmark.
                                    By default, all MIME types are used. 
    -it iterations                  Indicates the number of iterations (default 500).
    -h|--help                       Print this help message
";
    exit 1;
}

# Command-line argument processing
my $index = -1;
my $it    = 500;
GetOptions(
    "i=s"    => \$index,
    "it=s"   => \$it,
    "h|help" => \&print_help,

);

if ( !-d "temp" ) {
    mkdir("temp");
}

my $mime_list = MimeType::list_mime_types("Magdir");
my $n         = @{$mime_list};

if ( $index <= 0 or $index >= $n ) {
    $index = $n - 1;
}

my @sub = @{$mime_list}[ 0 .. $index ];

timethis(
    $it,
    sub {
        MimeType::create_mini_magic_file( \@sub, "Magdir", "temp/$index" );
    }
);
rmtree("temp");
