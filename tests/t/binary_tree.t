#!/usr/bin/perl
###############################################################################
#
# binary_tree.t: Test for MiniMagic module
#
# Copyright (c) 2021 Open Systems AG, Switzerland
# All Rights Reserved.
#
# This unit-test tests the function _traverse_tests_tree with a 3-level binary tree
# with one of the leafs that must be saved
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
    $root->{"mimes"}  = [];
    $root->{"name"}  = [];
    $root->{"use"}   = [ "level1_1", "level1_2" ];
    $root->{"saved"} = 0;

    my $level1_1;
    $level1_1->{"body"}  = "";
    $level1_1->{"mimes"}  = [];
    $level1_1->{"name"}  = ["level1_1"];
    $level1_1->{"use"}   = [ "level2_1", "level2_2" ];
    $level1_1->{"saved"} = 0;

    my $level1_2;
    $level1_2->{"body"}  = "";
    $level1_2->{"mimes"}  = [];
    $level1_2->{"name"}  = ["level1_2"];
    $level1_2->{"use"}   = [ "level2_3", "level2_4" ];
    $level1_2->{"saved"} = 0;

    my $level2_1;
    $level2_1->{"body"}  = "";
    $level2_1->{"mimes"}  = [];
    $level2_1->{"name"}  = ["level2_1"];
    $level2_1->{"use"}   = [];
    $level2_1->{"saved"} = 0;

    my $level2_2;
    $level2_2->{"body"}  = "";
    $level2_2->{"mimes"}  = [];
    $level2_2->{"name"}  = ["level2_2"];
    $level2_2->{"use"}   = [];
    $level2_2->{"saved"} = 0;

    my $level2_3;
    $level2_3->{"body"}  = "";
    $level2_3->{"mimes"}  = [];
    $level2_3->{"name"}  = ["level2_3"];
    $level2_3->{"use"}   = [];
    $level2_3->{"saved"} = 0;

    my $level2_4;
    $level2_4->{"body"}  = "";
    $level2_4->{"mimes"}  = ['something'];
    $level2_4->{"name"}  = ["level2_4"];
    $level2_4->{"use"}   = [];
    $level2_4->{"saved"} = 0;
    $level2_4->{"has_desired_mime"} = 1;

    my %named_tests = (
        "level1_1" => $level1_1,
        "level1_2" => $level1_2,
        "level2_1" => $level2_1,
        "level2_2" => $level2_2,
        "level2_3" => $level2_3,
        "level2_4" => $level2_4,
    );

    return ( $root, \%named_tests );
}

my ( $root, $named_tests ) = build_input();
my ( $save, $discovered_ref ) =
  MiniMagic::_traverse_tests_tree( $root, $named_tests );

my $nbr_discovered_tests = keys %{$discovered_ref};

ok( $save, "all tests must be saved" );
is( $nbr_discovered_tests, 6, "all tests were discovered" );

