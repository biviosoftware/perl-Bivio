# -*-perl-*-
#
# $Id$
#
use strict;

BEGIN { $| = 1; print "1..3\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
use Bivio::Mail::Outgoing;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

use Bivio::Mail::Incoming;
use User::pwent ();

my($_USER) = $ENV{LOGNAME} || $ENV{USER} || User::pwent::getpwuid($>)->name;

Bivio::IO::Config->initialize(\@ARGV);

my($_IN) = <<'EOF';
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
Subject: This is my subject
Reply-To: "NAIC I-Club-List" <i-club-list@lists.better-investing.org>
Sender: owner-naic@bivio.com
Precedence: bulk
Return-Receipt-To: nagler@acm.org

Okay Joe I give up.  I grew up near Philadelphia (Bucks County) a long time
ago and I never heard of Ithan.  Where is it located?
Dan Hess
EOF

my($_OUT) = <<"EOF";
Date: Thu, 1 Jul 1999 09:33:35 -0400
From: "Dan Hess" <dan_hess\@prodigy.net>
Subject: $_USER: This is my subject
Sender: owner-$_USER
To: "My Fancy List" <$_USER>
Reply-To: "My Fancy List" <$_USER>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
List-Unsubscribe: <mailto:leave-i-club-list-14220S\@lists.better-investing.org>
Precedence: bulk
X-Mimeole: Produced By Microsoft MimeOLE V4.72.3110.3
X-MSMail-Priority: Normal
X-Priority: 3

Okay Joe I give up.  I grew up near Philadelphia (Bucks County) a long time
ago and I never heard of Ithan.  Where is it located?
Dan Hess
EOF

my($test) = 2;
my($bmo) = Bivio::Mail::Outgoing->new(Bivio::Mail::Incoming->new(\$_IN));
$bmo->set_headers_for_list_send($_USER, 'My Fancy List', 1, 1);
$bmo->set_recipients($_USER);
print STDERR "\nYou should be receiving two identical mail messages\n";
$bmo->send();
$bmo->enqueue_send();
$bmo->send_queued_messages();
print $bmo->as_string eq $_OUT ? "ok $test\n" : "not ok $test\n";
$test++;

my($body) = 'what a body';
$bmo->set_body(\$body);
my($out) = $_OUT;
$out =~ s/\n\n.*/\n\n/s;
$out .= $body;
$bmo->send();
print $bmo->as_string eq $out ? "ok $test\n" : "not ok $test\n";
$test++;

#
# Test support for attachments
#

my($m) = Bivio::Mail::Outgoing->new(Bivio::Mail::Incoming->new(\$_IN));
$m->set_content_type('multipart/alternative');
$m->attach({ content_type => 'text/plain', content => 'abc' });
$m->attach({ content_type => 'text/html',
	       content => '<!doctype html public "-//w3c//dtd html 4.0 transitional//en"><html>abc</html>' });
print $m->as_string;
