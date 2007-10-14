# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# -*-perl-*-
#
# $Id$
#
use strict;

BEGIN {
    $| = 1;
    print "1..11\n";
}
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
BEGIN {
    use Cwd ();
    $ENV{BCONF} = Cwd::getcwd() . '/Config/t1.bconf';
    @ARGV = qw(
        --Bivio::IO::Config::t::T1.p4=p4
        --Bivio::IO::Config::t::T1.p5=p5
    );
}
use Bivio::IO::Config;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

my($T) = 1;
sub dev_get {
    ++$T;
    my($caller) = caller;
    print eval "
        package $caller;
	Bivio::IO::Config->get(\@_);
	1;
    " ? "$@not ok $T\n" : "ok $T\n";
    return;
}

sub conf_get {
    ++$T;
    my($caller) = caller;
    my($res) = eval "
        package $caller;
	Bivio::IO::Config->get(\@_);
    ";
    print $res ? "ok $T\n" : "$@not ok $T\n";
    return $res;
}

package Bivio::IO::Config::t::T1;
my($_CFG);
sub handle_config {
    shift;
    $_CFG = shift;
    return;
}
Bivio::IO::Config->register({
    p1 => Bivio::IO::Config->REQUIRED,
    p1_1 => -1,
    p2 => 'p2',
    p2_2 => -1,
    Bivio::IO::Config->NAMED => {
       p3 => Bivio::IO::Config->REQUIRED,
       p4 => undef,
       p5 => 39,
       p6 => 'p6',
    },
});

my($c) = main::conf_get(undef);
main::dev_get('hello');
my($k);
foreach $k (qw(p3 p4 p5 p6)) {
    die("missing named $k") unless exists($c->{$k});
    die("bad $k, $c->{$k}") unless $c->{$k} eq $k;
}
foreach $k (qw(p1 p2)) {
    die("shouldn't be set named $k") if exists($c->{$k});
}
foreach $k (qw(p1 p2)) {
    die("missing $k") unless exists($_CFG->{$k});
    die("bad $k, $_CFG->{$k}") unless $_CFG->{$k} eq $k;
}
$c = main::conf_get('goodbye');

foreach $k (qw(p3 p4)) {
    die("missing named $k") unless exists($c->{$k});
    die("bad $k, $c->{$k}") unless $c->{$k} eq 'g'.$k;
}
foreach $k (qw(p5 p6)) {
    die("missing named $k") unless exists($c->{$k});
    die("bad $k, $c->{$k}") unless $c->{$k} eq $k;
}
foreach $k (qw(p1 p2)) {
    die("shouldn't be set named $k") if exists($c->{$k});
}

Bivio::IO::Config->introduce_values({
    'Bivio::IO::Config::t::T1' => {
	p1 => 999,
	freddy => {
	    p3 => 777,
	},
    },
});

foreach my $x (
    [p1 => 999],
    [[qw(freddy p3)] => 777],
    [p1_1 => 1],
    [p2_2 => 2],
    ['Bivio::IO::Config::t::T1.p2_2' => 2],
) {
    my($name, $expect) = @$x;
    my($a, $b) = ref($name) ? @$name : $name;
    my($actual) = main::conf_get($a);
    $actual = $actual->{$b}
	if $b;
    die($actual, ": $a not $expect")
	unless $actual == $expect;
}

my($actual) = main::conf_get('Bivio::IO::Config::t::T1');
die($actual, ': unexpected config')
    unless $actual->{p1} eq 999;
$T++;
print Bivio::IO::Config->if_version(1, sub {1}, sub {0}) == 0
    ? "ok $T\n" : "$@not ok $T\n";

1;
