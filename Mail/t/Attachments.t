# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
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

use User::pwent ();

#my($_USER) = $ENV{LOGNAME} || $ENV{USER} || User::pwent::getpwuid($>)->name;
my($_USER) = 'nobody@example.com';

my($test) = 2;

my($m) = Bivio::Mail::Outgoing->new();
$m->set_recipients($_USER);
$m->set_content_type('multipart/alternative');
my($t) = 'abc';
my($h) = '<!doctype html public "-//w3c//dtd html 4.0 transitional//en"><html>bbc</html>';
$m->attach(\$t, 'text/plain');
$m->attach(\$h, 'text/html', 'text.html');
$m->send();
my($out) = $m->as_string;
print $out;
my($exp_out) = <<'EOF';
MIME-Version: 1.0
Content-Type: multipart/alternative;
 boundary="------------8169AB88A610572B963B8638"

This is a multi-part message in MIME format.
--------------8169AB88A610572B963B8638
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

abc

--------------8169AB88A610572B963B8638
Content-Type: text/html;
 name="text.html"
Content-Transfer-Encoding: 7bit

<!doctype html public "-//w3c//dtd html 4.0 transitional//en"><html>bbc</html>

--------------8169AB88A610572B963B8638--
EOF
print $out eq $exp_out ? '' : 'not ', "ok $test\n";

$test++;
my($vcf) = <<'EOF';
begin:vcard
n:User;Some
tel;fax:+1 (999) 555-1212
tel;work:+1 (303) 555 1212
x-mozilla-html:FALSE
url:http://bivio.biz
org:bivio Software Inc.
adr:;;1313 Mockingbird Lane;Boulder;CO;80304;
version:2.1
email;internet:cool-dude@example.com
title:CEO
fn:Some User
end:vcard
EOF
my($m2) = Bivio::Mail::Outgoing->new();
$m2->set_recipients($_USER);
$m2->set_content_type('multipart/mixed');
my($img);
{ local($/) = undef; open(F, 'img.gif'); $img = <F>; close(F); }
$m2->attach(\$img, 'image/gif', 'img.gif');
$m2->attach(\$vcf, 'text/x-vcard');
$m2->send();
print "ok $test\n";
$test++;
