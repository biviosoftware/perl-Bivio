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
            from_literal_or_die => [
                ['99'] => '99',
                ['x99'] => Bivio::DieCode->DIE,
            ],
        ],
    ]);

The first argument to L<unit|"unit"> is a list of object groups.  An object
group is tuple of the object (class or instance) and a list of method groups.
A method group is a tuple of the method name followed by a list of test cases.
Each test case is a tuple of I<params> and an I<expect> value.

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

If the I<expect> is an array_ref, it will be compared with the I<return>.  If
the method returns an array_ref, you'll need to wrap it one more time in an
array_ref, e.g.

    make_array_ref => [
        [1, 2, 3] => [[1, 2, 3]],
    ]

If the I<expect> is a regexp_ref, the I<entire> I<return> will be compared
to I<expect>.  I<return> will be stringified with
L<Bivio::IO::Ref::to_string|Bivio::IO::Ref/"to_string">.

Here C<make_array_ref> is a routine being tested.  It returns an array_ref of
its arguments.  We have an extra level of square brackets on the result
of C<make_array_ref>.

If the I<expect> is a L<Bivio::DieCode|Bivio::DieCode>, an exception is
expected to be thrown and must match the L<Bivio::DieCode|Bivio::DieCode>
exactly.

If the I<expect> is a code_ref, this will be a custom check_return (see below)
for this case only.  If the 

    Bivio::Test->unit([
	Bivio::Math::EMA->new(30) => [
	    compute => [
	        [1] => sub {
                    my($case, $
                    return [1];
                },
	    ],
        ],
    ]);

=head2 OPTIONS

Sometimes it is difficult to specify a return result.  For example, in
L<Bivio::SQL::Connection|Bivio::SQL::Connection>, the result is often a
C<DBI::st>.  The result can't be compared structurally.

You can specify a I<success_ok> option to L<new|"new"> or at the
object or method level.  Here's an example at instantiation:

    Bivio::Test->new->({
	check_return => sub {
	    my($case, $return) = @_;
            # Round to 6 decimal places
	    return [POSIX::floor($return->[0] * 1000000 + 0.5) / 1000000];
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
            check_return => sub {
                my($case, $return) = @_;
                return [POSIX::floor($return->[0] * 1000000 + 0.5) / 1000000];
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
named attributes: C<object> and C<check_return>.

The object level overrides the value supplied to L<new|"new">.
The method level overrides the object level.

The following options are allowed:

=over 4

=item check_die : code_ref

See L<check_die|"check_die">.

=item check_return : code_ref

See L<check_return|"check_return">.

=item compute_params : code_ref

See L<compute_params|"compute_params">

=item method_is_autoloaded : boolean [0]

By default, an object must implement the methods in the test cases. For
AUTOLOAD cases, set this option to true.

=item print : code_ref (global attribute)

You can override the print function used to output the results of the test.
This is probably useful for testing L<Bivio::Test|Bivio::Test> itself.
Only acceptable as an attribute on the
L<Bivio::Test|Bivio::Test> object itself.

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
use Bivio::IO::Ref;
use Bivio::Die;
use Bivio::DieCode;
use Bivio::Test::Case;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my(@_CALLBACKS) = qw(check_return check_die compute_params);
my(@_ALL_OPTIONS) = (@_CALLBACKS, 'print', 'method_is_autoloaded');
my(@_CASE_OPTIONS) = grep($_ ne 'print', @_ALL_OPTIONS);

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

=for html <a name="check_die"></a>

=head2 abstract check_die(Bivio::Test::Case case, Bivio::Die die, Bivio::DieCode expect) : boolean

=head2 abstract check_die(Bivio::Test::Case case, Bivio::Die die, Bivio::DieCode expect) : Bivio::DieCode

This callback is defined as a I<check_die> group attribute.

Will be called only if the case results in an exception (L<Bivio::Die|Bivio::Die> and I<expect> is a L<Bivio::Die|Bivio::Die>, i.e. not
an array_ref or C<undef>.

Returns true or false when it compares the I<die> to the I<expect> or
some other criteria.  True means pass.

Returns a L<Bivio::DieCode|Bivio::DieCode> for the new value of I<case.die>.
This module will then compare the I<expect> with I<die>.

B<Called as a I<sub>, not a method>.

=cut

$_ = <<'}'; # emacs
sub check_die {
}

=for html <a name="check_return"></a>

=head2 callback check_return(Bivio::Test::Case case, array_ref return, array_ref expect) : boolean

=head2 callback check_return(Bivio::Test::Case case, array_ref return, array_ref expect) : array_ref

This callback is defined as the code_ref either in the I<expect> location
in a test case or as the I<check_return> group attribute.

Will be called only if the actual result is a return and I<expect> is an
array_ref, i.e. not a L<Bivio::Die|Bivio::Die> or C<undef>.

Returns true or false when it compares the I<return> to the I<expect> or
some other criteria.   True means pass.

Returns an array_ref for the new value of I<case.return>.  This module will
then compare the I<expect> with I<return>.

B<Called as a I<sub>, not a method>.

=cut

$_ = <<'}'; # emacs
sub check_return {
}

=for html <a name="compute_params"></a>

=head2 callback compute_params(Bivio::Test::Case case, array_ref params, any method, any object) : array_ref

Returns the parameters to be passed to I<method>.  I<object> is the instance or
class to be executed.  I<params> were the values specified with the test case.

The sub always returns a valid array_ref.

B<Called as a I<sub>, not a method>.

=cut

$_ = <<'}'; # emacs
sub compute_params {
}

=for html <a name="print"></a>

=head2 callback print(array args)

Prints its arguments.

Set as an attribute on L<Bivio::Test|Bivio::Test>.
Overrides the print function used to output the results of the test.

Defaults to C<print(STDOUT @args)>.

B<Called as a I<sub>, not a method>.

=cut

$_ = <<'}'; # emacs
sub print {
}

=for html <a name="scalar_ref"></a>

=head2 static scalar_ref(string arg) : scalar_ref

Returns its argument as a scalar_ref.

=cut

sub scalar_ref {
    my(undef, $arg) = @_;
    return \$arg;
}

=for html <a name="unit"></a>

=head2 static unit(array_ref tests)

Evaluates I<tests> which are defined as tuples of tuples of tuples.
see L<DESCRIPTION|"DESCRIPTION"> for the syntax.

The tests are suitable for processing by
L<Bivio::Util::Test::unit|Bivio::Util::Test/"unit">
(command C<b-test unit>) or C<Test::Harness> (a standard CPAN module).

=cut

sub unit {
    my($self, $tests) = @_;
    # Instantiate first, if called statically.
    return $self->new->unit($tests) unless ref($self);
    _eval($self, _compile($self, $tests));
    return;
}

#=PRIVATE METHODS

# _add_option(hash_ref state, hash_ref in, hash_ref option) : boolean
#
# Sets $option in $state to value in $in.  Returns false if
# $option not in $in.
#
sub _add_option {
    my($state, $in, $option) = @_;
    return 0 unless exists($in->{$option});
    $state->{$option} = $in->{$option};
    delete($in->{$option});
    return 1;
}

# _assert_options(hash_ref options)
#
# Validates result_ok, compute_params, and printer options.
#
sub _assert_options {
    my($options) = @_;
    die('options not a hash_ref') unless ref($options) eq 'HASH';
    my($o) = {%$options};
    foreach my $c (@_ALL_OPTIONS) {
	next unless exists($o->{$c});
	die($c, ': option not a subroutine (code_ref)')
	    unless ref($o->{$c}) eq 'CODE' || $c eq 'method_is_autoloaded';
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
	object_num => 0,
	map {
	    ($_ => $self->unsafe_get($_));
	} @_CASE_OPTIONS
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
    $params = [$params] if defined($params) && !ref($params);
    _compile_die($state, 'params must be array_ref or CODE')
	unless ref($params) =~ /^(ARRAY|CODE)$/;
    push(@$tests, my $case = Bivio::Test::Case->new({
	%$state,
	params => $params,
    }));
    $case->expect($expect);
    _trace($case) if $_TRACE;
    return;
}

# _compile_die(any state, array msg)
#
# Calls _die() with msg and state of compilation.
#
sub _compile_die {
    my($state, @msg) = @_;
    _die('Error compiling ', ref($state) eq 'HASH'
	? Bivio::Test::Case->new({%$state}) : $state, ': ', @msg);
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
	unless $state->{method_is_autoloaded}
	    || defined($method) && !ref($method)
		&& UNIVERSAL::can($state->{object}, $method);
    if (ref($cases) eq 'ARRAY') {
	_compile_assert_even($cases, $state);
    }
    elsif (!ref($cases) || ref($cases) =~ /^(CODE|Regexp)$/) {
	# Shortcut: scalar, construct the cases.  Handle undef as ignore case
	$cases = [
	    [] => defined($cases) ? ref($cases) ? $cases : [$cases] : undef,
	];
    }
    else {
	_compile_die($state,
	    'cases is not an ARRAY, CODE, Regexp, scalar or undef: ',
	    $cases);
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

    unless (ref($entity_or_hash) eq 'HASH') {
	# No customizations, just set $which
	$state->{$which} = $entity_or_hash;
    }
    else {
	# Customizations and $which
	my($h) = {%$entity_or_hash};
	_compile_die($state, '"', $which, '" must be specified in HASH')
	    unless $h->{$which};
	_add_option($state, $h, 'method_is_autoloaded');
	foreach my $c (@_CALLBACKS, $which) {
	    next unless _add_option($state, $h, $c);
	    next if $c eq $which;
	    _compile_die($state, $c, ' is not a subroutine (code_ref)')
		unless ref($state->{$c}) eq 'CODE';
	}
	_compile_die($state, 'unknown options: ',
	    join(' ', sort(keys(%$h))))
	    if %$h;
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
    $print->('1..' . int(@$tests) . "\n");
    my($err);
    foreach my $case (@$tests) {
	$c++;
	my($result);
	$case->put(params => _eval_params($case, \$err));
	next if $err;
	my($die) = Bivio::Die->catch(sub {
	    my($method) = $case->get('method');
	    _trace($case) if $_TRACE;
	    $result = [$case->get('object')->$method(@{$case->get('params')})];
	    return;
	});
	_trace('returned ', $die || $result) if $_TRACE;
	if ($die) {
	    $case->put(die => $die);
	    $err = _eval_result($case, $die);
	}
	elsif (defined($case->unsafe_get('expect'))) {
	    $case->put(return => $result);
	    $err = _eval_result($case, $result);
	}
	else {
	    _trace('ignoring result') if $_TRACE;
	}
    }
    continue {
	$print->(!$err
	    ? "ok $c\n" : ("not ok $c " . $case->as_string . ": $err\n"));
	$err = undef;
    }
    return;
}

# _eval_custom(Bivio::Test::Case case, string which, array_ref params, string_ref err) : any
#
# Returns result of custom call $which (check_return or compute_params).
# If there is an error, $err will be set.  Checks for appropriate return
# result in case of compute_params.
#
# $params only needs extra params for check_return only.
#
sub _eval_custom {
    my($case, $which, $params, $err) = @_;
    my($res);
    my($die) = Bivio::Die->catch(sub {
	$res = $case->get($which)->($case, @$params);
	return;
    });
    if ($die) {
	$$err = "Error in custom $which: " . $die->as_string;
	return undef;
    }
    if ($which =~ /params/ && ref($res) ne 'ARRAY') {
	$$err = 'custom compute_params did not return an array_ref: '
	    . Bivio::IO::Ref->to_short_string($res);
	return undef;
    }
    if ($which =~ /expect|return/
	&& ref($res) && ref($res) ne 'ARRAY') {
	$$err = 'custom check_return did not return an array_ref or scalar: '
	    . Bivio::IO::Ref->to_short_string($res);
	return undef;
    }
    if ($which =~ /die/
	&& ref($res) && !UNIVERSAL::isa($res, 'Bivio::DieCode')) {
	$$err = 'custom check_die did not return a Bivio::DieCode or scalar: '
	    . Bivio::IO::Ref->to_short_string($res);
	return undef;
    }
    return $res;
}

# _eval_params(Bivio::Test::Case case, string_ref err) : array_ref
#
# Returns params.
#
sub _eval_params {
    my($case, $err) = @_;
    foreach my $custom (qw(params compute_params)) {
	return _eval_custom(
	    $case, $custom, [$case->get(qw(params method object))], $err)
	    if ref($case->unsafe_get($custom)) eq 'CODE';
    }
    return $case->get('params');
}

# _eval_result(Bivio::Test::Case case, any actual) : string
#
# Calls the custom method, if need be.
# Assumes type of result was already verified.
#
sub _eval_result {
    my($case, $actual) = @_;
    my($custom);
    my($result) = ref($actual) eq 'Bivio::Die'
	? $actual->get('code') : $actual;
    if (ref($case->get('expect')) eq 'CODE') {
	# Only on success do we eval a case-specific check_return
	$custom = 'expect'
	    if ref($actual) eq 'ARRAY';
    }
    elsif (ref($case->get('expect')) eq ref($result)) {
	$custom = ref($actual) eq 'Bivio::Die' ? 'check_die' : 'check_return';
	unless ($case->unsafe_get($custom)) {
	    return undef if
		Bivio::IO::Ref->nested_equals($case->get('expect'), $result);
	    $custom = undef;
	}
    }
    elsif (ref($case->get('expect')) eq 'Regexp'
	&& ref($actual) ne 'Bivio::Die') {
#TODO: Replace when perl bug is fixed.
	my($x) = $case->get('expect');
	$x = "$x";
	return undef if ${Bivio::IO::Ref->to_string($actual)} =~ /$x/;
    }
    if ($custom) {
	my($err);
	my($res) = _eval_custom(
	    $case, $custom, [$actual, $case->get('expect')], \$err);
	_trace($case, ' ', $custom, ' returned: ', $res) if $_TRACE;
	return $err if $err;
	if (ref($res)) {
	    # New value for return or die, save and compare
	    $custom =~ s/^check_//;
	    $case->put($custom => $actual = $res);
	    return undef if
		Bivio::IO::Ref->nested_equals($case->get('expect'), $res);
	}
	elsif ($res) {
	    return undef;
        }
	# else false return from custom
    }
    return 'expected ' . Bivio::IO::Ref->to_short_string($case->get('expect'))
	.' but got ' . Bivio::IO::Ref->to_short_string($actual);
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.

=head1 VERSION

$Id$

=cut

1;
