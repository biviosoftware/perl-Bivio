# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::PropertyModel;
use strict;
$Bivio::Biz::PropertyModel::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::PropertyModel - An abstract model with a set of named elements

=head1 SYNOPSIS

    my($model) = ...;

    if ($model->load(id => 500)) {
        for (@{$model->get_field_names()}) {
            print($_.' = '.$model->get($_)."\n");
        }
    }

    for (1..100) {
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
use Bivio::Die;
use Bivio::DieCode;
use Carp ();

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
# Maps classes (models) to static class information in an hash_ref
my(%_CLASS_INFO);

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::Request req, hash property_info) : Bivio::Biz::PropertyModel

Creates a PropertyModel with the specified request and property information.
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

If this is the first time this class has been newed, calls
C<internal_initialize>.

=cut

sub new {
    my($proto, $req) = @_;
    Carp::croak('invalid request') unless ref($req);
    my($self) = &Bivio::Biz::Model::new($proto, $req);
    my($class) = ref($self);
    _initialize_class_info($class) unless $_CLASS_INFO{$class};
    my($ci) = $_CLASS_INFO{$class};
    my($properties) = {};
    local($_);
    foreach (keys(%{$ci->{property_info}})) {
	$properties->{$_} = undef;
    }
    $self->{$_PACKAGE} = {
	request => $req,
	properties => $properties,
	class_info => $ci,
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="as_string"></a>

=head2 as_string() : string

Pretty prints an identifier for this model.

=cut

sub as_string {
    my($self) = @_;
    my($ci) = $self->{$_PACKAGE}->{class_info};
    # All primary keys must be defined or just return ref($self).
    return ref($self) . '(' . join(',', map {
	return ref($self) unless defined($_);
	$_;
    } $self->get(@{$ci->{as_string_fields}})) . ')';
}

=for html <a name="create"></a>

=head2 abstract create(hash new_values)

Creates a new model in the database with the specified values. After creation,
this instance has the same values.  Dies on error.

=cut

sub create {
    my($self, $new_values) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{class_info}->{sql_support}->create(
	    $self, $fields->{properties}, $new_values);
    $self->get_request->put(ref($self), $self);
    return;
}

=for html <a name="delete"></a>

=head2 delete()

Deletes the current model from the database.   Dies on error.

=cut

sub delete {
    my($self) = @_;
#TODO: Should the fields be nulled?
    my($fields) = $self->{$_PACKAGE};
    my($ci) = $fields->{class_info};
    $ci->{sql_support}->delete($self, $ci->{primary_where},
	    $self->get(@{$ci->{primary_keys}}));
    return;
}

=for html <a name="get"></a>

=head2 get(string name) : (scalar or array)

Returns the value of the named properties. The values may be a scalar for
simple types, or array for complex types. Property names are exported
throught the L<"get_field_names"> method.

=cut

sub get {
    my($self, @names) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($properties) = $fields->{properties};
    my(@res) = map {
	Carp::croak("$_: unknown property") unless exists($properties->{$_});
	$properties->{$_};
    } @names;
    return @res if wantarray;
    Carp::croak('get not called in array context') unless int(@res) == 1;
    return $res[0];
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
#TODO: Cache the return result?
#TODO: Filter those fields which shouldn't be filled in.
    my($fields) = $self->{$_PACKAGE};
    my(@names) = keys(%{$fields->{properties}});
    return \@names;
}

=for html <a name="get_request"></a>

=head2 get_request() : Bivio::Agent::Request

Returns the request associated with this model.

=cut

sub get_request {
    my($fields) = shift->{$_PACKAGE};
    return $fields->{request};
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

=for html <a name="internal_initialize"></a>

=head2 abstract internal_initialize() : array_ref

B<FOR INTERNAL USE ONLY>.

Returns an array_ref of the property info, sql support, the primary
keys for this model.

=cut

sub internal_initialize {
    Carp::croak('abstract method');
}

=for html <a name="load"></a>

=head2 load(hash query)

Loads the model or dies if not found or other error.
Subclasses shouldn't override this method.

=cut

sub load {
    my($self) = shift;
    $self->unsafe_load(@_) && return;
    Bivio::Die->die(Bivio::DieCode::NOT_FOUND(),
	    {@_, entity => $self, request => $self->get_request}, caller);
}

=for html <a name="unauth_load"></a>

=head2 unauth_load(hash query) : boolean

Loads the model as with L<unsafe_load|"unsafe_load">.  However, does
not insert security realm into query params.  Use this when you
B<are certain> there are no security issues involved with loading
the date.

On success, saves model in request and returns true.

Returns false if not found.  Dies on any other errors.

Subclasses should override this method if there model doesn't match
the usual property model.  L<unsafe_load|"unsafe_load"> and
L<load|"load"> call this method.

=cut

sub unauth_load {
    my($self, %query) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($ci) = $fields->{class_info};
    # Don't bother checking query.  Will kick back if empty.

    # Create the where clause
    my($where, @values);
    while (my($k, $v) = each(%query)) {
	Carp::croak('invalid field name syntax') unless $k =~ /^\w{1,32}$/;
	$where .= (defined($where) ? ' and ' : 'where ') . $k . '=?';
	push(@values, $v);
    }

    return 0 unless $ci->{sql_support}->unsafe_load(
	    $self, $fields->{properties}, $where, @values);
    # If found, put a reference to this model in request
    $self->get_request->put(ref($self), $self);
    return 1;
}

=for html <a name="unsafe_load"></a>

=head2 unsafe_load(hash query) : boolean

Loads the model.  On success, saves model in request and returns true.

Returns false if not found.  Dies on all other errors.

Subclasses shouldn't override this method.

=cut

sub unsafe_load {
    my($self) = shift;
    my($fields) = $self->{$_PACKAGE};
    Carp::croak('no query arguments') unless @_;
    my($req) = $fields->{request};

    # Ensure we are only getting data from the realm we are authorized
    # to operate in.
    my($k, $v) = $req->unsafe_get('auth_owner_id_field', 'auth_owner_id');
    # Will override existing value for auth_owner if any
    return $self->unauth_load(@_, $k ? ($k, $v) : ());
}

=for html <a name="update"></a>

=head2 update(hash new_values) : boolean

Updates the current model's values.
NOTE: find should be called prior to an update.

=cut

sub update {
    my($self, $new_values) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($ci) = $fields->{class_info};
    my($pk) = $ci->{primary_keys};
    my($properties) = $fields->{properties};
    # Ensure primary keys aren't different in new_values from properties
    # or SQL::Support will try to update them.
    map {$new_values->{$_} = $properties->{$_}} @$pk;
    $ci->{sql_support}->update($self, $properties,
	    $new_values, $ci->{primary_where}, $self->get(@$pk));
    return;
}

#=PRIVATE METHODS

# _get_property_info_value(self, string name, int index) : any
#
# Returns the value at the specified index of the named property's
# configuration

sub _get_property_info_value {
    my($self, $name, $index) = @_;
    my($property_info) = $self->{$_PACKAGE}->{class_info}->{property_info};
    my($property) = $property_info->{$name};
    Carp::croak("$name: unknown property") unless $property;
    return $property->[$index];
}

sub _initialize_class_info {
    my($class) = @_;
    my($ci) = $class->internal_initialize;
    $_CLASS_INFO{$class} = $ci = {
	property_info => $ci->[0],
	sql_support => $ci->[1],
	primary_keys => $ci->[2],
    };
    $ci->{sql_support}->initialize;
    $ci->{primary_where} = 'where ' . join(' and ',
	    map {$_ . '=?'} @{$ci->{primary_keys}});
    # sort is so as_string is always in the same order
    $ci->{as_string_fields} = [sort @{$ci->{primary_keys}}];
    unshift(@{$ci->{as_string_fields}}, 'name')
	    if defined($ci->{property_info}->{name})
		    && !grep($_ eq 'name', @{$ci->{as_string_fields}});
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
