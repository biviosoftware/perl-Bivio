# -*-perl-*-
#
# $Id$
#
use strict;

BEGIN { $| = 1; print "1..5\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
use Bivio::UI::Widget;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

my($w1) = Bivio::UI::Widget->new({
    1 => '1',
    2 => '2',
   });
my($w2) = Bivio::UI::Widget->new({
    1 => '1.2',
    parent => $w1,
   });

my($_TEST_NUM) = 1;
sub conf {
    my($res) = @_;
    print $res ? "ok $_TEST_NUM\n" : "not ok $_TEST_NUM\n";
    $_TEST_NUM++;
}

sub dev {
    my($res) = @_;
    conf(!$res);
}

conf($w1->get('1') eq '1');
conf($w1->get('2') eq '2');
conf($w2->get('1') eq '1.2');
conf($w2->get('2') eq '2');
conf("@{[$w1->get('1', '2')]}" eq '1 2');
conf("@{[$w2->get('1', '2')]}" eq '1.2 2');

dev(eval {
    my($v1, $v2) = $w1->get('not found', '1');
    1;
});
my($v1, $v2) = $w1->unsafe_get('not found', '1');
conf(!defined($v1) && $v2 eq '1');
