# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::PropertyModel;
use strict;
$Bivio::Biz::PropertyModel::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Biz::PropertyModel - An abstract model with a set of named elements

=head1 SYNOPSIS

    use Bivio::Biz::PropertyModel;
    Bivio::Biz::PropertyModel->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::Model>

=cut

@Bivio::Biz::PropertyModel::ISA = qw(Bivio::Biz::Model);

=head1 DESCRIPTION

C<Bivio::Biz::PropertyModel>

=cut

=head1 CONSTANTS

=cut

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string name) : Bivio::Biz::PropertyModel

Creates a PropertyModel with the specified name.

=cut

sub new {
    my($proto, $name) = @_;
    my($self) = &Bivio::Biz::Model::new($proto, $name);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get"></a>

=head2 abstract get(string name) : scalar or CompoundField

Returns the value of the named property. This value may be a scalar for
simple types, or and instance or CompoundField for complex types.

=cut

sub get {
    die("abstract method");
}

=for html <a name="get_field_caption"></a>

=head2 get_field_caption(string name) : string

Returns the caption for the named field.

=cut

sub get_field_caption {
    die("abstract method");
}

=for html <a name="get_field_descriptor"></a>

=head2 abstract get_field_descriptor(string name) : FieldDescriptor

Returns the descriptor for the named property.

=cut

sub get_field_descriptor {
    die("abstract method");
}

=for html <a name="get_fields_names"></a>

=head2 get_fields_names() : array

Returns an array of field names.

=cut

sub get_fields_names {
    die("abstract method");
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
