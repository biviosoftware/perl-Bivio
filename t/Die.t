# -*-perl-*-
#
# $Id$
#
use strict;

BEGIN { $| = 1; print "1..3\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
use Bivio::Die;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

use Bivio::IO::Config;
Bivio::IO::Config->initialize(\@ARGV);

package Bivio::Die::T1;

sub handle_die {
    my($self, $die) = @_;
    $self eq 'Bivio::Die::T1' || die("huh?");
    $main::T1++;
    grep(/test 2/, $die->as_string) && die('DEATH_TAG');
}

sub sub_die {
    shift;
    die(@_);
}

sub sub {
    my($proto, @args) = @_;
    $proto->sub_die(@args);
}

package Bivio::Die::T2;

sub handle_die {
    my($self, $die) = @_;
    $self eq 'Bivio::Die::T2' || die("huh?");
    grep(/DEATH_TAG/, $die->as_string) && $main::T2++;
    $main::T2++;
}

sub sub {
    shift;
    Bivio::Die::T1->sub(@_);
}

package main;

my($MAIN) = 0;
sub handle_die {
    # This routine should never be called.
    $MAIN++;
}

Bivio::Die->catch(sub {
    Bivio::Die::T2->sub('test 1');
});
print $MAIN == 0 && $main::T1 == 1 && $main::T2 == 1 ? "ok 2\n" : "not ok 2\n";

$MAIN = $main::T1 = $main::T2 = 0;
Bivio::Die->catch(sub {
    Bivio::Die::T2->sub('test 2');
});
print $MAIN == 0 && $main::T1 == 1 && $main::T2 == 2 ? "ok 3\n" : "not ok 3\n";
