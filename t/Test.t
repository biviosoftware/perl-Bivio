#!perl -w
#
# $Id$
#
use strict;

BEGIN { $| = 1; print "1..4\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
use Bivio::Test;
use Bivio::t::Test::Testee;
$loaded = 1;
print "ok 1\n";

my($_OBJECT);
my($_T) = 2;
t(
    {
    }, [
	'Bivio::t::Test::Testee' => [
	    ok => undef,
	],
	Bivio::t::Test::Testee->new('1') => [
	    ok => 1,
	    # Deviance; 3
	    ok => 2,
	    ok => [
		[1] => [1],
		# Deviance: 5
		[1] => [1, 2],
		[1, 2, 3] => [1, 2, 3],
		[] => [1],
		# Deviance: 8
		[] => [2],
		# Deviance: 9
		[3] => [2],
		[2] => [2],
		[1, 2, 3] => undef,
		# Deviance: 12
		[1, 2, 3] => [1],
	    ],
	],
	'Bivio::t::Test::Testee' => [
	    die => [
		[] => Bivio::DieCode->DIE,
		# Deviance: 14
		[] => [],
	    ],
	    die => [
		[Bivio::DieCode->DB_CONSTRAINT]
		    => Bivio::DieCode->DB_CONSTRAINT,
	    ],
	],
	Bivio::t::Test::Testee->new('1') => [
	    ok => [
		# Deviance: 16
		[1] => Bivio::DieCode->DIE,
	    ],
	],
	Bivio::t::Test::Testee->new('3') => [
	    ok => [
		# Conformance: 17
		[3] => sub {
		    my($case, $return) = @_;
		    return $return->[0] == 3 ? 1 : 0;
		},
		sub {[3, 4, 5]} => sub {[3, 4, 5]},
		# Deviance: 19
		[1] => sub {Bivio::DieCode->DIE},
		sub {
		    my($case) = @_;
		    $case->expect([999, 999]);
		    return [@{$case->get('expect')}];
		} => Bivio::DieCode->DIE,
	    ],
	    die => [
		# Conformance: 21
		sub {
		    my($case) = @_;
		    $case->expect(Bivio::DieCode->DIE);
		    return [];
		} => [],
	    ],
	    ok => qr/\[.*3.*\]/s,
	    ok => 3,
	    # Deviance: 24
	    ok => sub {
		return 3;
	    },
	    # Deviance: 25
	    ok => sub {
		my($case, $return) = @_;
		$case->expect(['99']);
		return ['99'];
	    },
	    ok => sub {
		my($case, $return) = @_;
		$case->actual_return(['99']);
		return ['99'];
	    },
	    # Deviance: 27
	    die => sub {
		my($case, $return) = @_;
		return Bivio::DieCode->DIE;
	    },
	    # Deviance: 28
	    ok => sub {
		my($case, $return) = @_;
		return '3';
	    },
	    {
		method => 'die',
		compute_params => sub {
		    return 3;
		},
		check_die_code => sub {
		    my($case, $die, $expect) = @_;
		    return 0 unless ref($die) eq 'Bivio::Die'
			&& ref($expect) eq 'Bivio::DieCode';
		    return $expect;
	        },
	    } => [
		sub {['CLIENT_ERROR']} => Bivio::DieCode->CLIENT_ERROR,
	    ],
	],
	{
	    object => '3',
	    create_object => sub {
		my($case, $object) = @_;
		return Bivio::t::Test::Testee->new(@$object),
	    },
	} => [
	    ok => [
		# Conformance: 30
		[] => sub {
		    $_OBJECT = shift->get('object');
		    return [3];
		},
		[] => sub {
		    my($case) = @_;
		    # Objects should be the same
		    $case->actual_return([shift->get('object')]);
		    return [$_OBJECT];
		},
	    ],
	],
	sub {
	    return Bivio::t::Test::Testee->new(5);
        } => [
	    ok => [
		# Conformance: 32
		[] => sub {
		    # Objects should be diffferent
		    return 0 if $_OBJECT eq shift->get('object');
		    return [5];
		},
	    ],
        ],
	{
	    object => Bivio::t::Test::Testee->new('33'),
	    check_return => sub {
		my($case, $actual, $expect) = @_;
		$case->actual_return(['hello']);
		return $expect;
	    },
	    check_die_code => sub {Bivio::DieCode->DIE},
        } => [
	    # Conformance: 33
	    ok => sub {
		return qr/\[.*33.*\]/s;
	    },
	    ok => [
		[] => ['hello'],
	    ],
	    ok => sub {[33]},
	    ok => qr/hello/,
	    # Deviance: 37
	    ok => qr/no-found/,
	    die => [
		[] => Bivio::DieCode->NOT_FOUND,
	    ],
	    {
		method => 'die',
		check_die_code => sub {1},
	    } => [
		[] => Bivio::DieCode->DIE,
	    ],
	],
	Bivio::t::Test::Testee->new('33') => [
	    # Deviance: 40
	    ok => qr/not-found/,
	    # Deviance: 41
	    ok => sub {undef},
	    # Deviance: 42
	    ok => sub {2},
	    # Deviance: 43
	    {
		method => 'die',
		check_die_code => sub {undef},
	    } => [
		[] => Bivio::DieCode->DIE,
	    ],
	    # Deviance: 44
	    {
		method => 'die',
		check_die_code => sub {2},
	    } => [
		[] => Bivio::DieCode->DIE,
	    ],
	    die => Bivio::DieCode->DIE,

	    # Conformance: 46
	    {
		want_scalar => 1,
		method => 'want_scalar',
	    } => [
		9 => 1,
		[1, 2, 3] => 3,
	    ],
	    map({
		{
		    $_ ? (want_scalar => 0) : (),
		    method => 'want_scalar',
		} => [
		    9 => 9,
		    [1, 2, 3] => [1, 2, 3],
		];
	    } 0, 1),
	],
	{
	    object => Bivio::t::Test::Testee->new('33'),
	    check_return => sub {
		return 1;
	    },
        } => [
	    # Deviance 52
	    ok => [
		99 => Bivio::DieCode->DIE,
	    ],
	],
	{
	    object => Bivio::t::Test::Testee->new('33'),
	    check_die_code => sub {
		return 1;
	    },
        } => [
	    # Deviance 53
	    die => '33',
	],
	{
	    object => Bivio::t::Test::Testee->new('33'),
	    check_return => sub {
		return 1;
	    },
	    check_die_code => sub {
		return 1;
	    },
        } => [
	    # Deviance 54
	    die => 1,
	    # Deviance 55
	    ok => Bivio::DieCode->DIE,
	],
#TODO: Need more deviance tests
    ],
    55,
    [3, 5, 8, 9, 12, 14, 16, 19, 24, 25, 27, 28, 37, 40, 41, 42, 43, 44, 52, 53, 54, 55],
);
t(
    {
	create_object => sub {
	    my($case, $params) = @_;
	    return Bivio::t::Test::Testee->new(@$params);
	},
    }, [
	3 => [
	    ok => 3,
	],
	sub {
	    return Bivio::t::Test::Testee->new(5);
        } => [
	    ok => 5,
        ],
    ],
    2,
    [],
);
t(
    {
	class_name => 'Bivio::t::Test::Testee',
    }, [
	66 => [
	    ok => 66,
	],
	sub {
	    return Bivio::t::Test::Testee->new(77);
        } => [
	    ok => 77,
	],
	{
	    create_object => sub {
		my($case, $params) = @_;
		die($params, ': expected 99 as object')
		    unless $params->[0] == 99;
		return Bivio::t::Test::Testee->new(88);
	    },
	    object => 99,
	} => [
	    ok => 88,
	],
	{
	    class_name => 'No::Such::ClassName',
	    object => 99,
	} => [
	    ok => 88,
        ],
    ],
    4,
    [4],
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
		elsif ($msg =~ /FAILED (\d+).*passed (\d+)/i) {
		    $err .= "incorrect counts: $msg"
			unless $1 == @$not_ok && $1 + $2 == $num_tests;
		}
		elsif ($msg =~ /All \((\d+)\) tests PASSED/i) {
		    $err .= "incorrect counts: $msg"
			unless $1 == $num_tests && !@$not_ok;
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

