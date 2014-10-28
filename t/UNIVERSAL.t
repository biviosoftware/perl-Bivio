#!perl -w
# Copyright (c) 2005-2008 bivio Software, Inc.  All rights reserved.
# $Id$
use strict;
use Bivio::Test;
use Bivio::UNIVERSAL;
use Bivio::DieCode;

package Bivio::t::UNIVERSAL::t1;

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

sub my_caller_t {
    return _c(@_);
}

sub _c {
    return shift->my_caller;
}

package main;
require './UNIVERSAL/DataSectionOK.pm';

Bivio::Test->unit([
    'Bivio::UNIVERSAL' => [
	die => [
	    [NOT_FOUND => {message => 'hey'}] => Bivio::DieCode->NOT_FOUND,
	    [Bivio::DieCode->NOT_FOUND] => Bivio::DieCode->NOT_FOUND,
	    [not_found => {message => 'hey'}] =>  Bivio::DieCode->DIE,
	],
	use => [
	    'Type.String' => 'Bivio::Type::String',
	    'Bivio::UNIVERSAL' => 'Bivio::UNIVERSAL',
	    'Not::Known::Class' => Bivio::DieCode->NOT_FOUND,
	],
	map_by_two => [
	    [sub {$_[0]}, []] => [[]],
	    [sub {$_[0]}, [qw(a)]] => [[qw(a)]],
	    [sub {$_[1]}, [qw(a)]] => [[undef]],
	    [sub {$_[0]}, [qw(a 1 b 2)]] => [[qw(a b)]],
	    [sub {$_[1]}, [qw(a 1 b 2)]] => [[qw(1 2)]],
	    [sub {$_[0]}] => [[]],
	],
	map_by_slice => [
	    [sub {join('', @_)}, [qw(a 1 x b 2 y)]] => [[qw(a10 xb1 2y2)]],
	    [sub {join('', @_)}, [qw(a 1 x b 2 y)], 3] => [[qw(a1x0 b2y1)]],
	],
	is_blesser_of => [
	    [undef] => 0,
	    [''] => 0,
	    [qr{any}] => 0,
	    [qr{any}, 'UNIVERSAL'] => 0,
	    [\('any')] => 0,
	    [Bivio::UNIVERSAL->new] => 1,
	    [Bivio::UNIVERSAL->new, 'Bivio::Type'] => 0,
	    [Bivio::UNIVERSAL->new, 'Bivio::UNIVERSAL'] => 1,
	    [Bivio::DieCode->DIE, 'Bivio::Type'] => 1,
	],
	is_super_of => [
	    [undef] => 0,
	    [''] => 0,
	    [qr{any}] => 0,
	    [Bivio::UNIVERSAL->new] => 1,
	    ['Bivio::Type'] => 1,
	],
     ],
    'Bivio::t::UNIVERSAL::t1' => [
	is_super_of => [
	    ['Bivio::t::UNIVERSAL::t2'] => 1,
	    [Bivio::UNIVERSAL->new] => 0,
	    ['Bivio::Type'] => 0,
	],
	is_blesser_of => [
	    ['Bivio::t::UNIVERSAL::t2'] => 0,
	    [Bivio::UNIVERSAL->new] => 0,
	    [Bivio::DieCode->DIE] => 0,
	],
	inheritance_ancestors => [
	    [] => [[qw(Bivio::UNIVERSAL)]],
	],
	my_idi => 0,
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
	    [sub {$_[0] + $_[1]}, [1, 2, 3], [4]] => [[5, 6, 7]],
	],
	return_scalar_or_array => [
	    [] => [],
	    1 => 1,
	    [1, 2] => [1, 2],
	],
	{
	    method => 'return_scalar_or_array',
	    want_scalar => 1,
	} => [
	    [] => [undef],
	    1 => 1,
	    [1, 2] => qr{must.*array},
	],
    ],
    'Bivio::t::UNIVERSAL::t2' => [
	inheritance_ancestors => [
	    [] => [[qw(Bivio::t::UNIVERSAL::t1 Bivio::UNIVERSAL)]],
	],
	grep_methods => [
	    [qr{^my_}] => [[qw(my_caller my_caller_t my_idi)]],
	    [qr{^my_(.*)}] => [[qw(caller caller_t idi)]],
	    [qr{^package_name$}] => [['package_name']],
	],
	grep_subroutines => [
	    [qr{package_name}] => [[]],
	    [qr{^my_}] => [[qw(my_caller_t my_idi)]],
	],
	my_idi => 1,
	my_caller_t => 'my_caller_t',
    ],
    'Bivio::t::UNIVERSAL::DataSectionOK' => [
	internal_data_section => qr{data ok},
    ],
    'Bivio::t::UNIVERSAL::DataSectionMissing' => [
	internal_data_section => Bivio::DieCode->DIE,
    ],
]);

