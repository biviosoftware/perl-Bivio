#!perl -w
#
# $Id$
#
use strict;

BEGIN { $| = 1; print "1..2\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
use Bivio::Test;
use Bivio::t::Testee;
$loaded = 1;
print "ok 1\n";

my($_T) = 2;
t(
    {
    }, [
	'Bivio::t::Testee' => [
	    ok => undef,
	],
	Bivio::t::Testee->new('1') => [
	    ok => 1,
	    # Deviance; 3
	    ok => 2,
	    ok => [
		[1] => [1],
		# Deviance; 5
		[1] => [1, 2],
		[1, 2, 3] => [1, 2, 3],
		[] => [1],
		# Deviance: 8
		[] => [2],
		# Deviance: 9
		[3] => [2],
		[2] => [2],
		[1, 2, 3] => undef,
		[1, 2, 3] => [1],
	    ],
	],
	'Bivio::t::Testee' => [
	    die => [
		[] => Bivio::DieCode->DIE,
		# Deviance: 12
		[] => [],
	    ],
	    die => [
		[Bivio::DieCode->DB_CONSTRAINT]
		    => Bivio::DieCode->DB_CONSTRAINT,
	    ],
	],
	Bivio::t::Testee->new('1') => [
	    ok => [
		[1] => Bivio::DieCode->DIE,
	    ],
	],
    ],
    16,
    [3, 5, 8, 9, 12, 14, 16],
);


# t(hash_ref options, array_ref tests, int num_tests, array_ref not_ok)
#
# Creates a new test instance and runs $tests.  Expects $num_tests.
# $not_ok is a list of tests which should fail.
sub t {
    my($options, $tests, $num_tests, $not_ok) = @_;
    my($err) = '';
    my($start) = 1;
    my($die) = Bivio::Die->catch(sub {
	Bivio::Test->new({
	    print => sub {
		my($msg) = join('', @_);
		if ($start) {
		    $err .= "Incorrect test header: ".$msg
			if $msg ne "1..$num_tests\n";
		    $start = 0;
		}
		elsif ($msg =~ /^not ok (\d+)/s) {
		    my($n) = $1;
		    $err .= "Failed conformance: ".$msg
			unless grep($_ eq $n, @$not_ok);
		}
		elsif ($msg =~ /^ok (\d+)/) {
		    my($n) = $1;
		    $err .= "Failed deviance: ".$msg
			if grep($_ eq $n, @$not_ok);
		}
		else {
		    $err .= "Unexpected msg: ".$msg;
		}
		return;
	    },
	    %$options,
	})->unit($tests);
    });
    $err .= $die->as_string if $die;
    print !$err && !$start ? "ok ".$_T++."\n" : "not ok ".$_T++." ".$err;
}

