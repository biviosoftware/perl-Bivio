# Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test::Request;
use Bivio::UI::Widget::Join;
my($req) = Bivio::Test::Request->get_instance;
Bivio::Test->new({
    class_name => 'Bivio::UI::Widget::MIMEEntity',
    compute_params => sub {
	my($case, $params) = @_;
	my($s) = '';
	return $case->get('method') eq 'render' ? [$req, \$s] : $params;
    },
    check_return => sub {
       my($case, $actual, $expect) = @_;
       $case->actual_return([${$case->get('params')->[1]}])
	   if $case->get('method') eq 'render';
       return $expect;
   },
})->unit([
    [
	[
	    Bivio::UI::Widget::Join->new([
		"Part one",
	    ], {
		mime_type => 'text/html; charset="us-ascii"',
		mime_encoding => '7bit',
	    }),
	    Bivio::UI::Widget::Join->new([
		"From: a\@b.c\n\nPart two.",
	    ], {
		mime_type => 'message/rfc822',
		mime_encoding => '7bit',
	    }),
	],
    ] => [
	initialize => undef,
	render => qr{text/html.*\n\nPart one\n--}is,
	headers_as_string => [
	    [$req] => qr{MIME-Version.*1.0.*Content-Type.*multipart/mixed; boundary}is,
	],
    ],
    [
	[
	    Bivio::UI::Widget::Join->new([
		'Part one',
	    ], {
		mime_type => 'text/plain; charset="us-ascii"',
		mime_encoding => '7bit',
	    }),
	    Bivio::UI::Widget::Join->new([
		'<html><body>Part one</body></html>',
	    ], {
		mime_type => 'text/html; charset="us-ascii"',
		mime_encoding => '7bit',
	    }),
	],
	{
	    mime_type => 'multipart/alternative',
	},
    ] => [
	initialize => undef,
	render => qr{text/plain;.*\nPart One\n.*text/html;.*<body>Part One</body>}is,
	headers_as_string => [
	    [$req] => qr{MIME-Version.*1.0.*Content-Type.*multipart/alternative; boundary}is,
	],
    ],
]);
