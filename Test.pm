# Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.
# $Id$
package Bivio::Test;
use strict;
$Bivio::Test::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::VERSION;

=head1 NAME

Bivio::Test - support for declarative testing

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Test;

=cut

use Bivio::UNIVERSAL;
@Bivio::Test::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Test> supports declarative testing.  A declarative test allows you to
define what you want to test very succinctly.  Here's an example:

    #!perl -w
    use strict;
    use Bivio::TypeError;
    use Bivio::Type::Integer;
    Bivio::Test->unit([
        Bivio::Type::Integer => [
            from_literal => [
	        [1] => [1],
	        [x] => [undef, Bivio::TypeError->INTEGER],
            ],
        ],
    ]);

The first argument to L<unit|"unit"> is a list of object groups.  An object
group is tuple of the object (class or instance) and a list of method groups.
A method group is a tuple of the method name followed by a list of test cases.
Each test case is a tuple of a list of parameter(s) and a return value.

If there is no return value, specify C<[undef]>.  That's what the method should
return if it doesn't return anything.  perl methods return C<undef> implicitly
if the last statement they execute is C<return;>.  We recommend you always end
your methods in a C<return> statement to avoid unexpected return values being
used.  perl by default returns the value of the last statement executed.  This
can have serious side-effects unless one is careful.

To ignore the return result, specify C<undef> (as a scalar, not wrapped in an
array_ref), i.e. the test case tuple should only include the parameter(s).
Here's an example:

    do_something => [
        [1, 2, 3] => undef,
    ],

The result of the call to the method C<do_something> will not be checked.

If the expected return value is an array_ref, it will be compared with the
actual return value.  If the result is an array_ref, you'll need to wrap
it one more time in an array_ref, e.g.

    make_array_ref => [
        [1, 2, 3] => [[1, 2, 3]],
    ]

Here C<make_array_ref> is a routine to test which returns an array_ref of
its arguments.

If the expected (declared) return value is an unblessed code_ref (subroutine)
specified as a simple value, it will be executed to evaluate the return result.
See L<result_ok|"result_ok"> for a description of this interface.

If the expected (declared) return value is a L<Bivio::DieCode|Bivio::DieCode>,
an exception will be expected.

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::Die;
use Bivio::DieCode;
use Bivio::IO::ClassLoader;


#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="result_ok"></a>

=head2 abstract sub result_ok(any proto, string method, array_ref params, array_ref result) : boolean

=head2 abstract sub result_ok(any proto, string method, array_ref params, Bivio::Die die) : boolean

I<proto> is the instance or class which was executed.  I<method> was called
with I<params>.  The result is either a I<die> (get I<die.code> for the
exception) or I<result>.

The sub returns true if the test passed, i.e. I<die> or I<result> was
as expected.

B<Called as a I<sub>, not a method>.

=cut

$_ = <<'}'; # emacs
sub result_ok {
}

=for html <a name="unit"></a>

=head2 unit(array_ref tests)

Evaluates I<tests> which are defined as tuples of tuples of tuples.
see L<DESCRIPTION|"DESCRIPTION"> for the syntax.

The tests are suitable for processing by C<Test::Harness>, a standard CPAN
module.  See also L<Bivio::Util::Test|Bivio::Util::Test> which is a
front-end to C<Test::Harness>.

=cut

sub unit {
    my($proto, $tests) = @_;
    # Compile blows up.  May want to "catch" and print result as opposed
    # to dying.
    _unit_eval(_unit_compile($tests));
    return;
}

#=PRIVATE METHODS

# _assert_array(any value, string name)
#
# Asserts value is an array_ref.
#
sub _assert_array {
    my($value, $name) = @_;
    _die($name, ': must be an array_ref')
	unless ref($value) eq 'ARRAY';
    return;
}

# _assert_even(any value, string name)
#
# Asserts value is an even length array_ref.
#
sub _assert_even {
    my($value, $name) = @_;
    _assert_array($value, $name);
    _die($name, ': uneven elements in array')
	unless int(@$value) % 2 == 0;
    _die($name, ': no elements in array')
	unless int(@$value);
    return;
}

# _die(array msg)
#
# Calls die for now.  Eventually, will tell more.
#
sub _die {
    my(@msg) = @_;
    Bivio::Die->die(@msg);
    # DOES NOT RETURN
}

# _equal(any expected, any actual) : boolean
#
# Returns true if the two structures compare identically.
#
sub _equal {
    my($expected, $actual) = @_;
    return 0 unless defined($expected) eq defined($actual);
    return 1 unless defined($expected);
    return 0 unless ref($expected) eq ref($actual);
    return $expected eq $actual ? 1 : 0 unless ref($expected);
    if (ref($expected) eq 'ARRAY') {
	return 0 unless int(@$expected) == int(@$actual);
	for (my($i) = 0; $i <= $#$expected; $i++) {
	    return 0 unless _equal($expected->[$i], $actual->[$i]);
	}
	return 1;
    }
    if (ref($expected) eq 'HASH') {
	my(@e_keys) = sort(keys(%$expected));
	my(@a_keys) = sort(keys(%$actual));
	return 0 unless _equal(\@e_keys, \@a_keys);
	foreach my $k (@e_keys) {
	    return 0 unless _equal($expected->{$k}, $actual->{$k});
	}
	return 1;
    }
    return _equal($$expected, $$actual) if ref($expected) eq 'SCALAR';

    # CODE, GLOB, Regex, and blessed references should always be equal exactly
    return $expected eq $actual ? 1 : 0;
}

# _result_ok(any proto, string method, array_ref params, any expected, any actual) : boolean
#
# Default result_ok handler.
#
sub _result_ok {
    my($proto, $method, $params, $expected, $actual) = @_;
    # Make sure actual equal expected
    return;
}

# _summarize(array_ref value) : string
#
# Returns a string summary of the array_ref.
#
sub _summarize {
    my($value) = @_;
    return '[]' unless @$value;
    my($res) = '[';
    my($i) = 0;
    foreach my $v (@$value) {
	if (++$i > 3) {
	    # Extra dot gets chopped below
	    $res .= '....';
	    last;
	}
	$res .= ref($v)
	    ? UNIVERSAL::can($v, 'as_string')
	        ? _summarize_scalar($v->as_string)
	        : ref($v)
	    : _summarize_scalar($v);
	$res .= ',';
    }
    chop($res);
    return $res.']';
}

# _summarize_scalar(string v) : string
#
# Trims the scalar if too long.  Outputs undef, if undefined.
#
sub _summarize_scalar {
    my($v) = @_;
    return 'undef' unless defined($v);
    return length($v) > 20 ? substr($v, 0, 20).'...' : $v;
}

# _unit_compile(array_ref tests) : array_ref
#
# Compiles @$tests into a linear list of tuples.
#
sub _unit_compile {
    my($tests) = @_;
    _assert_even($tests, 'tests');
    my(@tests) = @$tests;
    my(@result);
    my($t) = 0;
    while (@tests) {
	$t++;
	my($proto, $group) = splice(@tests, 0, 2);
	$proto = Bivio::IO::ClassLoader->simple_require($proto)
	    unless ref($proto);
	my($proto_name) = (ref($proto) || $proto).'#'.$t;
	_die($proto_name, ': not a blessed reference')
	    unless UNIVERSAL::isa($proto, 'UNIVERSAL');
	_assert_even($group, $proto_name);
	my(@group) = @$group;
	my($g) = 0;
	while (@group) {
	    $g++;
	    my($method, $cases) = splice(@group, 0, 2);
	    my($group_name) = $proto_name.'->'.$method.'#'.$g;
	    _assert_even($cases, $group_name);
	    _die($proto_name, ': does not implement method ', $method)
		unless UNIVERSAL::can($proto, $method);
	    my(@cases) = @$cases;
	    my($c) = 0;
	    while (@cases) {
		$c++;
		my($params, $expected) = splice(@cases, 0, 2);
		my($case_name) = $group_name."(case#".$c.")";
		_assert_array($params, $case_name);
		_die($case_name, ": expected result must be undef, array_ref, "
			." code_ref (sub), or Bivio::DieCode")
		    unless !defined($expected) || ref($expected)
			&& (ref($expected) eq 'CODE'
			    || ref($expected) eq 'ARRAY'
			    || UNIVERSAL::isa($expected, 'Bivio::DieCode'));
		push(@result, {
		    proto_name => $proto_name,
		    proto => $proto,
		    group_name => $group_name,
		    method => $method,
		    case_name => $case_name,
		    params => $params,
		    expected => $expected,
		});
	    }
	}
    }
    return \@result;
}

# _unit_eval(array_ref cases)
#
# Runs the tests as returned from _unit_compile().
#
sub _unit_eval {
    my($cases) = @_;
    my($c) = 0;
    print('1..'.int(@$cases)."\n");
    foreach my $case (@$cases) {
	$c++;
	my($actual);
	my($die) = Bivio::Die->catch(sub {
	    my($method) = $case->{method};
	    _trace($case->{proto}, '->', $method, '(', $case->{params}, ')')
		if $_TRACE;
	    $actual = [$case->{proto}->$method(@{$case->{params}})];
	    return;
	});
	_trace('returned ', $die ? $die->as_string : $actual)
	    if $_TRACE;
	my($err, $ok);
	if (ref($case->{expected}) eq 'CODE') {
	    my($die2) = Bivio::Die->catch(sub {
		$ok = &{$case->{expected}}(
		    $case->{proto},
		    $case->{method},
		    $case->{params},
		    $actual || $die,
		);
		$err = 'custom result_ok() failed' unless $ok;
		return;
	    });
	    $err = 'Error in result_ok: '.$die2->as_string
		if $die2;
	}
	elsif ($die) {
	    my($code) = $die->get('code');
	    if (defined($case->{expected})
		&& UNIVERSAL::isa($case->{expected}, 'Bivio::DieCode')) {
		$ok = $case->{expected} eq $code;
		$err = 'expected '.$case->{expected}->as_string
		    .' but got '.$code->as_string
		    unless $ok;
	    }
	    else {
		$err = 'unexpected '.$code->as_string;
	    }
	}
	elsif (ref($case->{expected}) eq 'ARRAY') {
	    $ok = _equal($case->{expected}, $actual);
	    $err = 'expected '._summarize($case->{expected})
		.' but got '._summarize($actual);
	}
	# else ignore result

	print($ok ? "ok $c\n" : ("not ok $c $case->{case_name}: $err\n"));
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.

=head1 VERSION

$Id$

=cut

1;
