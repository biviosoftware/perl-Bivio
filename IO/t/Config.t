# -*-perl-*-
#
# $Id$
#
use strict;

BEGIN { $| = 1; print "1..10\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
use Bivio::IO::Config;
use Bivio::IO::Alert;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

my($T) = 1;
sub dev_init {
    ++$T;
    print eval {
	Bivio::IO::Config->initialize(@_);
	1;
    } ? "not ok $T\n" : "ok $T\n";
}

sub conf_init {
    ++$T;
    print eval {
	Bivio::IO::Config->initialize(@_);
	1;
    } ? "ok $T\n" : "not ok $T\n";
}

sub dev_get {
    ++$T;
    my($caller) = caller;
    print eval "
        package $caller;
	Bivio::IO::Config->get(\@_);
	1;
    " ? "$@not ok $T\n" : "ok $T\n";
}

sub conf_get {
    ++$T;
    my($caller) = caller;
    print eval "
        package $caller;
	Bivio::IO::Config->get(\@_);
	1;
    " ? "ok $T\n" : "$@not ok $T\n";
}

package Bivio::IO::Config::T1;
sub handle_config {}
Bivio::IO::Config->register({
    'p1' => Bivio::IO::Config->REQUIRED,
    'p2' => 'p2',
    Bivio::IO::Config->NAMED => {
       p3 => Bivio::IO::Config->REQUIRED,
       p4 => undef,
       p5 => 39
    }
});

&main::dev_init({});
&main::conf_init({
    'Bivio::IO::Config::T1' => {
	'p1' => 'p1',
    }
});
&main::conf_get();
&main::dev_get('hello');
&main::dev_get(undef);
&main::conf_init({
    'Bivio::IO::Config::T1' => {
	'p1' => 'p1',
	'p3' => 'p3',
    }
});
&main::conf_get(undef);
my($c) = Bivio::IO::Config->get(undef);
my($k);
foreach $k (qw(p3 p4 p5)) {
    exists($c->{$k}) || die("missing $k");
}
foreach $k (qw(p1 p2)) {
    exists($c->{$k}) && die("shouldn't be set $k");
}

open(OUT, '> ' . ($ENV{BIVIO_CONF} = "bivio.conf$$")) || die("open: $!");
print OUT <<'EOF';
{
    'Bivio::IO::Config::T1' => {
	'p1' => 'p1',
	'p3' => 'p3',
    },
}
EOF
close(OUT) || die("close: $!");
my(@argv) = qw(
    --Bivio::IO::Config::T1.p2=p2
    --Bivio::IO::Config::T1.p4=p4
    --Bivio::IO::Config::T1.p5=p5
);
&main::conf_init(\@argv);
unlink($ENV{BIVIO_CONF});
&main::conf_get(undef);
$c = Bivio::IO::Config->get(undef);
foreach $k (qw(p3 p4 p5)) {
    $c->{$k} ne $k && die("missing or invalid $k");
}
$c = Bivio::IO::Config->get();
foreach $k (qw(p1 p2)) {
    $c->{$k} ne $k && die("missing or invalid $k");
}
