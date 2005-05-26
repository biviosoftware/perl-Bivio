# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
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

=for html <a name="equals"></a>

=head2 equals(UNIVERSAL that) : boolean

Returns true if I<self> is identical I<that>.

=cut

sub equals {
    my($self, $that) = @_;
    return $self eq $that ? 1 : 0;
}

=for html <a name="as_string"></a>

=head2 as_string() : string

Returns the string form of I<self>.  By default, this is just I<self>.

=cut

sub as_string {
    return shift(@_) . '';
}

=for html <a name="inheritance_ancestor_list"></a>

=head2 inheritance_ancestor_list() : array_ref

Returns list of anscestors of I<class>, closest ancestor is at index 0.
Asserts single inheritance.  Must be descended from this class.

=cut

sub inheritance_ancestor_list {
    my($proto) = @_;
    my($class) = ref($proto) || $proto;
    die('not a subclass of Bivio::UNIVERSAL')
	unless $class->isa(__PACKAGE__);
    # Broken if called from Bivio::UNIVERSAL
    my($res) = [];
    while ($class ne __PACKAGE__) {
	my($isa) = do {
	    no strict 'refs';
	    \@{$class . '::ISA'};
	};
	die($class, ': does not define @ISA') unless @$isa;
	die($class, ': multiple inheritance not allowed; @ISA=', "@$isa")
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
    die('must call statically from package body')
	unless $pkg eq (caller)[0];
    # This class doesn't have any instance data.
    return @{$pkg->inheritance_ancestor_list} - 1;
}

=for html <a name="mapcar"></a>

=head2 static mapcar(string method, array_ref args) : array_ref

Calls I<method> on I<self> with each element of I<args>.  If the element
of I<args> is an array, it will be unrolled as its arguments.  Otherwise,
the individual argument is called.  For example,

    $math->mapcar('add', [[1, 2], [3, 4]])

returns

    [3, 7]

while

    $math->mapcar('sqrt', [4, 9])

returns

    [2, 3]

If I<method> takes a single array_ref as an argument, you need to wrap it
twice, e.g.

    $string->mapcar('concat', [[['a', 'b'], ['c', 'd']]])

returns

    ['ab', 'cd']

Result is always called in a scalar context.

=cut

sub mapcar {
    my($proto, $method, $args) = @_;
    return [map($proto->$method(ref($_) eq 'ARRAY' ? @$_ : $_), @$args)];
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
    my($proto) = @_;
    $proto = ref($proto) || $proto;
    $proto =~ s/.*:://;
    return $proto;
}

#=PRIVATE METHODS

=head1 SEE ALSO

C<UNIVERSAL>

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
