# $Id$
use strict;
use Bivio::Test;
use Bivio::Mail::Incoming;
use User::pwent ();

my($_USER) = $ENV{LOGNAME} || $ENV{USER} || User::pwent::getpwuid($>)->name;

my($_IN) = <<'EOF';
Received: (from majordomo@localhost)
	by bivio.com (8.8.7/8.8.7) id HAA23244
	for naic-outgoing; Thu, 1 Jul 1999 07:43:10 -0600
Received: from u10b.better-investing.org (u10b.better-investing.org [207.87.10.191])
	by bivio.com (8.8.7/8.8.7) with SMTP id HAA23241
	for <naic@bivio.com>; Thu, 1 Jul 1999 07:43:09 -0600
Message-ID: <123@foo.bar.com>
From: "Fan Tango" <foo_bar@foo.net>
To: "Some-List" <some-list@foo.bar.com>
Date: Thu, 1 Jul 1999 09:33:35 -0400
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
X-Priority: 3
X-MSMail-Priority: Normal
X-Mimeole: Produced By Microsoft MimeOLE V4.72.3110.3
List-Unsubscribe: <mailto:leave-some-list-14220S@foo.bar.com>
Subject: This is my subject
Reply-To: " Some-List" <some-list@foo.bar.com>
Sender: owner-naic@bivio.com
Return-Receipt-To: nagler@acm.org

Four score and seven years ago...

Fan Tango
EOF

my($_OUT) = <<"EOF";
Date: Thu, 1 Jul 1999 09:33:35 -0400
From: "Fan Tango" <foo_bar\@foo.net>
Subject: $_USER: This is my subject
Sender: $_USER-owner
To: "Some-List" <some-list\@foo.bar.com>
Reply-To: "My Fancy List" <$_USER>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
List-Unsubscribe: <mailto:leave-some-list-14220S\@foo.bar.com>
X-Mimeole: Produced By Microsoft MimeOLE V4.72.3110.3
X-MSMail-Priority: Normal
X-Priority: 3

Four score and seven years ago...

Fan Tango
EOF

Bivio::IO::Alert->warn('You will receive two identical mail messages');
my($_BODY) = 'what a body';
Bivio::Test->new('Bivio::Mail::Outgoing')->unit([
    [Bivio::Mail::Incoming->new(\$_IN)] => [
	set_headers_for_list_send => [
	    [$_USER, 'My Fancy List', 1, 1] => undef,
	],
	set_recipients => [
	    [$_USER] => undef,
	],
	send => undef,
	enqueue_send => undef,
	send_queued_messages => undef,
	as_string => $_OUT,
	set_body => [
	    [\$_BODY] => undef,
	],
	send => undef,
	as_string => sub {
	    $_OUT =~ /(^.*?\n\n)/s;
	    return [$1 . $_BODY];
	},
    ],
]);
