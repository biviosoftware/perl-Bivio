# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::PropertyModel;
use strict;
$Bivio::Biz::PropertyModel::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::PropertyModel - An abstract model with a set of named elements

=head1 SYNOPSIS

    my($model) = ...;

    if ($model->load(Bivio::Biz::FindParams->new({'id' => 500}))) {
        for (@{$model->get_field_names()}) {
            print($_.' = '.$model->get($_)."\n");
        }
    }

    for (0..100) {
        $model->create({'id' => $_, 'foo' => 'xxx'});
    }

=cut

=head1 EXTENDS

L<Bivio::Biz::Model>

=cut

use Bivio::Biz::Model;
@Bivio::Biz::PropertyModel::ISA = qw(Bivio::Biz::Model);

=head1 DESCRIPTION

C<Bivio::Biz::PropertyModel> is the complement to L<Bivio::Biz::ListModel>
and represents a row of data from storage. Each field is accessed by
name using the L<"get"> method. Field type information is available
by invoking L<"get_field_descriptor">. PropertyModel has serveral abstract
lifecycle methods for interacting with storage: L<"create">, L<"delete">,
and L<"update">.

In general a new instance of a PropertyModel is uninitialized until a
subsequent L<Bivio::Biz:Model/"find"> or L<"create"> is invoked. This
allows for a single instance of a model to be reused with different
data.

=cut

#=IMPORTS
use Carp;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string name, hash property_info) : Bivio::Biz::PropertyModel

Creates a PropertyModel with the specified name and property information.
property_info should have the format:
    {
        'property-name' => ['caption', field-descriptor]
        ...
    }

    ex.
    {
	'id' => ['Internal ID',
	      Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
	'name' => ['User ID',
	      Bivio::Biz::FieldDescriptor->lookup('STRING', 32)],
	'password' => ['Password',
	      Bivio::Biz::FieldDescriptor->lookup('STRING', 32)]
    }

=cut

sub new {
    my($proto, $name, $property_info) = @_;
    my($self) = &Bivio::Biz::Model::new($proto, $name);
    my($properties) = {};
    foreach (keys(%{$property_info})) {
	$properties->{$_} = undef;
    }
    $self->{$_PACKAGE} = {
	'property_info' => $property_info,
	'properties' => $properties
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 abstract create(hash new_values) : boolean

Creates a new model in the database with the specified value. After creation,
this instance has the same values. Returns 1 if successful, 0 otherwise. If
creation fails, then L<Bivio::Biz::Model/"get_status"> should return errors.

=cut

sub create {
    die("abstract method");
}

=for html <a name="delete"></a>

=head2 abstract delete() : boolean

Deletes the current model from the database. Returns 1 if successful,
0 otherwise.

=cut

sub delete {
    die("abstract method");
}

=for html <a name="get"></a>

=head2 get(string name) : scalar or array

Returns the value of the named property. This value may be a scalar for
simple types, or array for complex types. Property names are exported
throught the L<"get_field_names"> method.

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
    return &_get_property_info_value($self, $name, 0);
}

=for html <a name="get_field_descriptor"></a>

=head2 get_field_descriptor(string name) : FieldDescriptor

Returns the descriptor for the named field. See L<Bivio::Biz::FieldDescriptor>.

=cut

sub get_field_descriptor {
    my($self, $name) = @_;
    return &_get_property_info_value($self, $name, 1);
}

=for html <a name="get_field_names"></a>

=head2 get_field_names() : array

Returns an array of field names.

=cut

sub get_field_names {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my(@names) = keys(%{$fields->{properties}});
    return \@names;
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

=for html <a name="update"></a>

=head2 abstract update(hash new_values) : boolean

Updates the current model's values. Returns 1 if successful 0 otherwise.
Errors are stored in the Model's status.

=cut

sub update {
    die("abstract method");
}

#=PRIVATE METHODS

# _get_property_info_value(string name, int index) : any
#
# Returns the value at the specified index of the named property's
# configuration

sub _get_property_info_value {
    my($self, $name, $index) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($property_info) = $fields->{property_info}->{$name};
    $property_info || die("unknown property $name");
    return $property_info->[$index];
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
