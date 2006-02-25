# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# $Id$
use strict;
use Bivio::Test;
use Bivio::Mail::Incoming;
use Bivio::Test::Request;

my($req) = Bivio::Test::Request->initialize_fully;
# use User::pwent ();
# my($_USER) = $ENV{LOGNAME} || $ENV{USER} || User::pwent::getpwuid($>)->name;
# Bivio::IO::Alert->warn('You will receive two identical mail messages');
my($_USER) = 'nobody@example.com';

my($_IN) = <<'EOF';
Received: (from majordomo@localhost)
	by bivio.com (8.8.7/8.8.7) id HAA23244
	for example.com; Thu, 1 Jul 1999 07:43:10 -0600
Received: from lists.bivio.com)
	by foo.example.com (8.8.7/8.8.7) with SMTP id HAA23241
	for <any@bivio.com>; Thu, 1 Jul 1999 07:43:09 -0600
Message-ID: <123@example.com>
From: "Fan Tango" <foo_bar@example.net>
To: "Some-List" <some-list@example.com>
Date: Thu, 1 Jul 1999 09:33:35 -0400
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
X-Priority: 3
X-MSMail-Priority: Normal
X-Mimeole: Produced By Microsoft MimeOLE V4.72.3110.3
List-Unsubscribe: <mailto:leave-some-list-14220S@example.com>
Subject: This is my subject
Reply-To: " Some-List" <some-list@example.com>
Sender: owner-some-list@bivio.com
Return-Receipt-To: nagler@acm.org

Four score and seven years ago...

Fan Tango
EOF


my($host) = Sys::Hostname::hostname();
my($_OUT) = <<"EOF";
Date: Thu, 1 Jul 1999 09:33:35 -0400
From: "Fan Tango" <foo_bar\@example.net>
Subject: [abc] This is my subject
Sender: some-list-owner\@$host
To: "My Fancy List" <some-list\@$host>
Reply-To: "My Fancy List" <some-list\@$host>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
List-Unsubscribe: <mailto:leave-some-list-14220S\@example.com>
X-Mimeole: Produced By Microsoft MimeOLE V4.72.3110.3
X-MSMail-Priority: Normal
X-Priority: 3

Four score and seven years ago...

Fan Tango
EOF

my($_BODY) = 'what a body';
Bivio::Test->new('Bivio::Mail::Outgoing')->unit([
    [Bivio::Mail::Incoming->new(\$_IN)] => [
	set_headers_for_list_send => [
	    ['some-list', 'My Fancy List', 1, '[abc]', $req] => undef,
	],
	unsafe_get_recipients => [
	    [] => [undef],
	],
	set_recipients => [
	    [[$_USER, 'joe@example.com']] => undef,
	],
	unsafe_get_recipients => $_USER . ',joe@example.com',
	set_recipients => [
	    [$_USER] => undef,
	],
	unsafe_get_recipients => $_USER,
	unsafe_get_header => [
	    'Date' => "Thu, 1 Jul 1999 09:33:35 -0400",
	    'Not_Found' => [undef],
	],
	format_as_bounce => [
	    ['bad, bad, bad', undef, undef, undef, $req]
		=> qr{ERROR.*$_USER.*bad, bad, bad.*Original}s,
	],
	send => [
	    [$req] => undef,
	],
	enqueue_send => [
	    [$req] => undef,
	],
	send_queued_messages => [
	    [$req] => undef,
	],
	as_string => $_OUT,
	set_body => [
	    [\$_BODY] => undef,
	],
	send => [
	    [$req] => undef,
	],
	as_string => sub {
	    $_OUT =~ /(^.*?\n\n)/s;
	    return [$1 . $_BODY];
	},
	add_missing_headers => [
	    [undef, $req] => undef,
	],
	as_string => qr{Return-Path: <foo_bar\@example.net>\nMessage-ID}is,
    ],
]);
