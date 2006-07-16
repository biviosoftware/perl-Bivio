# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# -*-perl-*-
#
# $Id$
#
use strict;

BEGIN { $| = 1; print "1..7\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
use Bivio::Die;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

use Bivio::IO::Config;

package Bivio::Die::T1;

my($warn_count) = 0;

sub handle_die {
    my($self, $die) = @_;
    if ($die->as_string =~ /TOO MANY WARNINGS/) {
	foreach my $x (1..$warn_count) {
	    Bivio::IO::Alert->warn("test warn $x");
	}
	return;
    }
    $self eq 'Bivio::Die::T1' || die("huh?");
    $main::T1++;
    $die->as_string =~ /test 2/ && die('DEATH_TAG');
    return;
}

sub sub_die {
    shift;
    die(@_);
}

sub sub {
    my($proto, @args) = @_;
    $proto->sub_die(@args);
}

sub warn_test {
    my(undef, $wc, $op) = @_;
    $warn_count = $wc;
    $op->();
    return;
}

package Bivio::Die::T2;

sub handle_die {
    my($self, $die) = @_;
    $self eq 'Bivio::Die::T2' || die("huh?");
    $die->as_string =~ /DEATH_TAG/ && $main::T2++;
    $main::T2++;
    return;
}

sub sub {
    shift;
    return Bivio::Die::T1->sub(@_);
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

my($die) = Bivio::Die->catch('
use strict;
this routine should not be found;
');
print $die && $die->get('code')->equals_by_name('DIE') ? "ok 4\n" : "not ok 4\n";

use HTML::Parser;
$die = Bivio::Die->catch(<<'EOF');
HTML::Parser->new(
    api_version => 3,
    text_h => [sub {die('dead')}]
)->parse('<html>x</html>');
EOF
print $die && $die->get('code')->equals_by_name('DIE') ? "ok 5\n" : "not ok 5\n";

Bivio::IO::Config->introduce_values({
    'Bivio::IO::Alert' => {
	max_warnings => 1,
    }
});
my($t) = 6;
foreach my $warn_count (2, 10) {
    Bivio::IO::Alert->reset_warn_counter;
    $die = Bivio::Die->catch(sub {
        Bivio::Die::T1->warn_test(
	    $warn_count,
	    sub {
		Bivio::IO::Alert->warn('warn ok');
		Bivio::IO::Alert->warn('warn dies');
		# DOES NOT RETURN
	    },
	);
    });
    print(($t == 6 ? $die && !$die->unsafe_get('next')
        : $die && $die->unsafe_get('next')
	&& $die->get_nested(qw(next code))->eq_die_within_handle_die)
        ? "ok $t\n" : "not ok $t\n");
    $t++;
}
