# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model;
use strict;
$Bivio::Biz::Model::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::VERSION;

=head1 NAME

Bivio::Biz::Model - a business object

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model;

=head1 EXTENDS

L<Bivio::Collection::Attributes>

=cut

use Bivio::Collection::Attributes;
@Bivio::Biz::Model::ISA = ('Bivio::Collection::Attributes');

=head1 DESCRIPTION

C<Bivio::Biz::Model> is more interface than implementation, it provides
a common set of methods for L<Bivio::Biz::PropertyModel>,
L<Bivio::Biz::ListModel>, L<Bivio::Biz::FormModel>.

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::IO::ClassLoader;
use Bivio::HTML;
use Bivio::IO::Trace;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_IDI) = __PACKAGE__->instance_data_index;
my(%_CLASS_INFO);
my($_LOADED_ALL_PROPERTY_MODELS);

=head1 FACTORIES

=cut

=for html <a name="get_instance"></a>

=head2 static get_instance() : Bivio::Biz::Model

=head2 static get_instance(any class) : Bivio::Biz::Model

Returns the singleton for I<class>.  If I<class> is supplied, it may be just
the simple name or a fully qualified class name.  It will be loaded with
L<Bivio::IO::ClassLoader|Bivio::IO::ClassLoader> using the I<Model> map.
I<class> may also be an instance of a model.

May not be called on anonymous Models without I<class> argument.

=cut

sub get_instance {
    my($proto, $class) = @_;
    if (defined($class)) {
	$class = Bivio::IO::ClassLoader->map_require('Model', $class)
		unless ref($class);
	$class = ref($class) if ref($class);
    }
    else {
	$class = ref($proto) || $proto;
    }
    _initialize_class_info($class) unless $_CLASS_INFO{$class};
    return $_CLASS_INFO{$class}->{singleton};
}

=for html <a name="new"></a>

=head2 static new() : Bivio::Biz::Model

=head2 static new(Bivio::Agent::Request req) : Bivio::Biz::Model

=head2 static new(Bivio::Agent::Request req, any class) : Bivio::Biz::Model

Creates a Model with I<req>, if supplied.  The class of the model is defined by
C<$proto>.  If I<class> is supplied, L<get_instance|"get_instance"> is called
with I<class> as its argument and the resultant class is instantiated.

=cut

sub new {
    my($proto, $req, $class) = @_;
    $req ||= $proto->unsafe_get_request;
    return $proto->get_instance($class)->new($req) if defined($class);
    $class = ref($proto) || $proto;
    _initialize_class_info($class) unless $_CLASS_INFO{$class};
    my($ci) = $_CLASS_INFO{$class};
    # Make a copy of the properties for this instance.  properties
    # is an array_ref for efficiency
    my($self) = Bivio::Collection::Attributes::new($class,
	    {@{$ci->{properties}}});
    $self->[$_IDI] = {
	class_info => $ci,
        request => $req,
    };
    return $self;
}

=for html <a name="new_anonymous"></a>

=head2 static new_anonymous(hash_ref config) : Bivio::Biz::Model

=head2 static new_anonymous(hash_ref config, Bivio::Agent::Request req) : Bivio::Biz::Model

Creates an "anonymous" Model.  There are two modes: initialization
and creation from existing.  To initialize, you must supply
I<config>.  This will create the first anonymous instance.
I<proto> must be a class name, not a reference.

To create an instance from an existing instance, I<proto> must
be an instance, not a class name.  I<config> is ignored.

=cut

sub new_anonymous {
    my($proto, $config, $req) = @_;
    my($ci) = ref($proto) ? $proto->[$_IDI]->{class_info}
	    : _initialize_class_info($proto, $config);
    # Make a copy of the properties for this instance.  properties
    # is an array_ref for efficiency.
    my($self) = Bivio::Collection::Attributes::new($proto,
	    {@{$ci->{properties}}});
    $self->[$_IDI] = {
	class_info => $ci,
	# Never save the request for first time anonymous classes
        request => ref($proto) ? $req : undef,
	anonymous => 1,
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
    my($ci) = $self->[$_IDI]->{class_info};
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
    my($fields) = shift->[$_IDI];
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

=for html <a name="delete_from_request"></a>

=head2 delete_from_request()

Deletes I<self> from request.  Reverses L<put_on_request|"put_on_request">.

=cut

sub delete_from_request {
    my($self) = @_;
    my($req) = $self->unsafe_get_request;
    return unless $req;

    # ref($self) for backward compatibility
    foreach my $key ('Model.'.$self->simple_package_name, ref($self)) {
	$req->delete($key => $self);
    }
    return;
}

=for html <a name="die"></a>

=head2 die(string arg1, ...)

Calls L<throw_die|"throw_die"> with code DIE and message as (safe) concat
of args.

=cut

sub die {
    my($self, @args) = @_;
    $self->throw_die('DIE', {
#TODO: format, not die
	message => Bivio::Die->die(@args),
	program_error => 1,
    },
	    caller);
    # DOES NOT RETURN
}

=for html <a name="format_uri_for_this_property_model"></a>

=head2 format_uri_for_this_property_model(any task, string model_name) : string

Formats a uri for I<task> and model I<name> of I<self>.  Blows up if not all
the primary keys are available for I<model_name>.  Doesn't load the I<model>.
I<task> can be a name or L<Bivio::Agent::TaskId|Bivio::Agent::TaskId>.

=cut

sub format_uri_for_this_property_model {
    my($self, $task, $name) = @_;
    $task = Bivio::Agent::TaskId->from_name($task) unless ref($task);
    my($query, $mi) = _get_model_query($self, $name);
    $self->throw_die('NOT_FOUND', {
	message => 'missing primary keys in self for model', entity => $name})
	unless $query;
    return $self->get_request->format_uri(
	$task, $mi->format_query_for_this($query), undef, undef);
}

=for html <a name="get_as"></a>

=head2 get_as(string field, string converter)

Returns I<field> using the I<converter> (to_xml, to_string).

=cut

sub get_as {
    my($self, $field, $format) = @_;
    return $self->get_field_info($field, 'type')->$format($self->get($field));
}

=for html <a name="get_field_constraint"></a>

=head2 get_field_constraint(string name) : Bivio::SQL::Constraint

Returns the constraint for this field.

Calls L<get_field_info|"get_field_info">, so subclasses only need
to override C<get_field_info>.

=cut

sub get_field_constraint {
    return shift->get_field_info(shift, 'constraint');
}

=for html <a name="get_field_info"></a>

=head2 get_field_info(string field, string attr) : any

Returns I<attr> for I<field>.

=cut

sub get_field_info {
    return shift->[$_IDI]->{class_info}->{sql_support}
	    ->get_column_info(@_);
}

=for html <a name="get_field_type"></a>

=head2 get_field_type(string name) : Bivio::Type

Returns the type of this field.

Calls L<get_field_info|"get_field_info">, so subclasses only need
to override C<get_field_info>.

=cut

sub get_field_type {
    return shift->get_field_info(shift, 'type');
}

=for html <a name="get_info"></a>

=head2 get_info(string attr) : any

Returns meta information about the model.

B<Do not modify references returned by this method.>

=cut

sub get_info {
    return shift->[$_IDI]->{class_info}->{sql_support}->get(shift);
}

=for html <a name="get_model"></a>

=head2 get_model(string name) : Bivio::Biz::PropertyModel

Same as L<unsafe_get_model|"unsafe_get_model">, but dies if
the model could not be loaded.

=cut

sub get_model {
    my($self) = shift;
    my($model) = $self->unsafe_get_model(@_);
    $self->throw_die('NOT_FOUND', {
	message => 'unable to load model', entity => $model})
	    unless $model->is_loaded;
    return $model;
}

=for html <a name="internal_get_iterator"></a>

=head2 internal_get_iterator() : DBI::st

Returns the iterator.

=cut

sub internal_get_iterator {
    my($self) = @_;
    return $self->[$_IDI]->{iterator} || $self->die('iteration not started');
}

=for html <a name="internal_iterate_next"></a>

=head2 internal_iterate_next(hash_ref row, string converter) : array

Returns (I<self>, I<row>) on success or () if no more.

=cut

sub internal_iterate_next {
    my($self, $it, $row, $converter) = @_;
    if (ref($it) eq 'HASH') {
	$converter = $row;
	$row = $it;
	$it = $self->internal_get_iterator;
    }
    else {
	# deprecated form
    }
    return $self->internal_get_sql_support->iterate_next(
	$it, $row, $converter) ? ($self, $row) : ();
}

=for html <a name="internal_put_iterator"></a>

=head2 internal_put_iterator(DBI::st it) : DBI::st

Sets the iterator and returns its argument.

=cut

sub internal_put_iterator {
    my($self, $it) = @_;
    return $self->[$_IDI]->{iterator} = $it;
}

=for html <a name="put_on_request"></a>

=head2 put_on_request()

Adds this instance to the request, stored with the key
'Model.<simple package name>'.

=head2 put_on_request(boolean durable)

Adds the model to the request as a durable attribute. The model will
survive server redirects.

=cut

sub put_on_request {
    my($self, $durable) = @_;
    my($req) = $self->unsafe_get_request;
    return unless $req;

    # ref($self) for backward compatibility
    foreach my $key ('Model.'.$self->simple_package_name, ref($self)) {
	if ($durable) {
	    $req->put_durable($key => $self);
	}
	else {
	    $req->put($key => $self);
	}
    }
    return;
}

=for html <a name="throw_die"></a>

=head2 static throw_die(Bivio::Type::Enum code, hash_ref attrs, string package, string file, int line)

=head2 static throw_die(Bivio::Type::Enum code, string message, string package, string file, int line)nn

Terminate the I<model> as entity and request in I<attrs> with a specific code.

I<package>, I<file>, and I<line> need not be defined

=cut

sub throw_die {
    my($self, $code, $attrs, $package, $file, $line) = @_;
    $package ||= (caller)[0];
    $file ||= (caller)[1];
    $line ||= (caller)[2];
    $attrs ||= {};
    ref($attrs) eq 'HASH' || ($attrs = {message => $attrs});
    $attrs->{model} = $self;
    Bivio::Die->throw($code, $attrs, $package, $file, $line);
    # DOES NOT RETURN
}

=for html <a name="get_request"></a>

=head2 static get_request() : Bivio::Agent::Request

Returns the request associated with this model.
If not set, returns the current request.
If neither set, throws an exception.

=cut

sub get_request {
    my($self) = @_;
    my($req) = $self->unsafe_get_request;
    Bivio::Die->die($self, ": request not set") unless $req;
    return $req;
}

=for html <a name="has_fields"></a>

=head2 has_fields(string name, ...) : boolean

Does the model have these fields?

=cut

sub has_fields {
    return shift->[$_IDI]->{class_info}->{sql_support}
	    ->has_columns(@_);
}

=for html <a name="internal_clear_model_cache"></a>

=head2 internal_clear_model_cache()

Called to clear the cache of models.  Necessary
when a reload occurs.

=cut

sub internal_clear_model_cache {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
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
    my($fields) = $self->[$_IDI];
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
    Bivio::Die->die(shift, ': abstract method');
}

=for html <a name="internal_initialize_sql_support"></a>

=head2 static abstract internal_initialize_sql_support() : Bivio::SQL::Support

=head2 static abstract internal_initialize_sql_support(hash_ref config) : Bivio::SQL::Support

B<FOR INTERNAL USE ONLY>.

Returns the L<Bivio::SQL::Support|Bivio::SQL::Support> object
for this model.

=cut

sub internal_initialize_sql_support {
    Bivio::Die->die(shift, ': abstract method');
}

=for html <a name="iterate_end"></a>

=head2 iterate_end()

Terminates the iterator.  See L<iterate_start|"iterate_start">.
Does not modify model state, i.e. if loaded, stays loaded.

B<Deprecated form accepts an iterator as the first argument.>

=cut

sub iterate_end {
    my($self, $it) = @_;
    my($fields) = $self->[$_IDI];
    $self->internal_get_sql_support->iterate_end(
       $it || $self->internal_get_iterator);
    # Deprecated form passes in an iterator, which can only clear
    # if the caller hasn't "changed" iterators.
    $fields->{iterator} = undef
	if !$it || $fields->{iterator} && $it == $fields->{iterator};
    return;
}

=for html <a name="iterate_next"></a>

=head2 iterate_next(hash_ref row) : boolean

=head2 iterate_next(hash_ref row, string converter) : boolean

I<row> is the resultant values by field name.
I<converter> is optional and is the name of a
L<Bivio::Type|Bivio::Type> method, e.g. C<to_html>.

Returns false if there is no next.

B<Deprecated form accepts an iterator as the first argument.>

=cut

sub iterate_next {
    return shift->internal_iterate_next(@_) ? 1 : 0;
}

=for html <a name="merge_initialize_info"></a>

=head2 static merge_initialize_info(hash_ref parent, hash_ref child) : hash_ref

Merges two model field definitions (I<child> into I<parent>) into a new
hash_ref.

=cut

sub merge_initialize_info {
    my($proto, $parent, $child) = @_;

    my($res) = {};
    foreach my $info ($parent, $child) {
	foreach my $key (keys(%$info)) {
	    unless (exists($res->{$key})) {
		$res->{$key} = $info->{$key};
		next;
	    }
	    my($value) = $res->{$key};
	    $proto->die('unexpected key value: ', $key, ' => ', $value)
		unless ref($value) eq ref($info->{$key});
	    unless (ref($value)) {
		# Scalar (version)
		$res->{$key} = $info->{$key};
		next;
	    }
	    if (ref($value) eq 'ARRAY') {
		push(@$value, @{$info->{$key}});
		next;
	    }
	    # PropertyModel columns is a hash
	    foreach my $subkey (keys(%{$info->{$key}})) {
		$proto->die("duplicate $key key: ", $subkey)
		    if exists($value->{$subkey});
		$value->{$subkey} = $info->{$key}->{$subkey};
	    }
	}
    }
    return $res;
}

=for html <a name="put"></a>

=head2 put()

Not supported.

=cut

sub put {
    CORE::die('put: not supported');
}

=for html <a name="unsafe_get_model"></a>

=head2 unsafe_get_model(string name) : Bivio::Biz::PropertyModel

Returns the named PropertyModel associated with this instance.
If it can be loaded, it will be.  See
L<Bivio::Biz::PropertyModel::is_loaded|Bivio::Biz::PropertyModel/"is_loaded">.

=cut

sub unsafe_get_model {
    my($self, $name) = @_;
    my($fields) = $self->[$_IDI];
    if (defined($fields->{models})) {
	return $fields->{models}->{$name} if $fields->{models}->{$name};
    }
    else {
	$fields->{models} = {};
    }
    my($query, $mi) = _get_model_query($self, $name);
    $fields->{models}->{$name} = $mi;

#TODO: SECURITY: Is this valid?
    # Can be "unauth_load", because the primary load was authenticated
    $mi->unauth_load($query) if $query;
    return $mi;
}

=for html <a name="unsafe_get_request"></a>

=head2 static unsafe_get_request() : Bivio::Agent::Request

Returns the request associated with this model (if defined).
Otherwise, returns the current request, if any.

=cut

sub unsafe_get_request {
    my($self) = @_;
    my($req);
    $req = $self->[$_IDI]->{request} if ref($self);
    # DON'T SET the request for future calls, because this may
    # be an anonymous model or a singleton.
    Bivio::IO::ClassLoader->simple_require('Bivio::Agent::Request');
    return $req ? $req : Bivio::Agent::Request->get_current;
}

#=PRIVATE METHODS

# _as_string_fields(Bivio::SQL::Support sql_support) : array_ref
#
# Returns as_string_fields.
#
sub _as_string_fields {
    my($sql_support) = @_;
    return $sql_support->get('as_string_fields')
	if $sql_support->has_keys('as_string_fields');
    my($res) = [@{$sql_support->get('primary_key_names')}];
    unshift(@$res, 'name')
	if $sql_support->has_columns('name') && !grep($_ eq 'name', @$res);
    return $res;
}

# _assert_class_name(string class)
#
# Ensures that the class conforms to the naming conventions.
#
sub _assert_class_name {
    my($class) = @_;
    Bivio::Die->die($class, ': is a base class; it cannot be initialized'
	    .' as a model')
		if $class =~ /Base$/;
    my($super) = 'Bivio::Biz::'
	    .($class =~ /(ListForm|Form|List)$/ ? $1 : 'Property')
	    .'Model';
    Bivio::Die->die($class, ': must be a ', $super)
	    unless UNIVERSAL::isa($class, $super);
    return;
}

# _get_model_query(self, string name) : array
#
# Returns the model (query, instance) by looking for the model.
#
sub _get_model_query {
    my($self, $name) = @_;
    # Asserts operation is valid
    my($sql_support) = $self->internal_get_sql_support;
    my($models) = $sql_support->get('models');
    $self->die("$name: no such model") unless defined($models->{$name});
    my($m) = $models->{$name};
    my($properties) = $self->internal_get;
    my($req) = $self->unsafe_get_request;
    # Always store the model.
    my($mi) = $m->{instance}->new($req);
    my($query) = {};
    my($map) = $m->{primary_key_map};
    foreach my $pk (keys(%$map)) {
	my($v);
	unless (defined($v = $properties->{$map->{$pk}->{name}})) {
	    # If there is an auth_id, use it if this is the missing
	    # primary key.
	    my($auth_id) = $mi->get_info('auth_id');
	    unless ($auth_id && $pk eq $auth_id->{name}) {
		_trace($self, ': loading ', $m->{instance}, ' missing key ',
			$map->{$pk}->{name}) if $_TRACE;
		return (undef, $mi);
	    }
	    $v = $req->get('auth_id');
	}
	$query->{$pk} = $v;
    }
    return ($query, $mi);
}

# _initialize_class_info(string class)
# _initialize_class_info(string class, hash_ref config) : hash_ref
#
# Initializes from class or from config.  config is supplied for
# anonymous models (currently, only ListModels).
#
sub _initialize_class_info {
    my($class, $config) = @_;
    # This may load the models and we'll try to get the class_info
    # again after the models are loaded.
    _load_all_property_models();

    # Have here for safety to avoid infinite recursion if called badly.
    return if !$config && $_CLASS_INFO{$class};

    _assert_class_name($class) unless $config;

    my($sql_support) = $class->internal_initialize_sql_support($config);
    my($ci) = {
	sql_support => $sql_support,
	as_string_fields => _as_string_fields($sql_support),
	# Is an array, because faster than a hash_ref for our purposes
	properties => [map {
		($_, undef);
	    } @{$sql_support->get('column_names')},
	],
    };
    return $ci if $config;
    # $_CLASS_INFO{$class} is sentinel to stop recursion
    $_CLASS_INFO{$class} = $ci;
    $ci->{singleton} = $class->new;
    $ci->{singleton}->[$_IDI]->{is_singleton} = 1;
    return;
}

# _load_all_property_models()
#
# Loads the property models, if not already loaded.
#
sub _load_all_property_models {
    return if $_LOADED_ALL_PROPERTY_MODELS;
    # Avoid recursion and don't want redo in any event
    $_LOADED_ALL_PROPERTY_MODELS = 1;
    my($models) = Bivio::IO::ClassLoader->map_require_all('Model',
	    sub {
		my($class, $file) = @_;
		# We don't load classes which end in List, Form, or Base.
		return $class =~ /(Form|List|Base)$/ ? 0 : 1;
	    });

    # Force class initialization
    foreach my $class (@$models) {
	$class->get_instance;
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
