# Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test::Request;
use Bivio::UI::Widget::Join;
my($_req) = Bivio::Test::Request->get_instance;
Bivio::Test->new({
    class_name => 'Bivio::UI::Widget::Director',
    compute_params => sub {
	my($case, $params, $method) = @_;
	return $params
	    unless $method eq 'render';
	$_req->put(control => $params->[0]);
	my($x) = '';
	return $method eq 'render' ? [$_req, \$x] : $params;
    },
    check_return => sub {
	my($case, $actual, $expected) = @_;
	$case->actual_return([${$case->get('params')->[1]}]);
	return $expected;
    }
})->unit([
    [
	['control'],
	{
	    map({
		my($v, $w) = @$_;
		$v => Bivio::UI::Widget::Join->new([$w]);
	    }
		['' => 'empty'],
		[0 => 'zero'],
		[1 => 'one'],
		[ctl => ['control']],
	    ),
	},
    ] => [
	initialize => undef,
	render => [
	    '' => 'empty',
	    0 => 'zero',
	    1 => 'one',
	    ctl => 'ctl',
	    force_default => Bivio::DieCode->DIE,
	    [undef] => Bivio::DieCode->DIE,
        ],
    ],
    [
	['control'],
	{
	    1 => Bivio::UI::Widget::Join->new(['one']),
	},
	Bivio::UI::Widget::Join->new(['default_value']),
	Bivio::UI::Widget::Join->new(['undef_value']),
    ] => [
	initialize => undef,
	render => [
	    1 => 'one',
	    force_default => 'default_value',
	    [undef] => 'undef_value',
        ],
    ],
]);
