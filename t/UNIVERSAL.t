#!perl -w
# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# $Id$
use strict;
use Bivio::Test;
use Bivio::UNIVERSAL;

package Bivio::t::UNIVERSAL::t1;
$Bivio::t::UNIVERSAL::t1::VERSION = 3.154;

@Bivio::t::UNIVERSAL::t1::ISA = ('Bivio::UNIVERSAL');
my($_IDI1) = __PACKAGE__->instance_data_index;
sub my_idi {
    return $_IDI1;
}

sub concat {
    my(undef, @args) = @_;
    return join('-', @args);
}

package Bivio::t::UNIVERSAL::t2;
@Bivio::t::UNIVERSAL::t2::ISA = ('Bivio::t::UNIVERSAL::t1');
my($_IDI2) = __PACKAGE__->instance_data_index;
sub my_idi {
    return $_IDI2;
}

package main;

Bivio::Test->unit([
    'Bivio::t::UNIVERSAL::t1' => [
	inheritance_ancestor_list => [
	    [] => [[qw(Bivio::UNIVERSAL)]],
	],
	my_idi => 0,
	package_version => 3.154,
	simple_package_name => 't1',
	as_string => 'Bivio::t::UNIVERSAL::t1',
	equals => [
	    'Bivio::t::UNIVERSAL::t1' => 1,
	    'Bivio::t::UNIVERSAL::t2' => 0,
	],
	map_invoke => [
	    ['concat', ['a']] => [['a']],
	    ['concat', [qw(a b)]] => [[qw(a b)]],
	    ['concat', [[qw(a b)], [qw(c d)]]] => [['a-b', 'c-d']],
	    ['concat', [[qw(a b)], [qw(c d)]], ['x']] => [['x-a-b', 'x-c-d']],
	    ['concat', [[qw(a b)], [qw(c d)]], ['x'], ['y']] => [['x-a-b-y', 'x-c-d-y']],
	    ['concat', [[qw(a b)], [qw(c d)]], undef, ['y']] => [['a-b-y', 'c-d-y']],
	],
    ],
    'Bivio::t::UNIVERSAL::t2' => [
	inheritance_ancestor_list => [
	    [] => [[qw(Bivio::t::UNIVERSAL::t1 Bivio::UNIVERSAL)]],
	],
	my_idi => 1,
    ],
]);

