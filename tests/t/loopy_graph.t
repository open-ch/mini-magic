#!/usr/bin/perl
###############################################################################
#
# loopy_graph.t: Test for MiniMagic module
#
# Copyright (c) 2021 Open Systems AG, Switzerland
# All Rights Reserved.
#
# This unit-test tests the function _traverse_tests_tree with a graph containing a loop
#
###############################################################################
use v5.28;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Test::More tests => 2;
use MiniMagic;

# build_input builds the binary tree used as input for the function _traverse_tests_tree
# It returns:
# - the root of the tree
# - the hash reference to the hash that contains all tests with the type name
sub build_input {
    my $root = {};
    $root->{"body"}  = "";
    $root->{"mime"}  = "";
    $root->{"name"}  = [];
    $root->{"use"}   = [ "level1_1", "level1_2" ];
    $root->{"saved"} = 0;

    my $level1_1;
    $level1_1->{"body"}  = "";
    $level1_1->{"mime"}  = "";
    $level1_1->{"name"}  = ["level1_1"];
    $level1_1->{"use"}   = [ "level2", "level2" ];
    $level1_1->{"saved"} = 0;

    my $level1_2;
    $level1_2->{"body"}  = "";
    $level1_2->{"mime"}  = "";
    $level1_2->{"name"}  = ["level1_2"];
    $level1_2->{"use"}   = [ "level2", "level2" ];
    $level1_2->{"saved"} = 0;

    my $level2;
    $level2->{"body"}  = "";
    $level2->{"mime"}  = "something";
    $level2->{"name"}  = ["level2"];
    $level2->{"use"}   = [];
    $level2->{"saved"} = 0;

    my %named_tests = (
        "level1_1" => $level1_1,
        "level1_2" => $level1_2,
        "level2"   => $level2,
    );

    return ( $root, \%named_tests );
}

my ( $root, $named_tests ) = build_input();
my ( $save, $discovered_ref ) =
  MiniMagic::_traverse_tests_tree( $root, $named_tests );

my $nbr_discovered_tests = keys %{$discovered_ref};

ok( $save, "all tests must be saved" );
is( $nbr_discovered_tests, 3, "all tests were discovered" );

