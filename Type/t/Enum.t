# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# -*-perl-*-
#
# $Id$
#
use strict;
BEGIN { $| = 1; print "1..41\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
use Bivio::Type::Enum;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

package Bivio::Type::Enum::T1;

use Bivio::Type::Enum;
@Bivio::Type::Enum::T1::ISA = qw(Bivio::Type::Enum);

__PACKAGE__->compile([
    E0 => [
    	0,
	'e0',
	'e 0',
    ],
    E1 => [
    	1,
	'e1',
	'e 1',
    ],
    E2 => [
    	2,
	'e2',
	'e 2',
    ],
]);

1;

package Bivio::Type::Enum::T2;

use Bivio::Type::Enum;
@Bivio::Type::Enum::T2::ISA = qw(Bivio::Type::Enum);

__PACKAGE__->compile([
    E_0 => 0,
    E_2 => [
    	2,
	'e two',
    ],
    SOME_ENUM => [
    	3,
    ],
]);

sub is_continuous { return 0; }

1;

package Bivio::Type::Enum::T3;

use Bivio::Type::Enum;
@Bivio::Type::Enum::T3::ISA = qw(Bivio::Type::Enum);

__PACKAGE__->compile([
    'E123456789' => [
    	-123456789,
    ],
]);

1;

package main;

my($T) = 2;
sub t {
    print shift(@_) ? "ok $T\n" : ("not ok $T at line ", (caller)[2], "\n");
    $T++;
}

my($t1) = Bivio::Type::Enum::T1->E0;
t($t1->get_min == $t1->E0 && $t1->get_max == $t1->E2);
t($t1->can_be_zero && $t1->can_be_positive && !$t1->can_be_negative);
t($t1->get_width == 2);
t($t1->get_width_long_desc == 3);
t($t1->get_width_short_desc == 2);
t($t1->get_precision == 1);

my($i);
my($not_done) = 3;
foreach $i (0..2) {
    my($e) = 'E' . $i;
    $t1->from_int($i) == $t1->$e() || last;
    $t1->from_any($e)->as_int == $i || last;
    $t1->from_literal_or_die($e)->as_int == $i || last;
    $t1->from_literal_or_die($t1->from_name($e))->as_int == $i || last;
    $t1->from_literal_or_die($i)->as_int == $i || last;
    $t1->$e()->as_string eq (ref($t1).'::'.$e) || last;
    $t1->$e()->get_short_desc eq lc($e) || last;
    $t1->$e()->get_long_desc eq "e $i" || last;
    $not_done--;
}
t($t1->E0->equals_by_name('E0') == 1);
t($t1->E1->equals_by_name('E0') == 0);
t($t1->E1->equals_by_name('E2', 'E1') == 1);
t(!$not_done);
t(int(@{[$t1->get_list]}) == 3);
t(int(@{[$t1->get_non_zero_list]}) == 2);

t($t1->from_name('E0'));
t($t1->from_name('e0'));
t(!eval {$t1->from_name(0)});
t(!eval {$t1->from_name('e 0')});

my($t2) = Bivio::Type::Enum::T2->E_0;
t($t2->get_min eq $t2->E_0 && $t2->get_max eq $t2->SOME_ENUM);
t($t2->can_be_zero && $t2->can_be_positive && !$t2->can_be_negative);
t($t2->get_width == 9);
t($t2->get_precision == 1);

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
t($t2->SOME_ENUM->get_short_desc eq 'Some Enum');
t($t2->E_2->get_long_desc eq 'e two');
t(int(@{[$t1->get_list]}) == 3);

my($t3) = Bivio::Type::Enum::T3->E123456789;
t(!$t3->can_be_zero && $t3->can_be_negative && !$t3->can_be_positive);
t($t3->get_width == 10);
t($t3->get_precision == 9);

use Bivio::Test::Request;
my($req) = Bivio::Test::Request->get_instance;
t(!$req->has_keys('Type.T3'));
t($t3->execute($req) == 0);
t($req->get('Type.T3') == $t3);
t($req->get('Bivio::Type::Enum::T3') == $t3);
$req->clear_nondurable_state;
t(!$req->has_keys('Type.T3'));
t($t3->execute($req, 1) == 0);
$req->clear_nondurable_state;
t($req->get('Type.T3') == $t3);
t($t1->E0->eq_e0 == 1);
t($t1->E0->eq_e1 == 0);
t($t1->is_valid_name == 0);
