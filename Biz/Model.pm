# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model;
use strict;
$Bivio::Biz::Model::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model - a business object

=head1 SYNOPSIS

    my($model) = ...;
    # load a model with data
    $model->load(id => 100);

=head1 EXTENDS

L<Bivio::Collection::Attributes>

=cut

use Bivio::Collection::Attributes;
@Bivio::Biz::Model::ISA = ('Bivio::Collection::Attributes');

=head1 DESCRIPTION

C<Bivio::Biz::Model> is more interface than implementation, it provides
a common set of methods for L<Bivio::Biz::PropertyModel> and
L<Bivio::Biz::ListModel>.

=cut

#=IMPORTS
use Bivio::IO::Trace;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my(%_CLASS_INFO);

=head1 FACTORIES

=cut

=for html <a name="get_instance"></a>

=head2 static get_instance() : Bivio::Biz::PropertyModel

Returns the singleton for this class.

=cut

sub get_instance {
    my($proto) = @_;
    my($class) = ref($proto) || $proto;
    _initialize_class_info($class) unless $_CLASS_INFO{$class};
    return $_CLASS_INFO{$class}->{singleton};
}

=for html <a name="new"></a>

=head2 static new() : Bivio::Biz::PropertyModel

=head2 static new(Bivio::Agent::Request req) : Bivio::Biz::PropertyModel

Creates a PropertyModel with the specified request.

A PropertyModel may only be loaded if I<req> is non-null.

=cut

sub new {
    my($proto, $req) = @_;
    my($class) = ref($proto) || $proto;
    _initialize_class_info($class) unless $_CLASS_INFO{$class};
    my($ci) = $_CLASS_INFO{$class};
    # Make a copy of the properties for this instance
    my($self) = Bivio::Collection::Attributes::new($proto,
	    {@{$ci->{properties}}});
    $self->{$_PACKAGE} = {
	class_info => $ci,
        request => $req,
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
    } $self->unsafe_get(@{$ci->{as_string_fields}})) . ')';
}

=for html <a name="assert_not_singleton"></a>

=head2 assert_not_singleton()

Throws an exception if this is the singleton instance.

=cut

sub assert_not_singleton {
    my($fields) = shift->{$_PACKAGE};
    return unless $fields->{is_singleton};
    Carp::croak("can't create, update, read, or delete singleton instance");
}

=for html <a name="clone"></a>

=head2 clone()

Not supported.

=cut

sub clone {
    die('not supported');
}

=for html <a name="delete"></a>

=head2 delete()

Not supported.

=cut

sub delete {
    die('not supported');
}

=for html <a name="delete_all"></a>

=head2 delete_all()

Not supported.

=cut

sub delete_all {
    die('not supported');
}

=for html <a name="get_field_constraint"></a>

=head2 get_field_constraint(string name) : Bivio::SQL::Constraint

Returns the constraint for this field.

=cut

sub get_field_constraint {
    return shift->{$_PACKAGE}->{class_info}->{sql_support}->
	    get_column_constraint(@_);
}

=for html <a name="get_field_type"></a>

=head2 get_field_type(string name) : Bivio::Type

Returns the type of this field.

=cut

sub get_field_type {
    return shift->{$_PACKAGE}->{class_info}->{sql_support}->
	    get_column_type(@_);
}

=for html <a name="get_info"></a>

=head2 get_info(string attr) : any

Returns meta information about the model.

B<Do not modify references returned by this method.>

=cut

sub get_info {
    return shift->{$_PACKAGE}->{class_info}->{sql_support}->get(shift);
}

=for html <a name="die"></a>

=head2 static die(Bivio::Type::Enum code, hash_ref attrs, string package, string file, int line)

=head2 static die(Bivio::Type::Enum code, string message, string package, string file, int line)

Terminate the I<model> as entity and request in I<attrs> with a specific code.

I<package>, I<file>, and I<line> need not be defined

=cut

sub die {
    my($self, $code, $attrs, $package, $file, $line) = @_;
    $package ||= (caller)[0];
    $file ||= (caller)[1];
    $line ||= (caller)[2];
    $attrs ||= {};
    ref($attrs) eq 'HASH' || ($attrs = {message => $attrs});
    $attrs->{model} = $self;
    # Don't call get_request, because will blow up if not set.
    $attrs->{request} = $self->{$_PACKAGE}->{request};
    Bivio::Die->die($code, $attrs, $package, $file, $line);
}

=for html <a name="get_model"></a>

=head2 get_model(string name) : Bivio::Biz::PropertyModel

Returns the named property model associated with this instance.
If it can be loaded, it will be.

=cut

sub get_model {
    my($self, $name) = @_;
#TODO: clear_models?  Need to reset the state
    my($fields) = $self->{$_PACKAGE};

    # Asserts operation is valid
    my($sql_support) = $self->internal_get_sql_support;

    if (defined($fields->{models})) {
	return $fields->{models}->{$name} if $fields->{models}->{$name};
    }
    else {
	$fields->{models} = {};
    }
    my($models) = $sql_support->get('models');
    Carp::croak($name, ': no such model') unless defined($models->{$name});
    my($m) = $models->{$name};
    my($properties) = $self->internal_get;
    my($req) = $self->get_request;
    # Always store the model.
    my($mi) = $fields->{models}->{$name} = $m->{instance}->new($req);
    my(@query) = ();
    my($map) = $m->{primary_key_map};
    foreach my $pk (keys(%$map)) {
	my($v);
	unless (defined($v = $properties->{$map->{$pk}->{name}})) {
	    _trace($self, ': loading ', $m->{instance}, ' missing key ',
		    $map->{$pk}->{name}) if $_TRACE;
	    return $mi;
	}
	push(@query, $pk, $v);
    }
#TODO: SECURITY: Is this valid?
    # Can be "unauth_load", because the primary load was authenticated
    $mi->unauth_load(@query);
    return $mi;
}

=for html <a name="get_request"></a>

=head2 get_request() : Bivio::Agent::Request

Returns the request associated with this model.

=cut

sub get_request {
    my($self) = @_;
    my($req) = $self->{$_PACKAGE}->{request};
    Carp::croak($self, ": request not set") unless $req;
    return $req;
}

=for html <a name="internal_clear_model_cache"></a>

=head2 internal_clear_model_cache()

Called to clear the cache of models.  Necessary
when a reload occurs.

=cut

sub internal_clear_model_cache {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    delete($fields->{models});
    return;
}

=for html <a name="internal_get_sql_support"></a>

=head2 internal_get_sql_support() : Bivio::SQL::Support

Returns L<Bivio::SQL::Support|Bivio::SQL::Support> for this instance
only if this is not the singleton.  If it is the singleton, dies.

=cut

sub internal_get_sql_support {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    $self->assert_not_singleton if $fields->{is_singleton};
    return $fields->{class_info}->{sql_support};
}

=for html <a name="internal_initialize"></a>

=head2 static abstract internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY.>

Returns an has_ref describing the model suitable for passing
to L<Bivio::SQL::PropertySupport::new|Bivio::SQL::PropertySupport/"new">
or L<Bivio::SQL::ListSupport::new|Bivio::SQL::ListSupport/"new">.

=cut

sub internal_initialize {
    Carp::croak('abstract method');
}

=for html <a name="internal_initialize_sql_support"></a>

=head2 static abstract internal_initialize_sql_support() : Bivio::SQL::Support

B<FOR INTERNAL USE ONLY>.

Returns the L<Bivio::SQL::Support|Bivio::SQL::Support> object
for this model.

=cut

sub internal_initialize_sql_support {
    Carp::croak('abstract method');
}

=for html <a name="put"></a>

=head2 put()

Not supported.

=cut

sub put {
    CORE::die('not supported');
}

=for html <a name="unsafe_get_request"></a>

=head2 unsafe_get_request() : Bivio::Agent::Request

Returns the request associated with this model (if defined).

=cut

sub unsafe_get_request {
    return shift->{$_PACKAGE}->{request};
}

#=PRIVATE METHODS


sub _initialize_class_info {
    my($class) = @_;
    # Have here for safety to avoid infinite recursion if called badly.
    return if $_CLASS_INFO{$class};
    my($sql_support) = $class->internal_initialize_sql_support;
    my($ci) = $_CLASS_INFO{$class} = {
	sql_support => $sql_support,
	as_string_fields => [@{$sql_support->get('primary_key_names')}],
	# Is an array, because faster than a hash_ref for our purposes
	properties => [map {
		($_, undef);
	    } @{$sql_support->get('column_names')},
	],
    };
    unshift(@{$ci->{as_string_fields}}, 'name')
	    if $sql_support->has_columns('name')
		    && !grep($_ eq 'name', @{$ci->{as_string_fields}});
    # $_CLASS_INFO{$class} is sentinel to stop recursion
    $ci->{singleton} = $class->new;
    $ci->{singleton}->{$_PACKAGE}->{is_singleton} = 1;
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
