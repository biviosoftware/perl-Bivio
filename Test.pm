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
    Bivio::Test->run([
        Bivio::Type::Integer => [
            from_literal => [
	        [1] => [1],
	        [x] => [undef, Bivio::TypeError->INTEGER],
            ],
        ],
    ]);

You declare the class or instance you are testing followed by a list of tests.
Each test is a method name followed by a list of cases.  Each case is a tuple
of parameter(s) and return value(s).

If there is no return value, specify C<[undef]>.  That's what the method should
return if it doesn't return anything.  (All perl subs return C<undef>
implicitly.

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

#=VARIABLES
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

=for html <a name="run"></a>

=head2 run(array_ref tests)

Evaluates I<tests> which are defined as tuples of tuples of tuples.
see L<DESCRIPTION|"DESCRIPTION"> for the syntax.

The tests are suitable for processing by C<Test::Harness>, a standard CPAN
module.  See also L<Bivio::Util::Test|Bivio::Util::Test> which is a
front-end to C<Test::Harness>.

=cut

sub run {
    my($proto, $tests) = @_;
    my($die) = Bivio::Die->catch(sub {_compile($tests)});
    return $die->as_string;
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

# _compile(array_ref tests) : array_ref
#
# Compiles @$tests into a linear list of tuples.
#
sub _compile {
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
		    proto_name => $proto_name
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

# _die(array msg)
#
# Calls die for now.  Eventually, will tell more.
#
sub _die {
    my(@msg) = @_;
    Bivio::Die->die(@msg);
    # DOES NOT RETURN
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

=head1 COPYRIGHT

Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.

=head1 VERSION

$Id$

=cut

1;
