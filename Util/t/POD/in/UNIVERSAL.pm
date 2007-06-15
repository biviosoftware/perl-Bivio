# Copyright (c) 1999-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UNIVERSAL;
use strict;
$Bivio::UNIVERSAL::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
# $_ = $Bivio::UNIVERSAL::VERSION;

=head1 NAME

Bivio::UNIVERSAL - base class for all bivio classes

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UNIVERSAL;

=cut

=head1 DESCRIPTION

C<Bivio::UNIVERSAL> is the base class for all bivio classes.  All of the
methods defined here may be overriden.

Please note the example use of L<new|"new">.

=cut

#=VARIABLES

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string name) : Bivio::UNIVERSAL

Creates and blesses the object.

This is how you should always create objects:

    my($_IDI) = __PACKAGE__->instance_data_index;

    sub new {
        my($proto) = shift;
        my($self) = $proto->SUPER::new(@_);
	$self->[$_IDI] = {'field1' => 'value1'};
	return $self;
    }

All instances in Bivio's object space use this form.  This is the
only "bless" in the system.  There are several advantages of this.
Firstly, bless is inefficient and reblessing is an unnecessary
operation.  Secondly, all object creations go through this one
method, so we can track object allocations by adding just a little
bit of code.  Finally, the instance data name space is managed
effectively.  See L<instance_data_index|"instance_data_index"> for
more details.

You can assign anything to your class's part of the instance data array.
If you are concerned about performance, consider arrays or pseudo-hashes.

=cut

sub new {
    my($proto) = @_;
    return bless([], ref($proto) || $proto);
}

=head1 METHODS

=cut

=for html <a name="as_string"></a>

=head2 as_string() : string

Returns the string form of I<self>.  By default, this is just I<self>.

=cut

sub as_string {
    return shift(@_) . '';
}

=for html <a name="die"></a>

=head2 static die(any die_code, hash_ref attrs)

=head2 static die(string arg1, ...)

A convenient alias for L<Bivio::Die::throw_or_die|Bivio::Die/"throw_or_die">

=cut

sub die {
    shift;
    Bivio::Die->throw_or_die(@_);
    # DOES NOT RETURN
}

=for html <a name="equals"></a>

=head2 equals(UNIVERSAL that) : boolean

Returns true if I<self> is identical I<that>.

=cut

sub equals {
    my($self, $that) = @_;
    return $self eq $that ? 1 : 0;
}

=for html <a name="grep_methods"></a>

=head2 static grep_methods(regexp to_match) : array_ref

Returns list of methods that match I<to_match>.  If a match is found, returns
$+ (last matching paren) if defined, otherwise returns complete method name.

=cut

sub grep_methods {
    my($proto, $to_match) = @_;
    no strict 'refs';
    return $proto->use('Type.StringArray')->sort_unique([
	map($_ =~ $to_match ? defined($+) ? $+ : $_ : (),
	    map(keys(%{*{$_ . '::'}}),
	        $proto->package_name,
		@{$proto->inheritance_ancestors}))]);
}

=for html <a name="inheritance_ancestors"></a>

=head2 inheritance_ancestors() : array_ref

Returns list of anscestors of I<class>, closest ancestor is at index 0.
Asserts single inheritance.  Must be descended from this class.

=cut

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

=for html <a name="instance_data_index"></a>

=head2 static final instance_data_index() : int

Returns the index into the instance data.  Usage:

    my($_IDI) = __PACKAGE__->instance_data_index;

    sub some_method {
	my($self) = @_;
	my($fields) = $self->[$_IDI];
	...
    }

=cut

sub instance_data_index {
    my($pkg) = @_;
    # Some sanity checks, since we don't access this often
    CORE::die('must call statically from package body')
	unless $pkg eq (caller)[0];
    # This class doesn't have any instance data.
    return @{$pkg->inheritance_ancestors} - 1;
}

=for html <a name="internal_data_section"></a>

=head2 static internal_data_section() : string_ref

Reads the __DATA__ section of $proto.

=cut

sub internal_data_section {
    my($proto) = @_;
    no strict 'refs';
    return ${$proto->use('Bivio::IO::File')->read(
	\${$proto->package_name . '::'}{DATA})};
}

=for html <a name="is_blessed"></a>

=head2 static final is_blessed(any value, any object) : boolean

Returns true if I<value> is a blessed reference.  If I<object> supplied,
then test if I<value> isa I<object>.

=cut

sub is_blessed {
    my(undef, $value, $object) = @_;
    my($v) = $value;
    return ref($value) && $v =~ /=/
	&& (!$object || $value->isa(ref($object) || $object)) ? 1 : 0;
}

=for html <a name="map_by_two"></a>

=head2 static map_by_two(code_ref op, array_ref values) : array_ref

Passes I<values> two by two to I<op>.  Returns cummulative results
of I<op>.  If array is odd, last element will be C<undef>.

=cut

sub map_by_two {
    my(undef, $op, $values) = @_;
    $values ||= [];
    return [map(
	$op->($values->[2 * $_], $values->[2 * $_ + 1]),
	0 .. int((@$values + 1) / 2) - 1,
    )];
}

=for html <a name="map_invoke"></a>

=head2 static map_invoke(string method, array_ref repeat_args, array_ref first_args, array_ref last_args) : array_ref

=head2 static map_invoke(code_ref method, array_ref repeat_args, array_ref first_args, array_ref last_args) : array_ref

Calls I<method> on I<self> with each element of I<args>.  If I<method> is a
ref, will call the sub.

If the element of I<repeat_args> is an array, it will be unrolled as its
arguments.  Otherwise, the individual argument is called.  For example,

    $math->map_invoke('add', [[1, 2], [3, 4]])

returns

    [3, 7]

while

    $math->map_invoke('add', [2, 3], [1])

returns

    [3, 4]

and

    $math->map_invoke('sub', [2, 3], undef, [1])

returns

    [1, 2]

If I<method> takes a single array_ref as an argument, you need to wrap it
twice, e.g.

    $string->map_invoke('concat', [[['a', 'b'], ['c', 'd']]])

returns

    ['ab', 'cd']

Result is always called in an array context.

=cut

sub map_invoke {
    my($proto, $method, $repeat_args, $first_args, $last_args) = @_;
    return [map(
	ref($method) ? $method->(@$_) : $proto->$method(@$_),
	map([
	    $first_args ? @$first_args : (),
	    ref($_) eq 'ARRAY' ? @$_ : $_,
	    $last_args ? @$last_args : (),
	], @$repeat_args),
    )];
}

=for html <a name="my_caller"></a>

=head2 static my_caller() : string

Returns method (or simple subroutine) name of caller immediately before the
caller of this routine.

IMPLEMENTATION RESTRICTION: Does not work for evals.

=cut

sub my_caller {
    return ((caller(2))[3] =~ /([^:]+)$/)[0];
}

=for html <a name="name_parameters"></a>

=head2 static name_parameters(array_ref names, array_ref argv) : (self, hash_ref)

Expects I<names> to be the keys in the first and only element of I<argv>, or
uses I<names> to convert positional I<argv> into hash_ref.  Does not work if
first positional parameter is allowed to be a hash_ref.

Returns (self, named).

=cut

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

=for html <a name="package_name"></a>

=head2 static package_name() : string

Returns the package name for the class being called.

=cut

sub package_name {
    my($proto) = @_;
    return ref($proto) || $proto;
}

=for html <a name="package_version"></a>

=head2 static package_version() : float

Returns the value of the C<$VERSION> variable for I<proto>.  Will die
if no such version.

=cut

sub package_version {
    {
	no strict 'refs';
	return ${\${shift->package_name . '::VERSION'}};
    };
}

=for html <a name="simple_package_name"></a>

=head2 static simple_package_name() : string

Returns the package name sans directory prefixes, e.g. the simple package
name for this class is C<UNIVERSAL>.

=cut

sub simple_package_name {
    return (shift->package_name =~ /([^:]+$)/)[0];
}

=for html <a name="use"></a>

=head2 static use(string package, ...) : string

An convenient alias for map_require (Bivio::IO::ClassLoader).

=cut

sub use {
    shift;
    return Bivio::IO::ClassLoader->map_require(@_);
}

#=PRIVATE METHODS

=head1 SEE ALSO

C<UNIVERSAL>

=head1 COPYRIGHT

Copyright (c) 1999-2007 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
