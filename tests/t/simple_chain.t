#!/usr/bin/perl
###############################################################################
#
# simple_chain.t: Test for MiniMagic module
#
# Copyright (c) 2021 Open Systems AG, Switzerland
# All Rights Reserved.
#
# This unit-test tests the function _traverse_tests_tree with the variations of the
# simple cases where one test calls (only) another test.
#
###############################################################################

use v5.28;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Test::More tests => 8;
use MiniMagic;

for my $test_index ( 0 .. 3 ) {

    #Determine if the tests should have their field "mime" set or not
    my $caller_mime_type = $test_index < 2      ? 1 : 0;
    my $callee_mime_type = $test_index % 2 == 0 ? 1 : 0;

    # build test structures
    my $caller = {};
    $caller->{"mime"} = "";
    if ($caller_mime_type) {
        $caller->{"mime"} = "something";
    }
    $caller->{"name"}  = [];
    $caller->{"use"}   = ["callee"];
    $caller->{"saved"} = 0;

    my $callee = {};
    $callee->{"mime"} = "";
    if ($callee_mime_type) {
        $callee->{"mime"} = "something";
    }
    $callee->{"name"}  = ["callee"];
    $callee->{"use"}   = [];
    $callee->{"saved"} = 0;

    my %named_tests = ( "callee" => $callee );

    my ( $save, $discovered_ref ) =
      MiniMagic::_traverse_tests_tree( $caller, \%named_tests );

    ok(
        ( $caller_mime_type || $callee_mime_type ) == $save,
        "Caller: $caller_mime_type and Callee: $callee_mime_type"
    );
    my $discovered_tests = keys %{$discovered_ref};
    ok( $discovered_tests == 1, "see all nodes in tree" );

}
