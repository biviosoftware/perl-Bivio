# -*-perl-*-
#
# $Id$
#
#TODO: WAY more tests...  Especially tests which test addresses
use strict;

BEGIN { $| = 1; print "1..8\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
use Bivio::Mail::Incoming;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

use User::pwent ();

Bivio::IO::Config->initialize(\@ARGV);
my(%_MSGS) = (
<<'EOF'
From owner-naic@bivio.com  Thu Jul  1 01:23:43 1999
Received: (from majordomo@localhost)
	by bivio.com (8.8.7/8.8.7) id BAA15451
	for naic-outgoing; Thu, 1 Jul 1999 01:23:43 -0600
Received: from u10b.better-investing.org (u10b.better-investing.org [207.87.10.191])
	by bivio.com (8.8.7/8.8.7) with SMTP id BAA15448
	for <naic@bivio.com>; Thu, 1 Jul 1999 01:23:42 -0600
From: ASFields@aol.com
Message-ID: <LYR14220-46243-1999.07.01-03.19.57--naic#bivio.com@lists.better-investing.org>
Date: Thu, 1 Jul 1999 03:21:17 EDT
Subject: NAIC: re: disney
To: "NAIC I-Club-List" <i-club-list@lists.better-investing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
List-Unsubscribe: <mailto:leave-i-club-list-14220S@lists.better-investing.org>
Reply-To: "NAIC I-Club-List" <i-club-list@lists.better-investing.org>
Sender: owner-naic@bivio.com
Precedence: bulk

EOF
=>
{
    'content_type' => 'text/plain',
    'from_name' => undef,
    'from_email' => 'ASFields@aol.com',
    'reply_to_email' => 'i-club-list@lists.better-investing.org',
    'subject' => 'NAIC: re: disney',
    'date_time' => 930813677,
},
<<'EOF'
From owner-naic@bivio.com  Thu Jul  1 07:43:10 1999
Received: (from majordomo@localhost)
	by bivio.com (8.8.7/8.8.7) id HAA23244
	for naic-outgoing; Thu, 1 Jul 1999 07:43:10 -0600
Received: from u10b.better-investing.org (u10b.better-investing.org [207.87.10.191])
	by bivio.com (8.8.7/8.8.7) with SMTP id HAA23241
	for <naic@bivio.com>; Thu, 1 Jul 1999 07:43:09 -0600
Message-ID: <LYR14220-46291-1999.07.01-09.25.14--naic#bivio.com@lists.better-investing.org>
From: "Dan Hess" <dan_hess@prodigy.net>
To: "NAIC I-Club-List" <i-club-list@lists.better-investing.org>
Date: Thu, 1 Jul 1999 09:33:35 -0400
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
X-Priority: 3
X-MSMail-Priority: Normal
X-Mimeole: Produced By Microsoft MimeOLE V4.72.3110.3
List-Unsubscribe: <mailto:leave-i-club-list-14220S@lists.better-investing.org>
Reply-To: "NAIC I-Club-List" <i-club-list@lists.better-investing.org>
Sender: owner-naic@bivio.com
Precedence: bulk

Okay Joe I give up.  I grew up near Philadelphia (Bucks County) a long time
ago and I never heard of Ithan.  Where is it located?
Dan Hess
EOF
=>
{
    'content_type' => 'text/plain',
    'from_name' => 'Dan Hess',
    'from_email' => 'dan_hess@prodigy.net',
    'reply_to_email' => 'i-club-list@lists.better-investing.org',
    'subject' => undef,
    'date_time' => 930836015,
},
<<'EOF'
From owner-naic@bivio.com  Thu Jul  1 09:20:07 1999
Received: (from majordomo@localhost)
	by bivio.com (8.8.7/8.8.7) id JAA23323
	for naic-outgoing; Thu, 1 Jul 1999 09:20:07 -0600
Received: from u10b.better-investing.org (u10b.better-investing.org [207.87.10.191])
	by bivio.com (8.8.7/8.8.7) with SMTP id JAA23320
	for <naic@bivio.com>; Thu, 1 Jul 1999 09:20:05 -0600
Message-ID: <LYR14220-46326-1999.07.01-11.15.27--naic#bivio.com@lists.better-investing.org>
From: Dean Beeman <dbeeman@thegrid.net>
To: "NAIC I-Club-List" <i-club-list@lists.better-investing.org>
Subject:
Date: Thu, 1 Jul 1999 08:05:05 -0700
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Transfer-Encoding: 7bit
List-Unsubscribe: <mailto:leave-i-club-list-14220S@lists.better-investing.org>
Reply-To: "NAIC I-Club-List" <i-club-list@lists.better-investing.org>
Sender: owner-naic@bivio.com
Precedence: bulk

In my opinion, leaving your estate in a living trust has no effect whatsoever on
Income or estate taxes.
You practicing CPA's.  Correct me if I'm wrong.
Dean Beeman
Retired CPA

-----Original Message-----
From:	Jeffrey Richer [SMTP:jricher@inet.net]
Sent:	Wednesday, June 30, 1999 7:21 PM

	I tend to generally agree with your statement Ellis; however, there are
some of us out there who will leave a sizable estate to whomever.  Even in
a taxable account, there is a stepped up cost basis so that the capital
gains taxes would be insignificant.  Assumming this estate to be in the
form of a living trust, taxes would not be an issue at all.
-------------------------------------
Jeffrey Richer
Cross Country Investment Club, an On-Line Club
EOF
=>
{
    'content_type' => 'text/plain',
    'from_name' => 'Dean Beeman',
    'from_email' => 'dbeeman@thegrid.net',
    'reply_to_email' => 'i-club-list@lists.better-investing.org',
    'subject' => '',
    'date_time' => 930841505,
},
<<'EOF'
From moeller@[209.181.76.152]  Fri Jul 23 15:11:23 1999
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
=>
{
    'content_type' => 'text/plain',
    'from_name' => '',
    'from_email' => 'moeller@[209.181.76.152]',
    'reply_to_email' => undef,
    'subject' => 'hello',
    'date_time' => 932764367,
},
<<'EOF'
Return-Path: <johnk@inil.com>
Received: from mail.inil.com (inil.com [206.31.32.8])
        by bivio.com (8.9.3/8.9.3) with ESMTP id PAA17492
        for <my21cm@bivio.com>; Thu, 9 Dec 1999 15:18:36 -0700
Received: from jknwlap ([207.49.255.153]) by mail.inil.com
          (Post.Office MTA v3.5.3 release 223 ID# 177-57935U7500L650S0V35)
          with SMTP id com for <my21cm@bivio.com>;
          Thu, 9 Dec 1999 16:18:32 -0600
Reply-To: <johnk@inil.com>
From: johnk@inil.com (johnk)
To: <my21cm@bivio.com>
Subject: Re: Christmas meeting
Date: Thu, 9 Dec 1999 16:18:41 GMT
Message-ID: <A1EEBDC29AE0D211A55200104B9F09664290@DUALIV>
MIME-Version: 1.0
Content-Type: text/plain;
        charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
X-Priority: 3 (Normal)
X-MSMail-Priority: Normal
X-Mailer: Microsoft Outlook CWS, Build 9.0.2416 (9.0.2910.0)
Importance: Normal
X-MimeOLE: Produced By Microsoft MimeOLE V5.00.2314.1300

Some body
EOF
=>
{
    'content_type' => 'text/plain',
    'from_name' => 'johnk',
    'from_email' => 'johnk@inil.com',
    'reply_to_email' => 'johnk@inil.com',
    'subject' => 'Re: Christmas meeting',
    'date_time' => 944756321,
},
<<'EOF'
Return-Path: <nagler@mail.bivio.com>
Received: from mail.bivio.com (ski.bivio.com [207.174.140.66])
        by test.bivio.com (8.9.3/8.9.3) with ESMTP id PAA22679
        for <ask_candis@test.bivio.com>; Thu, 16 Dec 1999 15:20:38 -0700
Received: (from nagler@localhost)
        by mail.bivio.com (8.8.7/8.8.7) id PAA09081
        for ask_candis@test.bivio.com; Thu, 16 Dec 1999 15:20:38 -0700
Date: Thu, 16 Dec 1999 15:20:38 -0700
Message-Id: <199912162220.PAA09081@mail.bivio.com>
From: Candis King <candis@enteract.com>
Subject: What resources are available to new investors?
MIME-Version: 1.0
To: ask_candis_publish@test.bivio.com
Subject: What makes you successful as an NAIC investor?
Content-Type: text/html; charset=us-ascii
Content-Transfer-Encoding: 7bit

<!doctype html public "-//w3c//dtd html 4.0 transitional//en">
<html>
<head>
<title>What resources are available to new investors?</title>
</head>
<body>
<u>Susan M. of Bay View, MI writes:</u>
<br>
<i>
I am a new investor and don't understand where to begin to look
for investing information.  What resources would you suggest a
new investor start out with?
</i>

<p>
Dear Susan,
<p>
Candis King<br>
Wheaton, IL<br>
<a href="mailto:ask_candis@bivio.com">ask_candis@bivio.com</a><br>
</body>
</html>
EOF
=>
{
    'content_type' => 'text/html',
    'from_name' => 'Candis King',
    'from_email' => 'candis@enteract.com',
    'reply_to_email' => undef,
    'subject' => 'What resources are available to new investors?',
    'date_time' => 945382838,
},
);

my($test) = 2;
my($msg, $fields, $id);
while (($msg, $fields) = each(%_MSGS)) {
    my($bmi) = Bivio::Mail::Incoming->new(\$msg);
    $id = $bmi->get_message_id;
    my($e, $n) = $bmi->get_from;
    &assert_eq('from_email',  $e) || next;
    &assert_eq('from_name',  $n) || next;
    &assert_eq('reply_to_email', $bmi->get_reply_to) || next;
    &assert_eq('subject', $bmi->get_subject) || next;
    &assert_eq('date_time', $bmi->get_date_time) || next;
    (undef, $fields->{body}) = split(/\n\n/, $msg, 2);
    &assert_eq('body', $bmi->get_body) || next;
    print "ok $test\n";
}
continue {
    $test++;
}

sub assert_eq {
    my($f, $v) = @_;
    defined($fields->{$f}) == defined($v)
	    && (!defined($v) || $fields->{$f} eq $v) && return 1;
    $v = defined($v) ? substr($v, 0, 100) : 'undef';
    my($exp) = defined($fields->{$f}) ? substr($fields->{$f}, 0, 100)
	    : 'undef';
    print <<"EOF";
Message-Id: $id
$f: expected "$exp", got "$v"
not ok $test
EOF
    return 0;
}

$msg = <<"EOF";
From: Joe Blow <joe_blow>
To: Joe Farmer <joe_farmer>
Subject: My message (pid = $$)
Message-Id: <1234567890\@blow.com>

This is the body.
EOF
my($bmi) = Bivio::Mail::Incoming->new(\$msg);
$bmi->set_recipients(User::pwent::getpwuid($>)->name);
$bmi->enqueue_send;
$bmi->send_queued_messages;
print "ok $test\n";
$test++;
