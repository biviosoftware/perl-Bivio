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
by invoking L<"get_field_type">. PropertyModel has several
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
    my($self) = &Bivio::Biz::Model::new($proto, $req);
    my($class) = ref($self);
    _initialize_class_info($class) unless $_CLASS_INFO{$class};
    my($ci) = $_CLASS_INFO{$class};
    my($properties) = {map {
	    ($_, undef);
	} @{$ci->{sql_support}->get_column_names}
    };
    $self->{$_PACKAGE} = {
	class_info => $ci,
    };
    $self->internal_put($properties);
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

=head2 create(hash new_values)

Creates a new model in the database with the specified values. After creation,
this instance takes ownership of I<new_values>.  Dies on error.

=cut

sub create {
    my($self, $new_values) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($sql_support) = $fields->{class_info}->{sql_support};
    # Make sure all columns are defined
    my($n);
    foreach $n (@{$sql_support->get_column_names}) {
	$new_values->{$n} = undef unless exists($new_values->{$n});
    }
    $sql_support->create($new_values, $self);
    $self->internal_put($new_values);
    $self->get_request->put(ref($self), $self);
    return;
}

=for html <a name="delete"></a>

=head2 delete()

Deletes the current model from the database.   Dies on error.

=cut

sub delete {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{class_info}->{sql_support}->delete($self->internal_get, $self);
    return;
}

=for html <a name="get_field_type"></a>

=head2 get_field_type(string name) : Bivio::Type

=cut

sub get_field_type {
    my($sql_support) = shift->{$_PACKAGE}->{class_info}->{sql_support};
    return $sql_support->get_column_type(@_);
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
    $self->die(Bivio::DieCode::NOT_FOUND(), {@_}, caller);
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
    my($values) = $ci->{sql_support}->unsafe_load(\%query, $self);
    return 0 unless $values;
    $self->internal_put($values);
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

    # Ensure we are only getting data from the realm we are authorized
    # to operate in.
    my($k, $v) = $self->get_request->unsafe_get('auth_id_field', 'auth_id');
    # Will override existing value for auth_id if any
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
    my($properties) = $self->internal_get;
    $fields->{class_info}->{sql_support}->update($properties,
	    $new_values, $self);
    my($n);
    foreach $n (keys(%$new_values)) {
	$properties->{$n} =  $new_values->{$n};
    }
    return;
}

#=PRIVATE METHODS

sub _initialize_class_info {
    my($class) = @_;
    my($sql_support) = $class->internal_initialize;
    my($ci) = $_CLASS_INFO{$class} = {
	sql_support => $sql_support,
	as_string_fields => [@{$sql_support->get_primary_key_names}],
    };
    unshift(@{$ci->{as_string_fields}}, 'name')
	    if $sql_support->has_columns('name')
		    && !grep($_ eq 'name', @{$ci->{as_string_fields}});
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
