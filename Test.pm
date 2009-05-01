# Copyright (c) 2001-2007 bivio Software, Inc.  All Rights reserved.
# $Id$
package Bivio::Test;
use strict;
use Bivio::Base 'Collection.Attributes';
use Bivio::Die;
use Bivio::DieCode;
use Bivio::IO::Ref;
use Bivio::IO::Trace;
use Bivio::Test::Case;

# C<Bivio::Test> supports declarative unit testing.  A declarative test allows
# you to define what you want to test very succinctly.  Here's an example:
#
#     #!perl -w
#     use strict;
#     use Bivio::TypeError;
#     use Bivio::Test;
#     Bivio::Test->new('Bivio::Type::Integer')->unit([
#         Bivio::Type::Integer => [
#             from_literal => [
# 	        ['1'] => [1],
# 	        ['x'] => [undef, Bivio::TypeError->INTEGER],
#             ],
#             from_literal_or_die => [
#                 ['99'] => '99',
#                 ['x99'] => Bivio::DieCode->DIE,
#             ],
#         ],
#     ]);
#
# The first argument to L<unit|"unit"> is a list of object groups.  An object
# group is tuple of the object (class or instance) and a list of method groups.
# A method group is a tuple of the method name followed by a list of test cases.
# Each test case is a tuple of I<params> and an I<expect> value.
#
# If the return value is undef, specify C<[undef]> as the result.  That's what
# the method should return if it doesn't return anything.  perl methods return
# C<undef> implicitly if the last statement they execute is C<return;>.  We
# recommend you always end your methods in a C<return> statement to avoid
# unexpected return values being used unexpectedly.  perl by default returns the
# value of the last statement executed.  This can have serious side-effects
# unless one is careful.
#
# To ignore the return result, specify C<undef> (as a scalar, not wrapped in an
# array_ref), i.e. the test case tuple should only include the parameter(s).
# Here's an example:
#
#     do_something => [
#         [1, 2, 3] => undef,
#     ],
#
# The result of the call to the method C<do_something> will not be checked.  If
# the method dies (throws an exception), the case will fail.  When there is no
# exception, the case passes.
#
# If the I<expect> is an array_ref, it will be compared with the I<return>.  If
# the method returns an array_ref, you'll need to wrap it one more time in an
# array_ref, e.g.
#
#     make_array_ref => [
#         [1, 2, 3] => [[1, 2, 3]],
#     ]
#
# If I<expect> is a regexp_ref, the I<entire> I<return> will be compared
# to I<expect>.  I<return> will be stringified with
# L<Bivio::IO::Ref::to_string|Bivio::IO::Ref/"to_string">.
#
# Here C<make_array_ref> is the routine being tested.  It returns an array_ref of
# its arguments.  We have an extra level of square brackets on the result
# of C<make_array_ref>.
#
# If the I<expect> is a code_ref, this will be a custom check_return (see
# L<check_return|"check_return"> and below) for this case only.  If an exception
# is I<not> thrown, I<check_return> is called.  If it is thrown, I<check_return>
# is not called.
#
# If the I<expect> is a L<Bivio::DieCode|Bivio::DieCode>, an exception is
# expected to be thrown and must match the L<Bivio::DieCode|Bivio::DieCode>
# exactly.
#
#
# Sometimes it is difficult to specify a return result.  For example, in
# L<Bivio::SQL::Connection|Bivio::SQL::Connection>, the result is often a
# C<DBI::st>.  The result can't be compared structurally.
#
# You can specify a I<check_return> or I<compute_return> option to L<new|"new">
# or at the object or method level.  You can also specify a I<class_name> to
# require.  When I<class_name> implements C<new>, it will be called with the
# I<object> params.  Here's an example with global I<check_return> and the
# implicit call to I<new>:
#
#     Bivio::Test->new->({
#         class_name => 'Bivio::Math::EMA',
# 	check_return => sub {
# 	    my($case, $actual, $expect) = @_;
#             # Round to 6 decimal places
# 	    $case->actual_return(
#                 [POSIX::floor($actual->[0] * 1000000 + 0.5) / 1000000]);
#             return $expect;
# 	},
#     })->unit([
# 	30 => [
# 	    compute => [
# 	        1 => 1,
# 	        2 => 1.666666,
# 	        2 => 1.888888,
# 	    ],
#         ],
#     ]);
#
# In this case, we could also have specified the option at the object level
# as in:
#
#     Bivio::Test->unit([
#         {
#             class_name => 'Bivio::Math::EMA',
# 	    object => 30,
#             check_return => sub {
#                 my($case, $actual, $expect) = @_;
#                 $case->actual_return(
#                     [POSIX::floor($actual->[0] * 1000000 + 0.5) / 1000000];
#                 return $expect;
# 	    },
#         } => [
# 	    compute => [
# 	        [1] => [1],
# 	        [2] => [1.666666],
# 	        [2] => [1.888888],
# 	    ],
#         ],
#     ]);
#
# Note the introduction of a hash_ref in place of the object C<30> and the
# introduction of the named attributes: C<object> and C<check_return>.
#
# The object level overrides the value supplied to L<new|"new">.
# The method level overrides the object level.
#
# The following options are allowed:
#
#
# check_die_code : code_ref
#
# See L<check_die_code|"check_die_code">.
#
# check_return : code_ref
#
# See L<check_return|"check_return">.
#
# class_name : string
#
# Name of class to test.  Will be loaded dynamically with
# L<Bivio::IO::ClassLoader|Bivio::IO::ClassLoader>.
# L<create_object|"create_object"> will be set to
# L<default_create_object|"default_create_object">
# unless already set.
#
# compute_params : code_ref
#
# See L<compute_params|"compute_params">
#
# compute_return : code_ref
#
# See L<compute_return|"compute_return">.
#
# create_object : code_ref
#
# See L<create_object|"create_object">
#
# method : any (method attribute)
#
# Name of the method to call in the method group.  The following
# two are equivalent:
#
#     {
#         method => 'my_method',
#     } => [
#         <cases>,
#     ],
#
# and
#
#     my_method => [
#         <cases>,
#     ],
#
# method_is_autoloaded : boolean [0]
#
# By default, an object must implement the methods in the test cases. For
# AUTOLOAD cases, set this option to true.
#
# object : any (object attribute)
#
# Used as the object, to create the object, or as params to
# L<default_create_object|"default_create_object">.  The following
# two are equivalent:
#
#     {
#         object => <create arg>,
#     } => [
#         <method groups>,
#     ],
#
# and
#     <creation args> => [
#         <method groups>,
#     ],
#
# print : code_ref (global attribute)
#
# You can override the print function used to output the results of the test.
# This is probably useful for testing L<Bivio::Test|Bivio::Test> itself.
# Only acceptable as an attribute on the
# L<Bivio::Test|Bivio::Test> object itself.
#
# want_scalar : boolean [0]
#
# Caveat: we recommend executing all methods in a list
# context, and that methods should avoid being dependent on context.
# (For an example of how to avoid being context sensitive,
# see L<Bivio::Collection::Attributes::get|Bivio::Collection::Attributes/"get">).
#
# That being said, you sometimes need to test modules which are
# context sensitive, i.e. they return a scalar in a scalar context
# and an array in a list context.  Set this to true if you want
# all methods in the case group to be invoked in a scalar context.
#
#
#
# You can also specify a L<imperative_case|"imperative_case"> at the method
# level, e.g.,
#
#     Bivio::Test->new('Bivio::Math::EMA')->unit([
#         30 => sub {
#             my($case, $object) = @_;
#             foreach my $sub_case (
# 	        [1 => 1],
# 	        [2 => 1.666666],
# 	        [2 => 1.888888],
#             ) {
#                 my($value, $expect) = @$sub_case;
#                 return 0
#                     unless $expect
#                     == POSIX::floor(
#                         $object->compute($value) * 1000000 + 0.5) / 1000000;
# 	    },
#             return 1;
#         },
#     ]);
#
# You may also specify an I<imperative_case> as the I<method> option of a
# method group.  This allows you to specify the return value.
#
#
# If a method takes no parameters and returns a simple scalar
# result, the case case be written, e.g.:
#
#     Bivio::Test->unit([
# 	'Bivio::Type::Integer' => [
# 	    get_min => -999999999,
# 	    get_max => 999999999,
#         ],
#     ]);
#
#
# After L<unit|"unit"> completes, the following attributes are set:
#
#
# failed : array_ref
#
# Numbers for the cases which I<failed>.  Case numbers start at 1.
#
# passed : array_ref
#
# Numbers for the cases which I<passed>.  Case numbers start at 1.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_CASE);
our($_SELF);
my($_IDI) = __PACKAGE__->instance_data_index;
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my(@_CALLBACKS) = qw(check_return check_die_code compute_params compute_return create_object);
my(@_PLAIN_OPTIONS) = qw(method_is_autoloaded class_name want_scalar comparator);
my(@_ALL_OPTIONS) = (@_CALLBACKS, 'print', @_PLAIN_OPTIONS);
my(@_CASE_OPTIONS) = grep($_ ne 'print', @_ALL_OPTIONS);
my($_HANDLERS) = b_use('Biz.Registrar')->new;

sub IGNORE_RETURN {
    # B<EXPERIMENTAL>
    #
    # Return value to use when you want to ignore a return.
    return @_ == 1 ? \&IGNORE_RETURN : 1;
}

sub current_case {
    # Returns current case or dies.
    return $_CASE || Bivio::Die->die('no current case');
}

sub current_self {
    # Returns current running instance of this class or dies.
    return $_SELF || Bivio::Die->die('no current self');
}

sub default_create_object {
    my($case, $params) = @_;
    # Implements L<create_object|"create_object"> interface.  Calls
    # L<new|"new"> on I<class_name> attribute.
    #
    # SPECIAL CASE: I<params> contains the a single value which is
    # is name of the class, then the class name is returned and I<new>
    # is not called.  This allows mixing static (class) and instance tests.
    my($c) = $case->get('class_name');
    return @$params == 1 && $params->[0] eq $c ? $c : $c->new(@$params);
}

sub format_results {
    my(undef, $num_ok, $max) = @_;
    # Formats test results into a human readable string.
    return $max == $num_ok
	? "All ($max) tests PASSED\n"
        : sprintf("FAILED %d (%.1f%%) and passed %d (%.1f%%)\n",
	    map {
		$_, 100 * $_ / $max;
	    } ($max - $num_ok), $num_ok);
}

sub new {
    my($proto, $options) = @_;
    # Create a new test instance.  You can specify options here or at
    # the object or method levels of I<tests> as passed to L<unit|"unit">.
    # See L<OPTIONS|"OPTIONS"> for more details.
    my($self) = $proto->SUPER::new(_assert_options($options));
    _load_class($self);
    $self->[$_IDI] = {};
    return $self;
}

sub register_handler {
    shift;
    $_HANDLERS->push_object(@_);
    return;
}

sub unit {
    my($self, $tests) = @_;
    # Evaluates I<tests> which are defined as tuples of tuples of tuples.
    # see L<DESCRIPTION|"DESCRIPTION"> for the syntax.
    #
    # The tests are suitable for processing by
    # L<Bivio::Util::Test::unit|Bivio::Util::Test/"unit">
    # (command C<b-test unit>) or C<Test::Harness> (a standard CPAN module).
    #
    # If I<class_name> is supplied, will pass to L<new|"new"> or simply "put" on
    # self.
    return ref($self) ? _eval($self, _compile($self, $tests))
	: $self->new->unit($tests);
}

sub unsafe_current_self {
    return $_SELF;
}

sub _add_option {
    my($state, $in, $option) = @_;
    # Sets $option in $state to value in $in.  Returns false if
    # $option not in $in.
    return 0 unless exists($in->{$option});
    $state->{$option} = $in->{$option};
    delete($in->{$option});
    return 1;
}

sub _assert_options {
    my($options) = @_;
    # Validates result_ok, compute_params, and printer options.
    return {}
	unless $options;
    return {class_name => $options}
	if !ref($options) && $options;
    die('options not a hash_ref or class_name')
	unless ref($options) eq 'HASH';
    my($o) = {%$options};
    foreach my $c (@_ALL_OPTIONS) {
	next unless exists($o->{$c});
	die($c, ': option not a subroutine (code_ref)')
	    unless ref($o->{$c}) eq 'CODE'
		|| grep($c eq $_, @_PLAIN_OPTIONS);
	delete($o->{$c});
    }
    _die('unknown option(s) passed to new: ', join(' ', sort(keys(%$o))))
	if %$o;
    return $options;
}

sub _catch {
    return
	unless my $die = Bivio::Die->catch_quietly(@_);
    Bivio::Agent::Task->rollback(Bivio::Agent::Request->get_current)
        if UNIVERSAL::isa('Bivio::Agent::Request', 'Bivio::UNIVERSAL')
	&& UNIVERSAL::isa('Bivio::Agent::Task', 'Bivio::UNIVERSAL');
    return $die;
}

sub _compile {
    my($self, $objects) = @_;
    # Compiles @$objects into a linear list of tuples.
    my($state) = {
	object_num => 0,
	map(($_ => $self->unsafe_get($_)), @_CASE_OPTIONS),
    };
    _compile_assert_even($objects, $state);
    my(@objects) = @$objects;
    my($tests) = [];
    while (@objects) {
	_compile_object($self, $state, $tests, splice(@objects, 0, 2));
    }
    return $tests;
}

sub _compile_assert_array {
    my($value, $state) = @_;
    # Asserts value is an array_ref.
    _compile_die($state, 'value must be an array_ref')
	unless ref($value) eq 'ARRAY';
    return;
}

sub _compile_assert_even {
    my($value, $state) = @_;
    # Asserts value is an even length array_ref.
    _compile_assert_array($value, $state);
    _compile_die($state, 'value has uneven elements in array')
	unless int(@$value) % 2 == 0;
    _compile_die($state, 'value has no elements in array')
	unless int(@$value);
    return;
}

sub _compile_case {
    my($state, $tests, $params, $expect) = @_;
    # Parses a single case and pushes it on @$tests.
    $state->{case_num}++;
    $params = [$params]
	if defined($params) && !ref($params);
    _compile_die($state, 'params must be array_ref, Bivio::DieCode, or CODE')
	unless ref($params) =~ /^(ARRAY|CODE)$/;
    push(@$tests, my $case = Bivio::Test::Case->new({
	%$state,
	params => $params,
    }));
    $case->expect($expect);
    _trace($case) if $_TRACE;
    return;
}

sub _compile_die {
    my($state, @msg) = @_;
    # Calls _die() with msg and state of compilation.
    _die('Error compiling ', ref($state) eq 'HASH'
	? Bivio::Test::Case->new({%$state}) : $state, ': ', @msg);
    # DOES NOT RETURN
}

sub _compile_method {
    my($state, $tests, $method, $cases) = @_;
    # Validates method and parses cases.
    $state = _compile_options($state, 'method', $method);
    $state->{comparator} ||= 'nested_differences';
    $method = $state->{method};
    if (ref($cases) eq 'ARRAY') {
	_compile_assert_even($cases, $state);
    }
    elsif (!ref($cases) || ref($cases) =~ /^(?:CODE|Regexp)$/
	|| UNIVERSAL::isa($cases, 'Bivio::DieCode')) {
	# Shortcut: scalar, construct the cases.  Handle undef as ignore case
	$cases = [
	    [] => defined($cases) ? ref($cases) ? $cases : [$cases] : undef,
	];
    }
    else {
	_compile_die($state,
	    'cases is not an ARRAY, CODE, Regexp, Bivio::DieCode, scalar or undef: ',
	    $cases);
    }
    my(@cases) = @$cases;
    $state->{case_num} = 0;
    while (@cases) {
	_compile_case($state, $tests, splice(@cases, 0, 2));
    }
    return;
}

sub _compile_object {
    my($self, $state, $tests, $object, $methods) = @_;
    # Validates $object and sets object info on state.  Compiles methods.
    $state = _compile_options($state, 'object', $object);
    if ($state->{class_name}) {
	$state->{create_object} = \&default_create_object
	    unless $state->{create_object};
    }
    if ($state->{create_object} || ref($state->{object}) eq 'CODE') {
	my($fields) = $self->[$_IDI];
	$state->{_eval_object} = @{$fields->{_eval_object} ||= []};
	push(@{$fields->{_eval_object}}, [
	    ref($state->{object}) eq 'CODE'
	       ? ($state->{object}, [])
	       : ($state->{create_object},
		   ref($state->{object}) eq 'ARRAY' ? $state->{object}
		   : !ref($state->{object}) ? [$state->{object}]
		   : _compile_die('object must be a scalar, ARRAY, or CODE',
		       $state->{object})),
	]);
	$state->{object} = undef;
	$state->{create_object} = undef;
    }
    elsif (!UNIVERSAL::isa($state->{object}, 'UNIVERSAL')) {
	_load_class($state)
	    if $state->{object} && $state->{object} =~ /(?:\:\:|\.)/;
	_compile_die($state, 'object is not a subclass of UNIVERSAL'
	    . ' (forgot to "use"?) or CODE: ', $state->{object})
	    unless UNIVERSAL::isa($state->{object}, 'UNIVERSAL');
    }
    $methods = [
	$methods => 1,
    ] if ref($methods) eq 'CODE';
    _compile_assert_even($methods, $state);
    $state->{method_num} = 0;
    my(@methods) = @$methods;
    while (@methods) {
	_compile_method($state, $tests, splice(@methods, 0, 2));
    }
    return;
}

sub _compile_options {
    my($state, $which, $entity_or_hash) = @_;
    # which is object, method, or case.  If entity_or_hash is a hash, the hash
    # is parsed for which and the attributes are copied.  Any extra attributes
    # cause an exception.  $which_num is incremented.
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
	foreach my $o (@_PLAIN_OPTIONS) {
	    _add_option($state, $h, $o);
	}
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

sub _default_print {
    # Prints its arguments to STDOUT.
    return print(@_);
}

sub _die {
    my(@msg) = @_;
    # Calls die for now.  Eventually, will tell more.
    Bivio::Die->die(@msg);
    # DOES NOT RETURN
}

sub _die_stack {
    my($actual) = @_;
    my($s) = Bivio::Die->is_blessed($actual) && $actual->unsafe_get('stack');
    return $s ? "\n-- begin stack --\n" . $s . "\n-- end stack --\n" : '';
}

sub _eval {
    my($self, $tests) = @_;
    # Runs the tests as returned from _compile().
    my($c) = 0;
    my($print) = $self->get_if_exists_else_put(
	print => sub {\&_default_print});
    $print->('1..' . int(@$tests) . "\n");
    my($err);
    my($results) = {
	failed => [],
	passed => [],
    };
    local($_SELF) = $self;
    local($_CASE);
    foreach my $case (@$tests) {
	$_CASE = $case;
	$c++;
	my($result);
	next unless _prepare_case($self, $case, \$err);
	my($die) = _catch(sub {
	    _trace($case) if $_TRACE;
	    $result = [$case->unsafe_get('want_scalar')
	        ? scalar(_eval_method($case)) : _eval_method($case)];
	    return;
	});
	_trace('returned ', $die || $result) if $_TRACE;
	if ($die) {
	    $case->put(
		die_code => $die->get('code'),
		die => $die,
	    );
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
	push(@{$results->{$err ? 'failed' : 'passed'}}, $c);
	$print->($err
	    ? "not ok $c " . $case->as_string . ": $err\n"
	    : "ok $c\n");
	$err = undef;
    }
    $self->put(%$results);
    $print->(
	$self->format_results(scalar(@{$results->{passed}}), int(@$tests)),
    );
    return $self;
}

sub _eval_compute_return {
    my($case, $return) = @_;
    # Calls compute_return if there is a compute_return on the case, and
    # $return is an array_ref.
    return undef
	unless ref($$return) eq 'ARRAY' && $case->unsafe_get('compute_return');
    my($err);
    my($new_return) = _eval_custom(
	$case,
	'compute_return',
	[$$return, $case->get('expect')],
	\$err,
    );
    _trace($err || $new_return) if $_TRACE;
    return $err
	unless $new_return;
    $case->put(return => $$return = $new_return);
    return undef;
}

sub _eval_custom {
    my($case, $which, $params, $err) = @_;
    # Returns result of custom call $which (check_return or compute_params).
    # If there is an error, $err will be set.  Checks for appropriate return
    # result in case of compute_params.
    #
    # $params only needs extra params for check_return only.
    my($res);
    my($die) = _catch(sub {
	$res = $case->get($which)->($case, @$params);
	return undef;
    });
    if ($die) {
	$$err = "Error in custom $which: " . $die->as_string . _die_stack($die);
	return undef;
    }
    if ($which =~ /params/ && ref($res) ne 'ARRAY') {
	$$err = 'an array_ref';
    }
    elsif ($which =~ /object/
        && !(UNIVERSAL::isa($res, 'UNIVERSAL')
            || ($res || '') eq __PACKAGE__->IGNORE_RETURN)
    ) {
	$$err = 'a subclass of UNIVERSAL (forgot to "use"?)';
    }
    elsif ($which eq 'compute_return' && ref($res) ne 'ARRAY') {
	$$err = 'an array_ref';
    }
    elsif ($which =~ /expect|check_return/
	&& (ref($res) ? ref($res) !~ /^(?:ARRAY|Regexp)$/
	    : defined($res) ? $res !~ /^[01]$/ : 1)) {
	$$err = 'an array_ref, Regexp, or boolean (0 or 1)';
    }
    elsif ($which =~ /die/
	&& (ref($res) ? !UNIVERSAL::isa($res, 'Bivio::DieCode')
	    : defined($res) ? $res !~ /^[01]$/ : 1)) {
	$$err = 'a Bivio::DieCode or boolean (0 or 1)';
    }
    else {
	return $res;
    }
    $$err = "$which did not return ${$err}: "
	. Bivio::IO::Ref->to_short_string($res);
    return undef;
}

sub _eval_method {
    my($case) = @_;
    # Calls the method based on whether it is a sub or not.
    my($method) = $case->get('method');
    return ref($method) eq 'CODE'
	? $method->($case, $case->get('object'), @{$case->get('params')})
	    : $case->get('object')->$method(@{$case->get('params')});
}

sub _eval_object {
    my($self, $case, $err) = @_;
    # Returns true if eval worked.  Objects are cached.
    return $case->get('object')
	unless defined(my $e = $case->unsafe_get('_eval_object'));
    my($fields) = $self->[$_IDI];
    my($object) = $fields->{_eval_object}->[$e];
    unless (defined($object)) {
	$$err = 'prior create_object call failed';
	return 0;
    }
    if (ref($object) eq 'ARRAY') {
	my($code, $param) = @$object;
	# Try to load: If it fails, then
	unless (_load_class($case)) {
	    $$err = 'unable to load package ' . $case->get('class_name');
	}
	else {
	    $case->put(create_object => $code);
	    $fields->{_eval_object}->[$e] = $object
		= _eval_custom($case, 'create_object', [$param], $err);
	}
	return 0 if $$err;
    }
    $case->put(object => $object);
    return 1;
}

sub _eval_params {
    my($case, $err) = @_;
    # Returns true if eval worked.
    foreach my $custom (qw(params compute_params)) {
	next unless ref($case->unsafe_get($custom)) eq 'CODE';
	my($res) = _eval_custom(
	    $case, $custom, [$case->get(qw(params method object))], $err);
	return 0 if $$err;
	$case->put(params => $res);
	last;
    }
    return 1;
}

sub _eval_result {
    my($case, $actual) = @_;
    # Calls the custom method, if need be.
    # Assumes type of result was already verified.
    my($custom);
    my($show);
    my($result, $actual_which) = ref($actual) eq 'Bivio::Die'
	? ($actual->get('code'), 'die_code') : ($actual, 'return');
    my($expect_which) = UNIVERSAL::isa($case->get('expect'), 'Bivio::DieCode')
	? 'die_code' : 'return';
    if ($expect_which eq 'return') {
	my($err) = _eval_compute_return($case, \$actual);
	return $err
	    if $err;
	$result = $actual;
    }
    if (ref($case->get('expect')) eq 'CODE') {
	# Only on success do we eval a case-specific check_return
	$custom = 'expect'
	    if ref($actual) eq 'ARRAY';
    }
    elsif ($actual_which eq $expect_which) {
	$custom = "check_$expect_which";
	$custom = undef
	    unless $case->unsafe_get($custom);
    }
    if ($custom) {
#TODO: Move off to separate method
	my($err) = undef;
	my($res) = _eval_custom(
	    $case,
	    $custom, [$actual, $case->get('expect')],
	    \$err,
	);
	_trace($case, ' ', $custom, ' returned: ', $res) if $_TRACE;
	return $err
	    if $err;
	$custom = 'check_return'
	    if $custom eq 'expect';
	$custom =~ s/^check_//;
	if (ref($res)) {
	    # New value for return or die, save and compare
	    $case->expect($res);
	    $result = $case->get($custom);
	}
	else {
	    return $res ? undef
		: "check_$expect_which returned false for result: "
		    . Bivio::IO::Ref->to_short_string(
			$case->get($actual_which));

	}
    }
    my($e) = $case->get('expect');
    if (ref($e) eq 'CODE') {
	return "unexpected die: " . Bivio::IO::Ref->to_short_string($result)
	    . _die_stack($actual);
    }
    my($x);
    my($comparator) = $case->get('comparator');
    my($diff_die) = _catch(sub {
        $x = Bivio::IO::Ref->$comparator(
	    $e,
	    ref($result) eq 'ARRAY' && @$result == 1 && ref($e) eq 'Regexp'
		? $result->[0] : $result,
	);
    });
    return $diff_die ? "$comparator died: " . $diff_die->as_string
	: $x ? $$x . _die_stack($actual)
	: undef;
}

sub _load_class {
    my($thing) = @_;
    my($is_hash) = !Bivio::UNIVERSAL->is_blessed($thing);
    my($c) = $is_hash ? $thing->{object} : $thing->unsafe_get('class_name');
    return 1
	unless $c;
    return 0
	unless $c = Bivio::IO::ClassLoader->unsafe_map_require($c);
    $is_hash ? $thing->{object} = $c : $thing->put(class_name => $c);
    return 1;
}

sub _prepare_case {
    my($self, $case, $err) = @_;
    # Returns false if err.  Calls _eval_object_or_params and
    # then checks method.
    return 0
	unless _eval_object($self, $case, $err) && _eval_params($case, $err);
    if ($case->unsafe_get('method_is_autoloaded')
	|| UNIVERSAL::can($case->get('object'), $case->get('method'))
	|| ref($case->get('method')) eq 'CODE'
    ) {
        $_HANDLERS->call_fifo(handle_prepare_case => [$case]);
	return 1;
    }
    my($o) = $case->get('object');
    $$err = $case->get('method') . ': not implemented by ' . (ref($o) || $o)
	unless $o eq __PACKAGE__->IGNORE_RETURN;
    return 0;
}

1;
