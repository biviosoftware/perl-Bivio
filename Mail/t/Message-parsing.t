# -*-perl-*-
#
# $Id$
#
#TODO: WAY more tests...  Especially tests which test addresses
use strict;

BEGIN { $| = 1; print "1..9\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
use Bivio::Mail::Message;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

use User::pwent ();

my(%_MSGS) = (
<<'EOF'
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
    'content_type' => 'text/plain; charset="us-ascii"',
    'from_name' => undef,
    'from_email' => 'ASFields@aol.com',
    'reply_to_email' => 'i-club-list@lists.better-investing.org',
    'subject' => 'NAIC: re: disney',
    'date_time' => 930813677,
},
<<'EOF'
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
    'content_type' => 'text/plain; charset="iso-8859-1"',
    'from_name' => 'Dan Hess',
    'from_email' => 'dan_hess@prodigy.net',
    'reply_to_email' => 'i-club-list@lists.better-investing.org',
    'subject' => undef,
    'date_time' => 930836015,
},
<<'EOF'
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
    'content_type' => 'text/plain; charset="us-ascii"',
    'from_name' => 'Dean Beeman',
    'from_email' => 'dbeeman@thegrid.net',
    'reply_to_email' => 'i-club-list@lists.better-investing.org',
    'subject' => '',
    'date_time' => 930841505,
},
<<'EOF'
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
    'content_type' => undef,
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
    'content_type' => 'text/plain; charset="iso-8859-1"',
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
Message-Id: <199912162220.PAA09081@mail.bivio.com>
From: Candis King <candis@enteract.com>
Subject: What resources are available to new investors?
MIME-Version: 1.0
To: ask_candis_publish@test.bivio.com
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
    'content_type' => 'text/html; charset=us-ascii',
    'from_name' => 'Candis King',
    'from_email' => 'candis@enteract.com',
    'reply_to_email' => undef,
    'subject' => 'What resources are available to new investors?',
    'date_time' => 945382838,
},
<<'EOF'
Return-Path: <lichtin@bivio.com>
Received: from bivio.com (pole.bivio.com [63.211.227.82])
	by pass.bivio.com (8.9.3/8.9.3) with ESMTP id TAA31340
	for <lichtin@mail.bivio.com>; Wed, 23 Feb 2000 19:41:19 -0700
Received: from pass.bivio.com (pass.bivio.com [207.174.140.78])
	by bivio.com (8.9.3/8.9.3) with ESMTP id TAA16867
	for <lichtin@bivio.com>; Wed, 23 Feb 2000 19:41:18 -0700
Received: from bivio.com (snow.bivio.com [207.174.140.70])
	by pass.bivio.com (8.9.3/8.9.3) with ESMTP id TAA31336
	for <lichtin@bivio.com>; Wed, 23 Feb 2000 19:41:18 -0700
Sender: lichtin@pass.bivio.com
Message-ID: <38B49A4E.816D35EE@bivio.com>
Date: Wed, 23 Feb 2000 19:41:18 -0700
From: Martin Lichtin <lichtin@bivio.com>
Organization: bivio, LLC (http://www.bivio.com/)
X-Mailer: Mozilla 4.7 [en] (X11; U; Linux 2.2.13 i686)
X-Accept-Language: en
MIME-Version: 1.0
To: lichtin@bivio.com
Subject: test
Content-Type: multipart/alternative;
 boundary="------------667D5053A61BE4F5D5795573"
Status:   
X-Mozilla-Status: 8001
X-Mozilla-Status2: 00000000
X-UIDL: 38a24a7e000008f9


--------------667D5053A61BE4F5D5795573
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

the alternative way...


--------------667D5053A61BE4F5D5795573
Content-Type: text/html; charset=us-ascii
Content-Transfer-Encoding: 7bit

<!doctype html public "-//w3c//dtd html 4.0 transitional//en">
<html>
the <b>alternative</b> way...
<br>&nbsp;</html>

--------------667D5053A61BE4F5D5795573--
EOF
=>
{
    'content_type' => 'multipart/alternative; boundary="------------667D5053A61BE4F5D5795573"',
    'from_name' => 'Martin Lichtin',
    'from_email' => 'lichtin@bivio.com',
    'reply_to_email' => undef,
    'subject' => 'test',
    'date_time' => 951360078,
},
<<'EOF'
Return-Path: <charles.reamer2@gte.net>
Received: from smtppop2.gte.net (smtppop2.gte.net [207.115.153.21])
	by bivio.com (8.9.3/8.9.3) with ESMTP id JAA23467
	for <jespi@bivio.com>; Thu, 10 Feb 2000 09:36:26 -0700
Received: from gte.net (1Cust94.tnt26.sfo3.da.uu.net [63.28.72.94])
	by smtppop2.gte.net  with SMTP
	for jespi@bivio.com; id KAA27342125
	Thu, 10 Feb 2000 10:36:16 -0600 (CST)
Date: Thu, 10 Feb 100 08:17:07 Pacific Daylight Time
From: CHARLES "CHUCK" REAMER <charles.reamer2@gte.net>
To: jespi <jespi@bivio.com>
Subject: RE: cleanlivin Investment Club Invitation
Message-ID: <0210100081707.5@oemcomputer>
MIME-Version: 1.0
X-Mail-Agent: An Internet Client 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit



      Thanks, Jim. I accept the invitaion. Let me know when and where
      the 200 dollars can be handled. Thanks!
EOF
=>
{
    'content_type' => 'text/plain; charset=us-ascii',
    'from_name' => 'CHARLES "CHUCK" REAMER',
    'from_email' => 'charles.reamer2@gte.net',
    'reply_to_email' => undef,
    'subject' => 'RE: cleanlivin Investment Club Invitation',
    'date_time' => 950170627,
},
'test1.msg'
=>
{
    'content_type' => 'multipart/alternative; boundary="------------87A9D47A93B91C50AC533AD4"',
    'from_name' => 'Martin Lichtin',
    'from_email' => 'lichtin@bivio.com',
    'reply_to_email' => undef,
    'subject' => 'test1',
    'date_time' => 951360953,
},
'test2.msg'
=>
{
    'content_type' => 'multipart/related; boundary="------------7B9F31415285B591C9F3EF36"',
    'from_name' => 'Martin Lichtin',
    'from_email' => 'lichtin@bivio.com',
    'reply_to_email' => undef,
    'subject' => 'test2',
    'date_time' => 951360195,
},
'test3.msg'
=>
{
    'content_type' => 'multipart/mixed; boundary="------------2B5CF8757B3C1198B2A8699C"',
    'from_name' => 'Martin Lichtin',
    'from_email' => 'lichtin@bivio.com',
    'reply_to_email' => undef,
    'subject' => 'test3',
    'date_time' => 951360227,
},
'test4.msg'
=>
{
    'content_type' => 'multipart/mixed; boundary="------------F385799F1182BDC18EA4C6E4"',
    'from_name' => 'Martin Lichtin',
    'from_email' => 'lichtin@bivio.com',
    'reply_to_email' => 'lichtin@cheerful.to',
    'subject' => 'test4',
    'date_time' => 951372715,
},
'test5.msg'
=>
{
    'content_type' => 'multipart/mixed; boundary="------------F385799F1182BDC18EA4C6E4"',
    'from_name' => 'Martin Lichtin',
    'from_email' => 'lichtin@bivio.com',
    'subject' => 'test5',
    'date_time' => 951372715,
},
'test6.msg'
=>
{
    'content_type' => 'multipart/mixed; boundary="------------F385799F1182BDC18EA4C6E4"',
    'from_name' => 'Martin Lichtin',
    'from_email' => 'lichtin@bivio.com',
    'subject' => 'test6',
    'date_time' => 951372715,
},
);

my($test) = 2;
my($msg, $fields, $id);
while (($msg, $fields) = each(%_MSGS)) {
    if ($msg =~ /^test/) {
        open(F, $msg) || die("$msg: $!");
        { local($/) = undef; $msg = <F>; }
        close(F);
    }
    my($bm) = Bivio::Mail::Message->new(\$msg);
    $id = $bm->get_field('message-id');
    print "Message-Id: $id\n";
    my($e, $n) = $bm->get_from;
    &assert_eq('from_email',  $e) || next;
    &assert_eq('from_name',  $n) || next;
    &assert_eq('reply_to_email', $bm->get_reply_to) || next;
    &assert_eq('subject', $bm->get_field('subject')) || next;
    &assert_eq('content_type', $bm->get_field('content-type')) || next;
    &assert_eq('date_time', $bm->get_date_time) || next;
    (undef, $fields->{body}) = split(/\n\n/, $msg, 2);
    my($entity) = $bm->get_entity;
    my($num_parts);
    $num_parts = $entity->parts;
    print "num_parts = $num_parts\n";
    ($num_parts || &assert_eq('body', $bm->get_entity->body_as_string)) || next;
    my($num_of_parts);
    $entity->dump_skeleton;
    print "ok $test\n";
}
continue {
    $test++;
}

sub assert_eq {
    my($f, $v) = @_;
    defined($fields->{$f}) == defined($v)
	    && (!defined($v) || $fields->{$f} eq $v) && return 1;
    $v = defined($v) ? $v : 'undef';
    my($exp) = defined($fields->{$f}) ? $fields->{$f} : 'undef';
    print "Exp len = ", length($exp), ", got len = ", length($v), "\n";
    print <<"EOF";
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

my($bm) = Bivio::Mail::Message->new(\$msg);
$bm->add_recipients(User::pwent::getpwuid($>)->name);
my(@r) = $bm->get_recipients;
$r[0] eq User::pwent::getpwuid($>)->name || die;
$bm->enqueue_send;
$bm->send_queued_messages;
print "ok $test\n";
$test++;
