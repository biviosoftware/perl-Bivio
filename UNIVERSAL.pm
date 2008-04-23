# Copyright (c) 1999-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UNIVERSAL;
use strict;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_R, $_SA);

sub as_string {
    # Returns the string form of I<self>.  By default, this is just I<self>.
    return shift(@_) . '';
}

sub call_super {
    my($proto) = shift;
    my($package, $method, $args) = $_[0] =~ /^[a-z]\w*$/
	? ($proto->package_name, @_)
	: @_;
    my($sub) = $package->super_for_method($method);
    return $sub->($proto, $args ? @$args : ());
}

sub call_super_before {
    my($proto, $args, $op) = @_;
    my($sub) = (caller(0))[0]->super_for_method($proto->my_caller);
    my($super) = [$sub->($proto, @$args)];
    my($my) = $op->($proto, $args, $super) || $super;
    return wantarray ? @$my : $my->[0];
}

sub clone {
    my($self) = @_;
    return bless(
	[map(($_R ||= $self->use('IO.Ref'))->nested_copy($_), @$self)],
	ref($self),
    );
}

sub code_ref_for_subroutine {
    my($proto, $name) = @_;
    $name = $proto->package_name . '::' . $name;
    do {
	no strict 'refs';
	return
	    unless defined(&$name);
    };
    return \&$name;
}

sub delegate_method {
    my($proto) = shift;
    my($method) = $proto->my_caller;
    return shift->$method(\&delegate_method, $proto, @_);
}

sub delegated_args {
    my($proto) = shift;
    return ($proto, @_)
	unless ref($_[0]) && $_[0] == \&delegate_method;
    shift;
    return (@_);
}

sub delegated_package {
    # Call stack is: <delegated method>, delegate_method(), <delegating method>
    return (caller(2))[0];
}

sub die {
    shift;
    Bivio::Die->throw_or_die(@_);
    # DOES NOT RETURN
}

sub equals {
    my($self, $that) = @_;
    # Returns true if I<self> is identical I<that>.
    return $self eq $that ? 1 : 0;
}

sub grep_methods {
    my($proto, $to_match) = @_;
    no strict 'refs';
    return ($_SA ||= $proto->use('Type.StringArray'))->sort_unique([
	map($_ =~ $to_match ? defined($+) ? $+ : $_ : (),
	    map(keys(%{*{$_ . '::'}}),
	        $proto->package_name,
		@{$proto->inheritance_ancestors}))]);
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
    my($proto) = @_;
    no strict 'refs';
    return ${$proto->use('Bivio::IO::File')->read(
	\${$proto->package_name . '::'}{DATA})};
}

sub is_blessed {
    my($proto, $value, $object) = @_;
    $object ||= $proto;
    my($v) = $value;
    return ref($value) && $v =~ /=/ && $value->isa(ref($object) || $object)
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

sub map_by_two {
    my(undef, $op, $values) = @_;
    $values ||= [];
    return [map(
	$op->($values->[2 * $_], $values->[2 * $_ + 1]),
	0 .. int((@$values + 1) / 2) - 1,
    )];
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

sub my_caller {
    # IMPLEMENTATION RESTRICTION: Does not work for evals.
    return ((caller(2))[3] =~ /([^:]+)$/)[0];
}

sub name_parameters {
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

sub package_version {
    {
	no strict 'refs';
	return ${\${shift->package_name . '::VERSION'}};
    };
}

sub req {
    my($proto) = shift;
    my($req) = ref($proto) && $proto->can('get_request') && $proto->get_request
	|| Bivio::Agent::Request->get_current
	|| Bivio::Die->die('no request');
    return @_ ? $req->get_nested(@_) : $req
}

sub simple_package_name {
    return (shift->package_name =~ /([^:]+$)/)[0];
}

sub super_for_method {
    my($proto, $method) = @_;
    $method ||= $proto->my_caller;
    foreach my $a (@{$proto->inheritance_ancestors}) {
	if (my $sub = $a->code_ref_for_subroutine($method)) {
	    return ($sub, $a);
	}
    }
    Bivio::Die->die($method, ': not implemented by SUPER of ', $proto->package_name);
    # DOES NOT RETURN
}

sub use {
    shift;
    return Bivio::IO::ClassLoader->map_require(@_);
}

1;
