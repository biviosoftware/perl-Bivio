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

#=IMPORTS
use Bivio::Biz::Model;
use Carp;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string name) : Bivio::Biz::PropertyModel

Creates a PropertyModel with the specified class configuration.

=over 4

=item model_name : string

The lookup name of the model.

=item property_cfg : hash

A hash of property attributes. Format:
    {
        property-name => ['caption', field-descriptor]
        ...
    }

    ex.
	property_cfg => {
	    id => ['Internal ID',
		    Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
	    name => ['User ID',
		    Bivio::Biz::FieldDescriptor->lookup('STRING', 32)],
	    password => ['Password',
		    Bivio::Biz::FieldDescriptor->lookup('STRING', 32)]
	    }

=cut

sub new {
    my($proto, $class_cfg) = @_;
    $class_cfg || Carp::croak("missing class configuration");
    my($self) = &Bivio::Biz::Model::new($proto, $class_cfg->{model_name});

    my($property_cfg) = $class_cfg->{property_cfg};
    my($properties) = {};
    foreach (keys(%{$property_cfg})) {
	$properties->{$_} = undef;
    }
    $self->{$_PACKAGE} = {
	class_cfg => $class_cfg,
	properties => $properties
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get"></a>

=head2 get(string name) : scalar or CompoundField

Returns the value of the named property. This value may be a scalar for
simple types, or and instance or CompoundField for complex types.

=cut

sub get {
    my($self, $name) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($properties) = $fields->{properties};

    exists($properties->{$name}) || die("unknown property $name");
    return $properties->{$name};
}

=for html <a name="get_field_caption"></a>

=head2 get_field_caption(string name) : string

Returns the caption for the named field.

=cut

sub get_field_caption {
    my($self, $name) = @_;
    return &_get_property_cfg_value($self, $name, 0);
}

=for html <a name="get_field_descriptor"></a>

=head2 get_field_descriptor(string name) : FieldDescriptor

Returns the descriptor for the named field.

=cut

sub get_field_descriptor {
    my($self, $name) = @_;
    return &_get_property_cfg_value($self, $name, 1);
}

=for html <a name="get_fields_names"></a>

=head2 get_fields_names() : array

Returns an array of field names.

=cut

sub get_fields_names {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return \keys(%{$fields->{properties}});
}

=for html <a name="internal_get_fields"></a>

=head2 protected internal_get_fields() : hash

Returns the contents of the property hash. Only subclasses may call this
method (enforced).

=cut

sub internal_get_fields {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    caller(0)->isa($_PACKAGE) || Carp::croak("protected method");
    return $fields->{properties};
}

#=PRIVATE METHODS

# _get_property_cfg_value(string name, int index) : any
#
# Returns the value at the specified index of the named property's
# configuration
#
sub _get_property_cfg_value {
    my($self, $name, $index) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($property_cfg) = $fields->{class_cfg}->{property_cfg}->{$name};
    $property_cfg || die("unknown property $name");
    return $property_cfg->[$index];
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
