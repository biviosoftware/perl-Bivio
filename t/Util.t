# -*-perl-*-
#
# $Id$
#
use strict;

BEGIN { $| = 1; print "1..3\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
use Bivio::Util;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.


BEGIN {
    use Bivio::Util;
    package Bivio::Util::T;
    &Bivio::Util::compile_attribute_accessors([qw(one two)]);
    sub new ($) {bless({}, shift)}
    package main;
}

my($t) = Bivio::Util::T->new;
$t->set_one('1');
$t->set_two('2');
$t->one == 1 && $t->two == 2 || print "not ok\n";
print "ok 2\n";

BEGIN {
    use Bivio::Util;
    package Bivio::Util::T;
    &Bivio::Util::compile_attribute_accessors([
	['three', 'no_undef'],
	['four', 'no_set'],
	'five',
    ]);
    package main;
}

$t->set_five('5');
$t->{four} = 4;
!eval {$t->set_three(undef); 1;} && !eval {$t->set_four(1); 1;}
    && $t->set_three('3') && $t->one == 1 && $t->two == 2 && $t->three == 3
    && $t->four == 4 && $t->five == 5 || print "not ok 3\n";
print "ok 3\n";
