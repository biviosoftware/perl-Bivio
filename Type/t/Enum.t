# -*-perl-*-
#
# $Id$
#
use strict;

BEGIN { $| = 1; print "1..3\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
use Bivio::Type::Enum;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

package Bivio::Type::Enum::T1;

use Bivio::Type::Enum;
@Bivio::Type::Enum::T1::ISA = qw(Bivio::Type::Enum);

__PACKAGE__->compile({
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
});

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
    $t1->from_string($e)->as_int == $i || last;
    $t1->$e()->as_string eq $e || last;
    $t1->$e()->get_short_desc eq lc($e) || last;
    $t1->$e()->get_long_desc eq "e $i" || last;
    $not_done--;
}
print $not_done ? "not ok 3\n" : "ok 3\n";

