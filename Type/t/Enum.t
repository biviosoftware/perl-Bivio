# -*-perl-*-
#
# $Id$
#
use strict;

BEGIN { $| = 1; print "1..20\n"; }
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

sub IS_CONTINUOUS { return 0; }

1;

package Bivio::Type::Enum::T3;

use Bivio::Type::Enum;
@Bivio::Type::Enum::T3::ISA = qw(Bivio::Type::Enum);

__PACKAGE__->compile(
    'E123456789' => [
    	-123456789,
    ],
);

1;

package main;

my($T) = 2;
sub t {
    print shift(@_) ? "ok $T\n" : ("not ok $T at line ", (caller)[2], "\n");
    $T++;
}

my($t1) = Bivio::Type::Enum::T1->E0;
t($t1->MIN == $t1->E0 && $t1->MAX == $t1->E2);
t($t1->CAN_BE_ZERO && $t1->CAN_BE_POSITIVE && !$t1->CAN_BE_NEGATIVE);
t($t1->WIDTH == 2);
t($t1->PRECISION == 1);

my($i);
my($not_done) = 3;
foreach $i (0..2) {
    my($e) = 'E' . $i;
    $t1->from_int($i) == $t1->$e() || last;
    $t1->from_any($e)->as_int == $i || last;
    $t1->$e()->as_string eq (ref($t1).'::'.$e) || last;
    $t1->$e()->get_short_desc eq lc($e) || last;
    $t1->$e()->get_long_desc eq "e $i" || last;
    $not_done--;
}
t(!$not_done);
t(int(@{[$t1->LIST]}) == 3);

my($t2) = Bivio::Type::Enum::T2->E_0;
t($t2->MIN eq $t2->E_0 && $t2->MAX eq $t2->E_2);
t($t2->CAN_BE_ZERO && $t2->CAN_BE_POSITIVE && !$t2->CAN_BE_NEGATIVE);
t($t2->WIDTH == 3);
t($t2->PRECISION == 1);

$not_done = 2;
foreach $i (0, 2) {
    my($e) = 'E_' . $i;
    $t2->from_int($i) eq $t2->$e() || last;
    $t2->from_any($e)->as_int == $i || last;
    $t2->from_any($t2->from_any($e))->as_int == $i || last;
    $t2->$e()->as_string eq (ref($t2).'::'.$e) || last;
    $not_done--;
}
t(!$not_done);
t($t2->E_0->get_short_desc eq 'E 0');
t($t2->E_0->get_long_desc eq 'E 0');
t($t2->E_2->get_short_desc eq 'e two');
t($t2->E_2->get_long_desc eq 'e two');
t(int(@{[$t1->LIST]}) == 3);

my($t3) = Bivio::Type::Enum::T3->E123456789;
t(!$t3->CAN_BE_ZERO && $t3->CAN_BE_NEGATIVE && !$t3->CAN_BE_POSITIVE);
t($t3->WIDTH == 10);
t($t3->PRECISION == 9);
