# -*-perl-*-
#
# $Id$
#
use strict;

BEGIN { $| = 1; print "1..7\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
use Bivio::Type::Enum;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

package Bivio::Type::Enum::T1;

use Bivio::Type::Enum;
@Bivio::Type::Enum::T1::ISA = qw(Bivio::Type::Enum);

__PACKAGE__->compile(
    'E0' => [
    	0,
	'e0',
	'e 0',
    ],
    'E1' => [
    	1,
	'e1',
	'e 1',
    ],
    'E2' => [
    	2,
	'e2',
	'e 2',
    ],
);

1;

package Bivio::Type::Enum::T2;

use Bivio::Type::Enum;
@Bivio::Type::Enum::T2::ISA = qw(Bivio::Type::Enum);

__PACKAGE__->compile(
    'E_0' => [
    	0,
    ],
    'E_2' => [
    	2,
	'e two',
    ],
);

sub is_continuous { return 0; }

1;

package main;

my($t1) = Bivio::Type::Enum::T1->E0;
print $t1->min eq $t1->E0 && $t1->max eq $t1->E2
	? "ok 2\n" : "not ok 2\n";
my($i);
my($not_done) = 3;
foreach $i (0..2) {
    my($e) = 'E' . $i;
    $t1->from_int($i) eq $t1->$e() || last;
    $t1->from_any($e)->as_int == $i || last;
    $t1->$e()->as_string eq (ref($t1).'::'.$e) || last;
    $t1->$e()->get_short_desc eq lc($e) || last;
    $t1->$e()->get_long_desc eq "e $i" || last;
    $not_done--;
}
print $not_done ? "not ok 3\n" : "ok 3\n";
print int($t1->get_list()) == 3 ? "ok 4\n" : "not ok 4\n";

my($t2) = Bivio::Type::Enum::T2->E_0;
print $t2->min eq $t2->E_0 && $t2->max eq $t2->E_2
	? "ok 5\n" : "not ok 5\n";
$not_done = 2;
foreach $i (0, 2) {
    my($e) = 'E_' . $i;
    $t2->from_int($i) eq $t2->$e() || last;
    $t2->from_any($e)->as_int == $i || last;
    $t2->from_any($t2->from_any($e))->as_int == $i || last;
    $t2->$e()->as_string eq (ref($t2).'::'.$e) || last;
    $not_done--;
}
$t2->E_0->get_short_desc eq 'e 0' || ($not_done = -999999);
$t2->E_0->get_long_desc eq 'e 0' || ($not_done = -999999);
$t2->E_2->get_short_desc eq 'e two' || ($not_done = -999999);
$t2->E_2->get_long_desc eq 'e two' || ($not_done = -999999);
print $not_done ? "not ok 6\n" : "ok 6\n";
print int($t1->get_list()) == 3 ? "ok 7\n" : "not ok 7\n";
