# Copyright (c) 1999-2013 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UNIVERSAL;
use strict;

my($_A, $_R, $_SA, $_P, $_CL);
my($_CLASSLOADER_MAP_NAME) = {};

sub CLASSLOADER_MAP_NAME {
    my($proto) = @_;
    my($pkg) = $proto->package_name;
    return $_CLASSLOADER_MAP_NAME->{$pkg}
	||= _classloader()->unsafe_map_for_package($pkg);
}

sub as_classloader_map_name {
    my($proto) = @_;
    return ($proto->CLASSLOADER_MAP_NAME || return $proto->package_name)
	. '.'
	. $proto->simple_package_name;
}

sub as_classloader_mapped_package {
    my($proto) = @_;
    return $proto->use($proto->as_classloader_map_name);
}

sub as_req_key_value_list {
    my($proto) = @_;
    my($pkg) = $proto->package_name;
    return (
	$proto->as_classloader_map_name => $proto,
	$pkg => $proto,
    );
}

sub as_string {
    my($self) = @_;
    return "$self"
	unless $self->can('internal_as_string');
    my($p) = $self->simple_package_name;
    return $p
	unless ref($self);
    # Don't recurse more than two levels in calls to this sub.  We
    # look back an arbitrary number of levels (10), because there's
    # nesting inside Alert->format_args.
    my($this_sub) = (caller(0))[3];
    my($recursion) = 0;
    for (my($i) = 1; $i < 20; $i++) {
	my($sub) = (caller($i))[3];
	last unless $sub;
	return "$p(...)"
	    if $this_sub eq $sub && ++$recursion >= 1;
    }
    my(@cfg) = map(($_, ','), $self->internal_as_string);
    pop(@cfg);
    my($res) = ($_A ||= $self->use('IO.Alert'))
	->format_args($p, @cfg ? ('(', @cfg, ')') : ());
    chomp($res);
    return $res;
}

sub b_can {
    my($proto, $method, $object) = @_;
    $object ||= $proto;
    return defined($method) && !ref($method)
	&& __PACKAGE__->is_super_of($object) && $object->can($method) ? 1 : 0;
}

sub boolean {
    return $_[1] ? 1 : 0;
}

sub call_and_do_after {
    my($proto, $op_or_method, $args, $do_after) = @_;
    my($op) = sub {ref($op_or_method) ? $op_or_method->(@$args) : $proto->$op_or_method(@$args)};
    if (wantarray) {
	my($res) = [$op->()];
	$do_after->($res, 1);
	return @$res;
    }
    if (defined(wantarray)) {
	my($res) = scalar($op->());
	$do_after->(\$res, 0);
	return $res;
    }
    $op->();
    $do_after->(undef, undef);
    return;
}

sub clone {
    my($self) = @_;
    return $self
	if $self->clone_return_is_self;
    $_R ||= $self->use('IO.Ref');
    my($clone) = bless([], ref($self));
    $_R->nested_copy_notify_clone($self, $clone);
    @$clone = map($_R->nested_copy($_), @$self);
    return $clone;
}

sub clone_return_is_self {
    return 0;
}

sub delegate_method {
    my($delegator, $delegate) = (shift, shift);
#     my($args) = [$proto->delegated_args(@_)];
#     # remove $delegate (see delegated_args)
#     shift(@$args);
#     return shift->$method(\&delegate_method, @$args);
    my($delegation) = $delegate->use('Bivio.Delegation')->new(
	$delegate, $delegator);
    my($method) = $delegation->get('method');
    return $delegate->$method(
	\&delegate_method,
	$delegation,
	$delegator,
	@_,
    );
}

sub delegated_args {
    my($delegate) = shift;
    return (
	$delegate->use('Bivio.Delegation')->new($delegate, $delegate),
	$delegate,
	@_,
    ) unless ref($_[0]) && $_[0] == \&delegate_method;
    shift;
    return @_;
}

sub delete_from_req {
    my($self, $req) = @_;
    # Also deletes instance as string so just reuse as_req_key_value_list
    $req->delete($self->as_req_key_value_list);
    return;
}

sub die {
    shift;
    Bivio::Die->throw_or_die(
	Bivio::IO::Alert->calling_context,
	@_,
    );
    # DOES NOT RETURN
}

sub do_by_two {
    my(undef, $op, $values) = @_;
    foreach my $i (0 .. int((@$values + 1) / 2) - 1) {
	last
	    unless $op->($values->[2 * $i], $values->[2 * $i + 1], $i);
    }
    return;
}

sub equals {
    my($self, $that) = @_;
    # Returns true if I<self> is identical I<that>.
    return $self eq $that ? 1 : 0;
}

sub equals_class_name {
    my($proto, $class) = @_;
    return $proto->boolean(
	$proto->is_simple_package_name($class)
	    ? $proto->simple_package_name eq $class
	    : _classloader()->is_valid_map_class_name($class)
	    ? $proto->as_classloader_map_name eq $class
	    : $proto->package_name eq $class,
    );
}

sub global_variable_ref {
    my($proto, $var_name) = @_;
    no strict 'refs';
    return \${$proto->package_name . '::' . $var_name};
}

sub grep_methods {
    my($proto) = shift;
    return _grep_sub($proto, $proto->inheritance_ancestors, @_);
}

sub grep_subroutines {
    my($proto) = shift;
    return _grep_sub($proto, undef, @_);
}

sub if_then_else {
    my($proto, $condition, $then, $else) = @_;
    $then = 1
	unless @_ >= 3;
    return ref($then) eq 'CODE' ? $then->($proto) : $then
	if ref($condition) eq 'CODE' ? $condition->($proto) : $condition;
    return
	unless @_ >= 4;
    return ref($else) eq 'CODE' ? $else->($proto) : $else;
}

sub inheritance_ancestors {
    my($proto) = @_;
    my($class) = ref($proto) || $proto;
    CORE::die('not a subclass of Bivio::UNIVERSAL')
	unless $class->isa(__PACKAGE__);
    # Broken if called from Bivio::UNIVERSAL
    my($res) = [];
    while ($class ne __PACKAGE__) {
	my($isa) = do {
	    no strict 'refs';
	    \@{$class . '::ISA'};
	};
	CORE::die($class, ': does not define @ISA')
	    unless @$isa;
	CORE::die($class, ': multiple inheritance not allowed; @ISA=', "@$isa")
	    unless int(@$isa) == 1;
	push(@$res, $class = $isa->[0]);
    }
    return $res;
}

sub instance_data_index {
    my($pkg) = @_;
    # Returns the index into the instance data.  Usage:
    #
    #     my($_IDI) = __PACKAGE__->instance_data_index;
    #
    #     sub some_method {
    # 	my($self) = @_;
    # 	my($fields) = $self->[$_IDI];
    # 	...
    #     }
    # Some sanity checks, since we don't access this often
    CORE::die('must call statically from package body')
	unless $pkg eq (caller)[0];
    # This class doesn't have any instance data.
    return @{$pkg->inheritance_ancestors} - 1;
}

sub internal_data_section {
    my($proto, $op) = @_;
    no strict 'refs';
    my($f) = $proto->use('IO.File');
    my($h) = \${$proto->package_name . '::'}{DATA};
    return $op ? $f->do_lines($h, $op) : ${$f->read($h)};
}

sub internal_verify_do_iterate_result {
    my($proto, $value) = @_;
    $proto->use('IO.Alert')->warn(
	$value,
	': handler must return 0 or 1; caller=',
	$proto->my_caller(1),
    ) unless defined($value) && $value =~ /^(?:0|1)$/;
    return $value;
}

sub is_blessed {
    return shift->is_blesser_of(@_);
}

sub is_blesser_of {
    my($proto, $value, $object) = @_;
    $object ||= $proto;
    my($v) = $value;
    return ref($value) && $v =~ /=/ && $object->is_super_of($value) ? 1 : 0;
}

sub is_private_method_name {
    my(undef, $method) = @_;
    return $method && $method =~ /^_/ ? 1 : 0;
}

sub is_simple_package_name {
    my(undef, $name) = @_;
    return $name =~ /^\w+$/ ? 1 : 0;
}

sub is_subclass {
    Bivio::IO::Alert->warn_deprecated('use is_super_of');
    return shift->is_super_of(@_);
}

sub is_super_of {
    my($proto, $other) = @_;
    return defined($other) && UNIVERSAL::isa($other, ref($proto) || $proto)
	? 1 : 0;
}

sub iterate_reduce {
    my($proto, $op, $values, $initial) = @_;
    my($start) = 0;
    unless (defined($initial)) {
	$initial = $values->[0];
	$start++;
    }
    foreach my $i ($start .. $#$values) {
	$initial = $op->($initial, $values->[$i]);
    }
    return $initial;
}

sub list_if_value {
    my($proto) = shift;
    return @{$proto->map_by_two(sub {
        my($k, $v) = @_;
	return defined($v) ? ($k, $v) : ();
    }, \@_)};
}

sub map_by_slice {
    my($self, $op, $values, $slice_size) = @_;
    $slice_size ||= 2;
    return [map(
	{
	    my($i) = $slice_size * $_;
	    $op->(
		@$values[$i .. ($i + $slice_size - 1)],
		$_,
	    );
	}
	0 .. int((@$values + 1) / $slice_size) - 1,
    )];
}

sub map_by_two {
    my($proto, $op, $values) = @_;
    unless (ref($values) eq 'ARRAY') {
	Bivio::IO::Alert->warn_deprecated('values must be an array ref');
	$values = [];
    }
    return $proto->map_by_slice($op, $values);
}

sub map_invoke {
    my($proto, $method, $repeat_args, $first_args, $last_args) = @_;
    # Calls I<method> on I<self> with each element of I<args>.  If I<method>
    # is a ref, will call the sub.
    #
    # If the element of I<repeat_args> is an array, it will be unrolled as its
    # arguments.  Otherwise, the individual argument is called.  For example,
    #
    #     $math->map_invoke('add', [[1, 2], [3, 4]])
    #
    # returns
    #
    #     [3, 7]
    #
    # while
    #
    #     $math->map_invoke('add', [2, 3], [1])
    #
    # returns
    #
    #     [3, 4]
    #
    # and
    #
    #     $math->map_invoke('sub', [2, 3], undef, [1])
    #
    # returns
    #
    #     [1, 2]
    #
    # If I<method> takes a single array_ref as an argument, you need to wrap it
    # twice, e.g.
    #
    #     $string->map_invoke('concat', [[['a', 'b'], ['c', 'd']]])
    #
    # returns
    #
    #     ['ab', 'cd']
    #
    # Result is always called in an array context.
    return [map(
	ref($method) ? $method->(@$_) : $proto->$method(@$_),
	map([
	    $first_args ? @$first_args : (),
	    ref($_) eq 'ARRAY' ? @$_ : $_,
	    $last_args ? @$last_args : (),
	], @$repeat_args),
    )];
}

sub map_together {
    my($proto, $op, @arrays) = @_;
    return [map({
	my($i) = $_;
	$op->(map($_->[$i], @arrays));
    } 0 .. $proto->max_number(map($#$_, @arrays)))];
}

sub max_number {
    my(undef, @values) = @_;
    my($max) = shift(@values);
    foreach my $v (@values) {
	$max = $v
	    if $max < $v;
    }
    return $max;
}

sub method_that_does_nothing {
    return;
}

sub my_caller {
    my(undef, $depth) = @_;
    # IMPLEMENTATION RESTRICTION: Does not work for evals.
    return ((caller(($depth || 0) + 2))[3] =~ /([^:]+)$/)[0];
}

sub name_parameters {
#TODO:    ($_A ||= __PACKAGE__->use('IO.Alert'))->warn_deprecated('use parameters');
    my($self, $names, $argv) = @_;
    my($map) = {map(($_ => 1), @$names)};
    my($named) = @$argv;
    if (ref($named) eq 'HASH') {
	Bivio::Die->die('Too many parameters: ', $argv)
	    unless @$argv == 1;
	Bivio::Die->die(
	    $named, ': unknown params passed to ',
	    (caller(1))[3], ', which only accepts ', $names,
	) if grep(!$map->{$_}, keys(%$named));
        # make a copy to avoid changing the caller's value
        $named = {%$named};
    }
    else {
#TODO: Use ?syntax for optional params
#TODO: Consider combining with SheelUtil->name_arguments
	Bivio::Die->die($argv, ': too many params passed to ', (caller(1))[3])
	    unless @$argv <= @$names;
	my(@x) = @$names;
	$named = {map((shift(@x) => $_), @$argv)};
    }
    return ($self, $named);
}

sub new {
    my($proto) = @_;
    # Creates and blesses the object.
    #
    # This is how you should always create objects:
    #
    #     my($_IDI) = __PACKAGE__->instance_data_index;
    #
    #     sub new {
    #         my($proto) = shift;
    #         my($self) = $proto->SUPER::new(@_);
    # 	$self->[$_IDI] = {'field1' => 'value1'};
    # 	return $self;
    #     }
    #
    # All instances in Bivio's object space use this form.  This is the
    # only "bless" in the system.  There are several advantages of this.
    # Firstly, bless is inefficient and reblessing is an unnecessary
    # operation.  Secondly, all object creations go through this one
    # method, so we can track object allocations by adding just a little
    # bit of code.  Finally, the instance data name space is managed
    # effectively.  See L<instance_data_index|"instance_data_index"> for
    # more details.
    #
    # You can assign anything to your class's part of the instance data array.
    # If you are concerned about performance, consider arrays or pseudo-hashes.
    return bless([], ref($proto) || $proto);
}

sub package_name {
    my($proto) = @_;
    return ref($proto) || $proto;
}

sub parameters {
    return ($_P ||= __PACKAGE__->use('Bivio.Parameters'))
	->process_via_universal(@_);
}

sub put_on_req {
    my($self, $req, $durable) = @_;
    Bivio::Die->die($self, ': self must be instance')
	unless ref($self);
    my($method) = $durable ? 'put_durable' : 'put';
    ($req || $self->req)->$method($self->as_req_key_value_list);
    return $self;
}

sub put_on_request {
    return shift->put_on_req(@_);
}

sub replace_subroutine {
    my($proto, $method, $code_ref) = @_;
    no strict 'refs';
    local($^W);
    # $proto->package_name does not work during import of Bivio::Base
    *{(ref($proto) || $proto) . '::' . $method} = $code_ref;
    return;
}

sub req {
    return _ureq(get_nested => @_);
}

sub return_scalar_or_array {
    my($proto) = shift;
    return wantarray ? @_
	: @_ <= 1 ? $_[0]
	: Bivio::Die->die(
	    $proto->my_caller,
	    ': method must be called in array context');
}

sub self_from_req {
    my($proto) = shift;
    return $proto->unsafe_self_from_req(@_)
	|| Bivio::Die->die($proto, ': not on request');

}

sub simple_package_name {
    return (shift->package_name =~ /([^:]+$)/)[0];
}

sub type {
    my($proto, $class) = (shift, shift);
    $class = $proto->use('Type', $class);
    return @_ ? $class->from_literal_or_die(@_) : $class;
}

sub unsafe_get_request {
    return __PACKAGE__->is_super_of('Bivio::Agent::Request')
	? __PACKAGE__->use('Agent.Request')->get_current : undef;
}

sub unsafe_self_from_req {
    my($proto, $req) = @_;
    # It's really unsafe_self_from_req_or_proto, but this is a common pattern.
    return $req ? $req->unsafe_get($proto->as_classloader_map_name)
	: $proto;
}

sub ureq {
    return _ureq(unsafe_get_nested => @_);
}

sub use {
    shift;
    return _classloader()->map_require(@_);
}

sub want_scalar {
    shift;
    return shift;
}

sub _classloader {
    return $_CL ||= Bivio::IO::ClassLoader->map_require('IO.ClassLoader');
}

sub _grep_sub {
    my($proto, $ancestors, $to_match) = @_;
    no strict 'refs';
    return ($_SA ||= $proto->use('Type.StringArray'))->sort_unique([
	map($_ =~ $to_match ? defined($+) ? $+ : $_ : (),
	    map(
		{
		    my($stab) = \%{$_ . '::'};
		    grep(
			!ref($stab->{$_}) && ref(*{$stab->{$_}}{CODE}) eq 'CODE',
			keys(%$stab),
		    );
		}
	        $proto->package_name,
		$ancestors ? @$ancestors : (),
	    ),
	),
    ]);
}

sub _ureq {
    my($method, $proto, @args) = @_;
    my($req) = ref($proto) && $proto->can('get_request') && $proto->get_request
	|| Bivio::Agent::Request->get_current
	|| Bivio::Die->die('no request');
    return @args ? $req->$method(@args) : $req
}

1;
