# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UNIVERSAL;
use strict;
$Bivio::UNIVERSAL::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UNIVERSAL::VERSION;

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

Please note the example use of new.

=cut

#=VARIABLES

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string name) : Bivio::UNIVERSAL

Creates and blesses the object.

This is how you should always create objects:

    my($_PACKAGE) = __PACKAGE__;

    sub new {
	my($self) = MySuperClass::new(@_);
	$self->{$_PACKAGE} = {'field1' => 'value1'};
	return $self;
    }

All instances in Bivio's object space use this form.  This is the
only "bless" in the system.  There are several advantages of this.
Firstly, bless is inefficient and reblessing is an unnecessary
operation.  Secondly, all object creations go through this one
method, so we can track object allocations by adding just a little
bit of code.

=cut

sub new {
    my($proto) = @_;
    my($self) = {};
    bless($self, ref($proto) || $proto);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="equals"></a>

=head2 equals(UNIVERSAL that) : boolean

Returns true if I<self> is identical I<that>.

=cut

sub equals {
    my($self, $that) = @_;
    return $self == $that;
}

=for html <a name="as_string"></a>

=head2 as_string() : string

Returns the string form of I<self>.  By default, this is just I<self>.

=cut

sub as_string {
    my($self) = @_;
    # Ensure it is a string?
    return $self;
}

=for html <a name="package_name"></a>

=head2 static package_name() : string

Returns the package name for the class being called.

=cut

sub package_name {
    my($proto) = @_;
    return ref($proto) || $proto;
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
