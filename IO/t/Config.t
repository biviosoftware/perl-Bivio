# -*-perl-*-
#
# $Id$
#
use strict;

BEGIN { $| = 1; print "1..5\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
BEGIN {
    @ARGV = qw(
        --Bivio::IO::Config::t::T1.p4=p4
        --Bivio::IO::Config::t::T1.p5=p5
    );
}
use Bivio::IO::Config;
Bivio::IO::Config->introduce_values({
    'Bivio::IO::Config::t::T1' => {
	p1 => 'p1',
	p3 => 'p3',
        goodbye => {
	    p3 => 'gp3',
	    p4 => 'gp4',
        },
    },
});
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
    'p1' => Bivio::IO::Config->REQUIRED,
    'p2' => 'p2',
    Bivio::IO::Config->NAMED => {
       p3 => Bivio::IO::Config->REQUIRED,
       p4 => undef,
       p5 => 39
    },
});

my($c) = main::conf_get(undef);
main::dev_get('hello');
my($k);
foreach $k (qw(p3 p4 p5)) {
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
foreach $k (qw(p5)) {
    die("missing named $k") unless exists($c->{$k});
    die("bad $k, $c->{$k}") unless $c->{$k} eq $k;
}
foreach $k (qw(p1 p2)) {
    die("shouldn't be set named $k") if exists($c->{$k});
}

1;

# Test whether bconf is being read
package Bivio::IO::Alert;
sub handle_config {
    return;
}

Bivio::IO::Config->register({
    intercept_warn => 1,
    stack_trace_warn => -1,
    stack_trace_warn_deprecated => 0,
    max_arg_length => 99,
    want_stderr => 0,
    want_pid => 0,
    want_time => 0,
    max_warnings => 2000,
});

my($c2) = main::conf_get();
die('stack_trace_warn invalid') unless $c2->{stack_trace_warn} != -1;
1;
