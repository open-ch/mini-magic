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
use Const::Fast;
use File::Path;

const my $MIME_LIST_FOLDER => "$Bin/mime-lists";
const my $THIRTEEN_TESTS => "$MIME_LIST_FOLDER/13tests.txt";
const my $FIFTY_FIVE_TESTS => "$MIME_LIST_FOLDER/55tests.txt";
const my $TMP_FILE => "$Bin/.tmp";
const my $MAGDIR => "$TMP_FILE/Magdir";
const my $TIME => 5;
const my $MAGIC => "magic";

sub _clean {
    
    if ( -d $TMP_FILE ){
        rmtree($TMP_FILE) or die "Impossible to delete directory $TMP_FILE: $!";
    }
}

sub get_file_version {
    my $file_version_out = `file -v`;

    if ( $file_version_out =~ /(file-\d+\.\d+)/){ 
        my ($version) = $file_version_out =~ /(\d+\.\d+)/;
        return $version;
    }
}

my $file_version = get_file_version();
die "No version for the file command found" unless $file_version;

# Set up temporary directories
_clean();
mkdir($TMP_FILE) or die "Impossible to create directory $TMP_FILE: $!";

# Get all MIME types version 5.39
MimeType::download_magic_files($MAGDIR,$file_version); 

# Get MIME type lists
my @thirteen_list;
open(my $fh, '<', $THIRTEEN_TESTS);
while(my $line = <$fh>){
    chomp($line);
    push @thirteen_list, $line;
}
close($fh);



my @fifty_five_list;
open($fh, '<', $FIFTY_FIVE_TESTS);
while(my $line = <$fh>){
    chomp($line);
    push @fifty_five_list, $line;
}
close($fh);

my @all_list = @{MimeType::list_mime_types($MAGDIR)};

# Function we want to benchmark
sub compile_db{
    my $mime_list = shift;
    my $suffix = shift;
    my $out = $MAGIC.$suffix;
    MimeType::create_mini_magic_file( $mime_list, $MAGDIR, "$TMP_FILE/$out");
    chdir($TMP_FILE);
    system("file -C -m $out");
}

cmpthese(-$TIME, {
    "13 Tests"=> sub {
        compile_db(\@thirteen_list, "13");
    },
    "55 Tests" => sub {
        compile_db(\@fifty_five_list, "55");
    },
    "1035 Tests (all)" => sub {
        compile_db(\@all_list, "all");
    }
})

_clean();
