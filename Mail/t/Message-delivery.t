# -*-perl-*-
#
# $Id$
#
#TODO: WAY more tests...  Especially tests which test addresses
use strict;

BEGIN { $| = 1; print "1..\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
use Bivio::Mail::Message;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

use User::pwent ();
my($user) = User::pwent::getpwuid($>);

my($msg1) = <<"EOF";
From: Joe Blow <joe_blow>
To: Joe Farmer <joe_farmer>
Subject: My message (pid = $$)
Message-Id: <1234567890\@blow.com>

This is the body.
EOF

my($bm) = Bivio::Mail::Message->new(\$msg1);
$bm->set_recipients($user->name);
my($r) = $bm->get_recipients;
$r->[0] eq User::pwent::getpwuid($>)->name || die;
$bm->enqueue_send;

my($m2) = Bivio::Mail::Message->new;
$m2->set_recipients($user->name);
my($h) = $m2->get_head;
$h->replace('Subject', "Hi!");
$m2->get_entity->attach(Path => 'Mail/t/ms_y2k.jpg', Type => "image/jpeg", Encoding => "base64");
$m2->send;

my($msg) = <<'EOF';
Return-Path: <moeller@[209.181.76.152]>
Received: from [209.181.76.152] (moeller@ndsl152.dnvr.uswest.net [209.181.76.152])
	by bivio.com (8.8.7/8.8.7) with ESMTP id PAA03666
	for <nagler@bivio.com>; Fri, 23 Jul 1999 15:11:23 -0600
From: moeller@[209.181.76.152]
Received: (from moeller@localhost)
	by [209.181.76.152] (8.8.7/8.8.7) id PAA01336
	for nagler@bivio.com; Fri, 23 Jul 1999 15:12:47 -0600
Date: Fri, 23 Jul 1999 15:12:47 -0600
Message-Id: <199907232112.PAA01336@[209.181.76.152]>
To: nagler@bivio.com
Subject: hello
Status: R

12.
EOF

my($bm) = Bivio::Mail::Message->new(\$msg);
$bm->set_headers_for_list_send('LIST-NAME', 'LIST_TITLE', 1, 1);
$bm->set_recipients($user->name);
$bm->enqueue_send;

print("You should have received 3 messages, please check manually\n");
$bm->send_queued_messages;
