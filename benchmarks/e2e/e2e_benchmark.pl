#!/usr/bin/perl
###############################################################################
#
# e2e_benchmark.pl: benchmark script for the e2e process of compiling a minimal
# magic DB 
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
use Benchmark qw/cmpthese/;
use Getopt::Long qw(:config posix_default no_ignore_case);
use Const::Fast;

const my $MIME_LIST_FOLDER => "$Bin/mime-lists";
const my $SKIP_MEDIA_STREAMS_LIST => "$MIME_LIST_FOLDER/skipmediastreams.txt";
const my $PGHN_LIST => "$MIME_LIST_FOLDER/pghn.txt";

my $file_cmd = '/bin/file';
my $out = 'magic';
my $src = 'Magdir/';
my $t = -5;

# Print command line usage help text
sub print_help {
    print "Usage:
	perl e2e_benchmark.pl [Options]

	OPTIONAL PARAMETERS:

    --file path                     Indicates the path to the file command (default /bin/file)
    --out path                      Indicates the path to folder where the created magic files are stored (default magics/)
    --src path                      Indicates the path to the folder containing the MIME type definitions (default Magdir/)
	--t time                        Indicates the cpu time elapsed (default 5 seconds).
    -h|--help                       Print this help message
";
    exit 1;
}

# Command-line argument processing
GetOptions(
    "file=s"   => \$file_cmd,
    "help|h"       => \&print_help,
    "out=s"       => \$out,
    "src=s"       => \$src,
    "t=s"        => \$t,
) or print_help();



# argument of cmpthese must be negative to correspond to cpu time
$t = ($t > 0)? -$t : $t;

# Get MIME type lists
my @skipmediastreams_list;
open(my $fh, '<', $SKIP_MEDIA_STREAMS_LIST);
while(my $line = <$fh>){
    chomp($line);
    push @skipmediastreams_list, $line;
}
close($fh);

my @pghn_list;
open($fh, '<', $PGHN_LIST);
while(my $line = <$fh>){
    chomp($line);
    push @pghn_list, $line;
}
close($fh);

my @all_list = @{MimeType::list_mime_types($src)};

# Function we want to benchmark
sub compile_db{
    my $mime_list = shift;

    MimeType::create_mini_magic_file( $mime_list, $src, $out);
    system("$file_cmd -C -m $out");
}

cmpthese($t, {
    "Skip Media Streams" => sub {
        compile_db(\@skipmediastreams_list);
    },
    "PGHN" => sub {
        compile_db(\@pghn_list);
    },
    "ALL" => sub {
        compile_db(\@all_list);
    }
})