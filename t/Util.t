# -*-perl-*-
#
# $Id$
#
use strict;

BEGIN { $| = 1; print "1..6\n"; }
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
print $t->one == 1 && $t->two == 2 ? "ok 2\n" : "not ok 2\n";

BEGIN {
    use Bivio::Util;
    package Bivio::Util::T;
    &Bivio::Util::compile_attribute_accessors(['three'], 'no_undef');
    &Bivio::Util::compile_attribute_accessors(['four'], 'no_set');
    package main;
}

$t->{four} = 4;
print !eval {$t->set_three(undef); 1;} && !eval {$t->set_four(1); 1;}
    && $t->set_three('3') && $t->one == 1 && $t->two == 2 && $t->three == 3
    && $t->four == 4 ? "ok 3\n" : "not ok 3\n";

################################################################
#
#
print "Testing time_delta_in_seconds which requires a sleep of 1 second\n";
my($start_time) = &Bivio::Util::gettimeofday;
sleep(1);
my($secs) = &Bivio::Util::time_delta_in_seconds($start_time);
print $secs > 0.9 && $secs < 2.0 ? "ok 4\n" : "not ok 4\n";

Bivio::Util::my_require(__PACKAGE__);
print eval {
    Bivio::Util::my_require('Some::Random::Package');
    1;
} ? "not ok 5\n" : "ok 5\n";
print eval {
    Bivio::Util::my_require('Bivio::Type');
    1;
} ? "ok 6\n" : "not ok 6\n$@\n";
