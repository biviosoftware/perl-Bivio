# Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test::Widget;
Bivio::Test::Widget->unit(
    'Bivio::UI::Widget::Director',
    sub {
	my($req, $case, $params) = @_;
	$req->put(control => $params->[0]);
	return;
    },
[
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
	'default_value',
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
