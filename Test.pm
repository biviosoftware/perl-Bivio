# Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.
# $Id$
package Bivio::Test;
use strict;
$Bivio::Test::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::VERSION;

=head1 NAME

Bivio::Test - unit testing framework

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Test;

=cut

=head1 EXTENDS

L<Bivio::Collection::Attributes>

=cut

use Bivio::Collection::Attributes;
@Bivio::Test::ISA = ('Bivio::Collection::Attributes');

=head1 DESCRIPTION

C<Bivio::Test> supports declarative unit testing.  A declarative test allows
you to define what you want to test very succinctly.  Here's an example:

    #!perl -w
    use strict;
    use Bivio::TypeError;
    use Bivio::Type::Integer;
    Bivio::Test->unit([
        Bivio::Type::Integer => [
            from_literal => [
	        ['1'] => [1],
	        ['x'] => [undef, Bivio::TypeError->INTEGER],
            ],
        ],
    ]);

The first argument to L<unit|"unit"> is a list of object groups.  An object
group is tuple of the object (class or instance) and a list of method groups.
A method group is a tuple of the method name followed by a list of test cases.
Each test case is a tuple of parameters and a return value.


If the return value is undef, specify C<[undef]> as the result.  That's what
the method should return if it doesn't return anything.  perl methods return
C<undef> implicitly if the last statement they execute is C<return;>.  We
recommend you always end your methods in a C<return> statement to avoid
unexpected return values being used.  perl by default returns the value of the
last statement executed.  This can have serious side-effects unless one is
careful.

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

Here C<make_array_ref> is a routine being tested.  It returns an array_ref of
its arguments.  We have an extra level of square brackets on the result
of C<make_array_ref>.

If the expected (declared) return value is a L<Bivio::DieCode|Bivio::DieCode>,
an exception is expected and must match the C<DieCode> exactly.

If the expected is a code_ref, this will be a custom result_ok (see below)
for this case only.

    Bivio::Test->unit([
	Bivio::Math::EMA->new(30) => [
	    compute => [
	        [1] => sub {
		    my($object, $method, $params, $expect, $actual) = @_;
		    return 0
			unless defined($actual->[0]) && !ref($actual->[0]);
		    return $actual->[0] == 1;
		},
	    ],
        ],
    ]);

=head2 OPTIONS

Sometimes it is difficult to specify a return result.  For example, in
L<Bivio::SQL::Connection|Bivio::SQL::Connection>, the result is often a
C<DBI::st>.  The result can't be compared structurally.

You can specify a I<result_ok> option to L<new|"new"> or at the
object or method level.  Here's an example at instantiation:

    Bivio::Test->new->({
	result_ok => sub {
	    my($object, $method, $params, $expect, $actual) = @_;
            # Round to 6 decimal places
	    return POSIX::floor($actual->[0] * 1000000 + 0.5) / 1000000
	        == $expect->[0];
	},
    })->unit([
	Bivio::Math::EMA->new(30) => [
	    compute => [
	        [1] => [1],
	        [2] => [1.666666],
	        [2] => [1.888888],
	    ],
        ],
    ]);

In this case, we could also have specified the option at the object level
as in:

    Bivio::Test->unit([
        {
	    object => Bivio::Math::EMA->new(30),
	    result_ok => sub {
		# Round to 6 decimal places
		return POSIX::floor($actual->[0] * 1000000 + 0.5) / 1000000
		    == $expect->[0];
	    },
        } => [
	    compute => [
	        [1] => [1],
	        [2] => [1.666666],
	        [2] => [1.888888],
	    ],
        ],
    ]);

Note the introduction of a hash_ref in place of the object
C<Bivio::Math::EMA-E<gt>new(30)> and the introduction of the
named attributes: C<object> and C<result_ok>.

The object level overrides the value supplied to L<new|"new">.
The method level overrides the object level.

The following options are allowed:

=over 4

=item compute_params : code_ref

A pre-processor for input parameters specified in the test cases.
See the abstract sub L<compute_params|"compute_params"> for
a description of the inputs and output of this sub.

The default is to pass the params in each case verbatim to the
method.

=item print : code_ref (new level only)

You can override the print function used to output the results of the test.
This is probably useful for testing L<Bivio::Test|Bivio::Test> itself.

=item result_ok : code_ref

A post-processor for the result specified in the test cases.
Will be called only if the expect and actual results match at
the type level.  In the non-exception, expect is an array_ref.
If an exception isn't thrown, actual will an array_ref.

For C<undef> expect values, the L<result_ok|"result_ok"> sub is
not called.

See the abstract sub L<result_ok|"result_ok"> for
a description of the inputs and output of this sub.

The default is to compare the expect and actual verbatim.

=back

=head2 SHORTCUTS

If a method takes no parameters and returns a simple scalar
result, the case case be written, e.g.:

    Bivio::Test->unit([
	'Bivio::Type::Integer' => [
	    get_min => -999999999,
	    get_max => 999999999,
        ],
    ]);

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::Die;
use Bivio::DieCode;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref options) : Bivio::Test

Create a new test instance.  You can specify options here or at
the object or method levels of I<tests> as passed to L<unit|"unit">.
See L<OPTIONS|"OPTIONS"> for more details.

=cut

sub new {
    my($proto, $options) = @_;
    _assert_options($options) if $options;
    return Bivio::Collection::Attributes::new($proto, $options);
}

=head1 METHODS

=cut

=for html <a name="compute_params"></a>

=head2 abstract sub compute_params(any object, string method, array_ref params) : array_ref

Returns the parameters to be passed to I<method>.  I<object> is the instance or
class to be executed.  I<params> were the values specified with the test case.

The sub always returns a valid array_ref, a L<Bivio::DieCode|Bivio::DieCode>,
or C<undef> (ignore result) which may be empty.

B<Called as a I<sub>, not a method>.

=cut

$_ = <<'}'; # emacs
sub compute_params {
}

=for html <a name="default_result_ok"></a>

=head2 static default_result_ok(any object, string method, array_ref params, array_ref expect, array_ref actual) : boolean

=head2 static default_result_ok(any object, string method, array_ref params, Bivio::DieCode expect, Bivio::DieCode actual) : boolean

C<default_result_ok> custom L<result_ok|"result_ok"> subs to handle the normal
case.  This allows you to override default result comparisons only in certain
cases.  For example, the custom result_ok is only called if the method
is C<compute> in the following:

    Bivio::Test->new->({
	result_ok => sub {
	    my($object, $method, $params, $expect, $actual) = @_;
            return Bivio::Test->default_result_ok(@_)
                if $method ne 'compute';
	    return POSIX::ceil($actual * 100000) / 100000;
	}
    })->unit({
        ...
    })

=cut

sub default_result_ok {
    my($proto, $object, $method, $params, $expect, $actual) = @_;
    die('default_result_ok called with invalid expect')
	unless ref($expect);
    die('default_result_ok called with invalid actual')
	unless ref($actual);
    die('default_result_ok called with incorrect parameters')
	unless ref($expect) eq ref($actual)
	    || UNIVERSAL::isa($expect, 'Bivio::DieCode')
		&& UNIVERSAL::isa($actual, 'Bivio::DieCode');
    return _eval_equal($expect, $actual);
}

=for html <a name="result_ok"></a>

=head2 abstract sub result_ok(any object, string method, array_ref params, array_ref expect, array_ref actual) : boolean

=head2 abstract sub result_ok(any object, string method, array_ref params, Bivio::DieCode expect, Bivio::DieCode actual) : boolean

I<object> is the instance or class which was executed.  I<method> was called
with I<params>.  I<expect> is the result specified in the test case,
either an array_ref or a L<Bivio::DieCode|Bivio::DieCode>.

I<actual> is the result returned from the call to I<method>.

C<result_ok> is only called if the types of I<expect> and I<actual> match.
For example, if I<actual> is a DieCode and I<expect> is an array_ref, the
test fails and the C<result_ok> method is not called.

The sub returns true if the test passed, i.e. I<expect> equals I<actual>.

This handler may be specified at the test, object, or method levels.

See L<OPTIONS|"OPTIONS"> or an example.

=cut

$_ = <<'}'; # emacs
sub result_ok {
}

=for html <a name="unit"></a>

=head2 static unit(array_ref tests)

Evaluates I<tests> which are defined as tuples of tuples of tuples.
see L<DESCRIPTION|"DESCRIPTION"> for the syntax.

The tests are suitable for processing by C<Test::Harness>, a standard CPAN
module.  See also L<Bivio::Util::Test|Bivio::Util::Test> which is a
front-end to C<Test::Harness>.

=cut

sub unit {
    my($self, $tests) = @_;
    # Instantiate first, if called statically.
    return $self->new->unit($tests) unless ref($self);

    # Compile blows up.  May want to "catch" and print result as opposed
    # to dying.
    _eval($self, _compile($self, $tests));
    return;
}

#=PRIVATE METHODS

# _assert_options(hash_ref options)
#
# Validates result_ok, compute_params, and printer options.
#
sub _assert_options {
    my($options) = @_;
    die('options not a hash_ref') unless ref($options) eq 'HASH';
    my($o) = {%$options};
    foreach my $c ('result_ok', 'compute_params', 'print') {
	next unless exists($o->{$c});
	die($c, ': option not a subroutine (code_ref)')
	    unless ref($o->{$c}) eq 'CODE';
	delete($o->{$c});
    }
    _die('unknown option(s) passed to new: ', join(' ', sort(keys(%$o))))
	if %$o;
    return;
}

# _compile(self, array_ref objects) : array_ref
#
# Compiles @$objects into a linear list of tuples.
#
sub _compile {
    my($self, $objects) = @_;
    my($state) = {
	result_ok => $self->unsafe_get('result_ok'),
	compute_params => $self->unsafe_get('compute_params'),
	object_num => 0,
    };
    _compile_assert_even($objects, $state);
    my(@objects) = @$objects;
    my($tests) = [];
    while (@objects) {
	_compile_object($state, $tests, splice(@objects, 0, 2));
    }
    return $tests;
}

# _compile_assert_array(any value, hash_ref state)
#
# Asserts value is an array_ref.
#
sub _compile_assert_array {
    my($value, $state) = @_;
    _compile_die($state, 'value must be an array_ref')
	unless ref($value) eq 'ARRAY';
    return;
}

# _compile_assert_even(any value, hash_ref state)
#
# Asserts value is an even length array_ref.
#
sub _compile_assert_even {
    my($value, $state) = @_;
    _compile_assert_array($value, $state);
    _compile_die($state, 'value has uneven elements in array')
	unless int(@$value) % 2 == 0;
    _compile_die($state, 'value has no elements in array')
	unless int(@$value);
    return;
}

# _compile_case(hash_ref state, array_ref tests, array_ref params, array_ref expect)
#
# Parses a single case and pushes it on @$tests.
#
sub _compile_case {
    my($state, $tests, $params, $expect) = @_;
    $state->{case_num}++;
    _compile_assert_array($params, $state);
    _compile_die($state, "expected result must be undef, array_ref, "
	." CODE, or Bivio::DieCode")
	unless !defined($expect) || ref($expect)
	    && (ref($expect) =~ /^(ARRAY|CODE)$/
		|| UNIVERSAL::isa($expect, 'Bivio::DieCode'));
    push(@$tests, {
	%$state,
	params => $params,
	expect => $expect,
    });
    _trace($tests->[$#$tests]) if $_TRACE;
    return;
}

# _compile_die(hash_ref state, array msg)
#
# Calls _die() with msg and state of compilation.
#
sub _compile_die {
    my($state, @msg) = @_;
    _die('Error compiling ', _test_sig($state), ': ', @msg);
    # DOES NOT RETURN
}

# _compile_method(hash_ref state, array_ref tests, any method, array cases)
#
# Validates method and parses cases.
#
sub _compile_method {
    my($state, $tests, $method, $cases) = @_;
    $state = _compile_options($state, 'method', $method);
    $method = $state->{method};
    _compile_die($state, (ref($state->{object}) || $state->{object}),
	' does not implement method "', $method, '"')
	unless defined($method) && !ref($method)
	    && UNIVERSAL::can($state->{object}, $method);
    if (ref($cases)) {
	_compile_assert_even($cases, $state);
    }
    else {
	# Shortcut: scalar, construct the cases.  Handle undef as ignore case
	$cases = [
	    [] => defined($cases) ? [$cases] : undef,
	];
    }
    my(@cases) = @$cases;
    $state->{case_num} = 0;
    while (@cases) {
	_compile_case($state, $tests, splice(@cases, 0, 2));
    }
    return;
}

# _compile_object(hash_ref state, array_ref tests, any object, array_ref methods)
#
# Validates $object and sets object info on state.  Compiles methods.
#
sub _compile_object {
    my($state, $tests, $object, $methods) = @_;
    $state = _compile_options($state, 'object', $object);
    $object = $state->{object};
    _compile_die($state, 'object is not a blessed reference or class (did you forget to import it?)')
	unless UNIVERSAL::isa($object, 'UNIVERSAL');
    _compile_assert_even($methods, $state);
    $state->{method_num} = 0;
    my(@methods) = @$methods;
    while (@methods) {
	_compile_method($state, $tests, splice(@methods, 0, 2));
    }
    return;
}

# _compile_options(hash_ref state, string which, any entity_or_hash) : 
#
# which is object, method, or case.  If entity_or_hash is a hash, the hash
# is parsed for which and the attributes are copied.  Any extra attributes
# cause an exception.  $which_num is incremented.
#
sub _compile_options {
    my($state, $which, $entity_or_hash) = @_;
    _trace('options: ', $entity_or_hash) if $_TRACE;
    $state->{$which.'_num'}++;

    # Make a copy, so we retain defaults of parent
    $state = {%$state};

    if (ref($entity_or_hash) eq 'HASH') {
	# Customizations and $which
	my($h) = {%$entity_or_hash};
	_compile_die($state, '"', $which, '" must be specified in HASH')
	    unless $h->{$which};
	foreach my $c ('result_ok', 'compute_params', $which) {
	    next unless exists($h->{$c});
	    $state->{$c} = $h->{$c};
	    delete($h->{$c});
	    next if $c eq $which;
	    _compile_die($state, $c, ' is not a subroutine (code_ref)')
		unless ref($state->{$c}) eq 'CODE';
	}
	_compile_die($state, 'unknown options: ',
	    join(' ', sort(keys(%$h))))
	    if %$h;
    }
    else {
	# No customizations, just set $which
	$state->{$which} = $entity_or_hash;
    }
    _trace('state: ', $state) if $_TRACE;
    return $state;
}

# _default_print(array msg)
#
# Prints its arguments to STDOUT.
#
sub _default_print {
    return print(@_);
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

# _eval(self, array_ref tests)
#
# Runs the tests as returned from _compile().
#
sub _eval {
    my($self, $tests) = @_;
    my($c) = 0;
    my($print) = $self->get_or_default('print', \&_default_print);
    &$print('1..'.int(@$tests)."\n");
    my($err);
    foreach my $test (@$tests) {
	$c++;
	my($actual);
	$test->{params} = _eval_custom($test, 'compute_params', [], \$err)
	    if $test->{compute_params};
	next if $err;
	my($die) = Bivio::Die->catch(sub {
	    my($method) = $test->{method};
	    _trace($test->{object}, '->', $method, '(', $test->{params}, ')')
		if $_TRACE;
	    $actual = [$test->{object}->$method(@{$test->{params}})];
	    return;
	});
	_trace('returned ', $die || $actual) if $_TRACE;
	if ($die) {
	    $err = _eval_result($test, $die->get('code'));
	}
	elsif (defined($test->{expect})) {
	    $err = _eval_result($test, $actual);
	}
	# else ignore result
    }
    continue {
	&$print(!$err
	    ? "ok $c\n" : ("not ok $c "._test_sig($test).": $err\n"));
	$err = undef;
    }
    return;
}

# _eval_custom(hash_ref test, string which, array_ref params, string_ref err) : any
#
# Returns result of custom call $which (result_ok or compute_params).
# If there is an error, $err will be set.  Checks for appropriate return
# result in case of compute_params.
#
# $params only needs extra params for result_ok only.
#
sub _eval_custom {
    my($test, $which, $params, $err) = @_;
    my($res);
    my($die) = Bivio::Die->catch(sub {
	$res = &{$test->{$which}}(
	    $test->{object}, $test->{method}, $test->{params}, @$params);
	return;
    });
    if ($die) {
	$$err = "Error in custom $which: ".$die->as_string;
	return undef;
    }
    if ($which eq 'compute_params' && defined($res)
	&& !(ref($res) || ref($res) eq 'ARRAY'
	    || UNIVERSAL::isa($res, 'Bivio::DieCode'))) {
	$$err = 'custom compute_params did not return an array_ref: '
	    ._summarize($res);
	return undef;
    }
    return $res;
}

# _eval_equal(any expect, any actual) : boolean
#
# Returns true if the two structures compare identically.
#
sub _eval_equal {
    my($expect, $actual) = @_;
    return 0 unless defined($expect) eq defined($actual);
    return 1 unless defined($expect);

    # References must match exactly or we've got a problem
    return 0 unless ref($expect) eq ref($actual);

    # Scalar
    return $expect eq $actual ? 1 : 0 unless ref($expect);

    if (ref($expect) eq 'ARRAY') {
	return 0 unless int(@$expect) == int(@$actual);
	for (my($i) = 0; $i <= $#$expect; $i++) {
	    return 0 unless _eval_equal($expect->[$i], $actual->[$i]);
	}
	return 1;
    }
    if (ref($expect) eq 'HASH') {
	my(@e_keys) = sort(keys(%$expect));
	my(@a_keys) = sort(keys(%$actual));
	return 0 unless _eval_equal(\@e_keys, \@a_keys);
	foreach my $k (@e_keys) {
	    return 0 unless _eval_equal($expect->{$k}, $actual->{$k});
	}
	return 1;
    }
    return _eval_equal($$expect, $$actual) if ref($expect) eq 'SCALAR';

    # blessed ref: Check if can equals and compare that way
    return $expect->equals($actual) ? 1 : 0
	if UNIVERSAL::can($expect, 'equals');

    # CODE, GLOB, Regex, and blessed references should always be equal exactly
    return $expect eq $actual ? 1 : 0;
}

# _eval_result(hash_ref test, any actual) : string
#
# Calls the custom method, if need be.
# Assumes type of result was already verified.
#
sub _eval_result {
    my($test, $actual) = @_;
    my($custom);
    if (ref($test->{expect}) eq 'CODE') {
	$custom = 'expect';
    }
    elsif (ref($test->{expect}) eq ref($actual)) {
	if ($test->{result_ok}) {
	    $custom = 'result_ok';
	}
	else {
	    return undef if _eval_equal($test->{expect}, $actual);
	}
    }
    if ($custom) {
	my($err);
	my($res) = _eval_custom(
	    $test, $custom, [$test->{expect}, $actual], \$err);
	return $err if $err;
	return undef if $res;
    }
    return 'expected '._summarize($test->{expect})
	.' but got '._summarize($actual);
}

# _summarize(any value) : string
#
# Returns a string summary of the array_ref.  Used very specially by
# eval code.  We don't summarize all data structures.
#
sub _summarize {
    my($value) = @_;
    my($res) = Bivio::IO::Alert->format_args($value);
    chomp($res);
    return $res;
}

# _test_sig(hash_ref test) : string
#
# Computes a signature for the test.
#
sub _test_sig {
    my($test) = @_;
    my($sig) = '';
    $sig .= (ref($test->{object}) || $test->{object} || '<Object>')
	.'#'.$test->{object_num}
	if $test->{object};
    $sig .= '->'.($test->{method} || '<method>').'#'.$test->{method_num}
	if $test->{method_num};
    $sig .= '(case#'.$test->{case_num}
	.($test->{params} ? '['._summarize($test->{params}).']' : '')
	.')'
	if $test->{case_num};
    return $sig;
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.

=head1 VERSION

$Id$

=cut

1;
