# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test::Widget;
use Bivio::Type::UserAgent;
use Bivio::UI::HTML::Widget::Script;

Bivio::Test::Widget->unit(
    'Bivio::UI::HTML::Widget::Page',
    undef,
    sub {
	my($case, $actual, $expect) = @_;
	my($r) = $actual->[0];
	$r =~ s{.*?<html><head>\n}{}s || die;
	$r =~ s{\n</body></html>\n}{}s || die;
	return [$r];
    },
    [
 	['head', 'hello', {style => ''}] => qr{head</head><body bgcolor="#FFFFFF" text="#000000" link="#330099" alink="#330099" vlink="#330099">\nhello}is,
	['', '', {
	    style => '',
	    want_page_print => [sub {0}],
	}] => sub {
	    my(undef, $actual) = @_;
	    return $actual->[0] =~ /page_print/ ? 0 : 1;
	},
	[
	    '',
	    Bivio::UI::HTML::Widget::Script->new('first_focus'),
	    {
		want_page_print => 1,
		style => '',
	    },
	] => qr/first_focus_onload.*page_print_onload.*<body/is,
    ],
);
