# Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test::Request;
use Bivio::UI::Widget::Join;
my($_req) = Bivio::Test::Request->get_instance;
Bivio::Test->new('Bivio::UI::Widget::MIMEEntity')->unit([
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
	render => [
	    sub {
		my($s) = '';
		return [$_req, \$s];
	    } => sub {
		my($case) = @_;
		$case->actual_return([${$case->get('params')->[1]}]);
		return qr{text/html.*\n\nPart one\n--}is;
	    },
	],
	headers_as_string => [
	    [$_req] => qr{MIME-Version.*1.0.*Content-Type.*multipart/mixed; boundary}is,
	],
    ],
]);
