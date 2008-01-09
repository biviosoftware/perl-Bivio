# Copyright (c) 1999-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model;
use strict;
use Bivio::Base 'Bivio::Collection::Attributes';
use Bivio::Die;
use Bivio::HTML;
use Bivio::IO::ClassLoader;
use Bivio::IO::Trace;
use Bivio::SQL::Statement;

# C<Bivio::Biz::Model> is more interface than implementation, it provides
# a common set of methods for L<Bivio::Biz::PropertyModel>,
# L<Bivio::Biz::ListModel>, L<Bivio::Biz::FormModel>.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_IDI) = __PACKAGE__->instance_data_index;
#my(%_CLASS_INFO);
my($_LOADED_ALL_PROPERTY_MODELS);

sub as_string {
    my($self) = @_;
    my($ci) = $self->[$_IDI]->{class_info};
    return ref($self)
	. '('
	. join(',',
	    map($self->get_field_type($_)->to_string($self->unsafe_get($_)),
		@{$ci->{as_string_fields}}),
	) . ')';
}

sub assert_not_singleton {
    my($self) = @_;
    # Throws an exception if this is the singleton instance.
    die("can't create, update, read, or delete singleton instance")
	if $self->[$_IDI]->{is_singleton};
    return $self;
}

sub clone {
    my($self) = shift;
    return $self->is_instance ? $self->SUPER::clone(@_) : $self;
}

sub delete {
    # Not supported.
    die('not supported');
}

sub delete_from_request {
    my($self) = @_;
    # Deletes I<self> from request.  Reverses L<put_on_request|"put_on_request">.
    my($req) = $self->unsafe_get_request;
    return unless $req;

    # ref($self) for backward compatibility
    foreach my $key ('Model.'.$self->simple_package_name, ref($self)) {
	$req->delete($key => $self);
    }
    return;
}

sub die {
    my($self, @args) = @_;
    $self->throw_die(
	'DIE', {
	    message => Bivio::IO::Alert->format_args(@args),
	    program_error => 1,
	},
	caller,
    );
    # DOES NOT RETURN
}

sub do_iterate {
    my($self, $do_iterate_handler) = (shift, shift);
    # Like L<map_iterate|"map_iterate"> but does not return anything.  For each row,
    # calls L<iterate_next_and_load|"iterate_next_and_load"> followed by
    # L<do_iterate_handler|"do_iterate_handler">.  Terminates the iteration with
    # L<iterate_end|"iterate_end"> when there are no more rows or if
    # I<do_iterate_handler> returns false.
    my($iterate_start) = $_[0] && !ref($_[0]) && $_[0] =~ /iterate_start/
	&& $self->can($_[0]) ? shift : 'iterate_start';
    $self->$iterate_start(@_);
    0 while $self->iterate_next_and_load && $do_iterate_handler->($self);
    $self->iterate_end;
    return $self;
}

sub format_uri_for_this_property_model {
    my($self, $task, $name) = @_;
    # Formats a uri for I<task> and model I<name> of I<self>.  Blows up if not all
    # the primary keys are available for I<model_name>.  Doesn't load the I<model>.
    # I<task> can be a name or L<Bivio::Agent::TaskId|Bivio::Agent::TaskId>.
    $task = Bivio::Agent::TaskId->from_name($task) unless ref($task);
    my($query, $mi) = _get_model_query($self, $name);
    $self->throw_die('MODEL_NOT_FOUND', {
	message => 'missing primary keys in self for model', entity => $name})
	unless $query;
    return $self->get_request->format_uri(
	$task, $mi->format_query_for_this($query), undef, undef);
}

sub get_as {
    my($self, $field, $format) = @_;
    return $self->get_field_info($field, 'type')->$format($self->get($field));
}

sub get_field_constraint {
    # Returns the constraint for this field.
    #
    # Calls L<get_field_info|"get_field_info">, so subclasses only need
    # to override C<get_field_info>.
    return shift->get_field_info(shift, 'constraint');
}

sub get_field_info {
    # Returns I<attr> for I<field>.
    return shift->[$_IDI]->{class_info}->{sql_support}
	    ->get_column_info(@_);
}

sub get_field_type {
    # Returns the type of this field.
    #
    # Calls L<get_field_info|"get_field_info">, so subclasses only need
    # to override C<get_field_info>.
    return shift->get_field_info(shift, 'type');
}

sub get_info {
    # Returns meta information about the model.
    #
    # B<Do not modify references returned by this method.>
    return shift->[$_IDI]->{class_info}->{sql_support}->get(shift);
}

sub get_instance {
    my($proto, $class) = @_;
    # Returns the singleton for I<class>.  If I<class> is supplied, it may be just
    # the simple name or a fully qualified class name.  It will be loaded with
    # L<Bivio::IO::ClassLoader|Bivio::IO::ClassLoader> using the I<Model> map.
    # I<class> may also be an instance of a model.
    #
    # May not be called on anonymous Models without I<class> argument.
    if (defined($class)) {
	$class = Bivio::IO::ClassLoader->map_require('Model', $class)
		unless ref($class);
	$class = ref($class) if ref($class);
    }
    else {
	$class = ref($proto) || $proto;
    }
#     _initialize_class_info($class) unless $_CLASS_INFO{$class};
#     return $_CLASS_INFO{$class}->{singleton};
    return _get_class_info($class)->{singleton};
}

sub get_model {
    my($self) = @_;
    # Same as L<unsafe_get_model|"unsafe_get_model">, but dies if
    # the model could not be loaded.
    my($model) = shift->unsafe_get_model(@_);
    $self->throw_die('MODEL_NOT_FOUND', {
	message => 'unable to load model', entity => $model})
	    unless $model->is_loaded;
    return $model;
}

sub get_qualified {
    my($self, $field) = @_;
    # Returns the qualified field value if it exists or strips the model from
    # I<field> and tries to get unqualified.
    return $self->has_keys($field) ? $self->get($field)
	: $self->get(($field =~ /(?<=\.)(\w+)$/)[0]
	    || $self->die($field, ': not a qualified name'));
}

sub get_request {
    my($self) = @_;
    # Returns the request associated with this model.
    # If not set, returns the current request.
    # If neither set, throws an exception.
    my($req) = $self->unsafe_get_request;
    Bivio::Die->die($self, ": request not set") unless $req;
    return $req;
}

sub has_fields {
    # Does the model have these fields?
    return shift->[$_IDI]->{class_info}->{sql_support}
	    ->has_columns(@_);
}

sub has_iterator {
    my($self) = @_;
    # Returns true if there is an iterator started on this model.
    my($fields) = $self->[$_IDI];
    return $fields->{iterator} ? 1 : 0;
}

sub internal_clear_model_cache {
    my($self) = @_;
    # Called to clear the cache of models.  Necessary
    # when a reload occurs.
    my($fields) = $self->[$_IDI];
    delete($fields->{models});
    return;
}

sub internal_get_iterator {
    my($self) = @_;
    return $self->[$_IDI]->{iterator} || $self->die('iteration not started');
}

sub internal_get_sql_support {
    return shift->assert_not_singleton->internal_get_sql_support_no_assert;
}

sub internal_get_sql_support_no_assert {
    return shift->[$_IDI]->{class_info}->{sql_support};
}

sub internal_get_statement {
    my($self) = @_;
    # Returns L<Bivio::SQL::Statement|Bivio::SQL::Statement> for this instance.
    my($fields) = $self->[$_IDI];
    $self->assert_not_singleton if $fields->{is_singleton};
    return $fields->{class_info}->{statement};
}

sub internal_initialize {
    # B<FOR INTERNAL USE ONLY.>
    #
    # Returns an hash_ref describing the model suitable for passing
    # to L<Bivio::SQL::PropertySupport::new|Bivio::SQL::PropertySupport/"new">
    # or L<Bivio::SQL::ListSupport::new|Bivio::SQL::ListSupport/"new">.
    return (caller(1))[3] =~ /::internal_initialize$/ ? {}
	: Bivio::Die->die(
	    shift, ': abstract method; internal_initialize must be defined');
}

sub internal_initialize_local_fields {
    my($proto, $decls, $default_type, $default_constraint) = @_;
    # Provides positional shortcut for generating field declarations to pass return
    # from L<internal_initialize|"internal_initialize">.  I<decls> is a array of
    # arrays.  Each element is a field declaration that is a tuple of (name, type,
    # constraint).  If type or constraint is undef, will be initialized with default
    # values.  If both type or constraint is missing, element may be a string.
    # I<default_type> and <default_constraint> must be defined if I<decls>
    # requires default values.
    #
    # In the second form, you may specify the class as an argument.  This also allows
    # you to declare multiple (class, decl) tuples which can be convenient for
    # forms with all local fields.
    #
    # Examples:
    #
    #     $self->internal_initialize_local_fields([
    #         'first_name',
    #         'middle_name',
    #         'last_name',
    #         [qw(gender Gender)],
    #     ], 'Line', 'NOT_NULL');
    #
    #     $self->internal_initialize_local_fields([
    #         ['count', 'Integer', 'NOT_NULL'],
    #     ]);
    #
    #     $self->internal_initialize_local_fields(
    #         visible => [
    # 	    'first_name',
    # 	    'middle_name',
    # 	    'last_name',
    # 	    [qw(gender Gender)],
    # 	],
    #         hidden => [
    #             ['count', 'Integer', 'NOT_NULL'],
    #         ],
    #         'Line', 'NOT_NULL');
    return [
	map({
	    $_ = [$_]
	    unless ref($_);
	    {
		name => $_->[0],
		type => $_->[1] || $default_type
		    || $proto->die('default_type must be defined'),
		constraint => $_->[2] || $default_constraint
		    || $proto->die('default_constraint must be defined'),
	    };
	} @$decls)
    ] if ref($decls) eq 'ARRAY';
    my($aux) = [];
    unshift(@$aux, pop(@_))
	while !ref($_[$#_]);
    Bivio::Die->die('expecting class and declarations')
	unless @_ > 1;
    shift(@_);
    Bivio::Die->die('uneven (class, declarations) tuples')
        if @_ % 2;
    return [
	map({
	    (shift(@_) => $proto->internal_initialize_local_fields(
		shift(@_), @$aux));
	} 1 .. @_ / 2),
    ];
}

sub internal_initialize_sql_support {
    # B<FOR INTERNAL USE ONLY>.
    #
    # Returns the L<Bivio::SQL::Support|Bivio::SQL::Support> object
    # for this model.
    Bivio::Die->die(shift, ': abstract method');
}

sub internal_iterate_next {
    my($self, $it, $row, $converter) = @_;
    # Returns (I<self>, I<row>) on success or () if no more.
    if (ref($it) eq 'HASH') {
	$converter = $row;
	$row = $it;
	$it = $self->internal_get_iterator;
    }
    else {
	# deprecated form
    }
    return $self->internal_get_sql_support->iterate_next(
	$self, $it, $row, $converter) ? ($self, $row) : ();
}

sub internal_put_iterator {
    my($self, $it) = @_;
    # Sets the iterator and returns its argument.
    return $self->[$_IDI]->{iterator} = $it;
}

sub is_ephemeral {
    my($self) = @_;    
    return exists($self->[$_IDI]->{ephmeral});
}

sub is_instance {
    my($self) = @_;
    # Returns true if is a normal instance and not singleton or class.
    return !ref($self) || $self->[$_IDI]->{is_singleton} ? 0 : 1;
}

sub iterate_end {
    my($self, $it) = @_;
    # Terminates the iterator.  See L<iterate_start|"iterate_start">.
    # Does not modify model state, i.e. if loaded, stays loaded.
    #
    # B<Deprecated form accepts an iterator as the first argument.>
    my($fields) = $self->[$_IDI];
    $self->internal_get_sql_support->iterate_end(
       $it || $self->internal_get_iterator);
    # Deprecated form passes in an iterator, which can only clear
    # if the caller hasn't "changed" iterators.
    $fields->{iterator} = undef
	if !$it || $fields->{iterator} && $it == $fields->{iterator};
    return;
}

sub iterate_next {
    # I<row> is the resultant values by field name.
    # I<converter> is optional and is the name of a
    # L<Bivio::Type|Bivio::Type> method, e.g. C<to_html>.
    #
    # Returns false if there is no next.
    #
    # B<Deprecated form accepts an iterator as the first argument.>
    return shift->internal_iterate_next(@_) ? 1 : 0;
}

sub map_iterate {
    my($self, $map_iterate_handler) = (shift, shift);
    # Calls L<iterate_start|"iterate_start"> or I<iterate_start> (if supplied)
    # to start the iteration with I<iterate_args>.  For each row, calls
    # L<iterate_next_and_load|"iterate_next_and_load"> followed by
    # L<map_iterate_handler|"map_iterate_handler">.  Terminates the iteration with
    # L<iterate_end|"iterate_end">.
    #
    # Returns the aggregated result of L<map_iterate_handler|"map_iterate_handler">
    # as an array_ref, calling L<get_shallow_copy|"get_shallow_copy"> to get each
    # row's values.
    #
    # If I<map_iterate_handler> is C<undef>, the default handler simply returns all
    # the rows.
    my($iterate_start) = $_[0] && !ref($_[0]) && $_[0] =~ /iterate_start/
	&& $self->can($_[0]) ? shift : 'iterate_start';
    my($res) = [];
    $self->$iterate_start(@_);
    my($op) = ref($map_iterate_handler) ? $map_iterate_handler
	: defined($map_iterate_handler) ? sub {shift->get($map_iterate_handler)}
	: sub {shift->get_shallow_copy};
    while ($self->iterate_next_and_load) {
	push(@$res, $op->($self));
    }
    $self->iterate_end;
    return $res;
}

sub merge_initialize_info {
    my($proto, $parent, $child) = @_;
    # Merges two model field definitions (I<child> into I<parent>) into a new
    # hash_ref.
    my($res) = {%$child};
    foreach my $k (keys(%$parent)) {
	if (
	    ref($parent->{$k}) ne 'ARRAY'
	    || $k =~ /^(auth_id|date|primary_id|primary_key)$/,
        ) {
	    $res->{$k} = $parent->{$k}
		unless exists($res->{$k});
	}
	else {
	    # Parent takes precedence on arrays
	    unshift(@{$res->{$k} ||= []}, @{$parent->{$k}});
	}
    }
    return $res;
}

sub new {
    my($proto, $req, $class) = _new_args(@_);
    # Creates a Model with I<req>, if supplied.  The class of the model is defined by
    # C<$proto>.  If I<class> is supplied, L<get_instance|"get_instance"> is called
    # with I<class> as its argument and the resultant class is instantiated.
    return $proto->get_instance($class)->new($req)
	if defined($class);
    my($ci) = _get_class_info(ref($proto) || $proto);
    my($self) = $proto->SUPER::new({@{$ci->{properties}}});
    $self->[$_IDI] = {
	class_info => $ci,
        request => $req || (ref($proto) ? $proto->unsafe_get_request : undef),
    };
    return $self;
}

sub new_anonymous {
    my($proto, $config, $req) = @_;
    # Creates an "anonymous" Model.  There are two modes: initialization
    # and creation from existing.  To initialize, you must supply
    # I<config>.  This will create the first anonymous instance.
    # I<proto> must be a class name, not a reference.
    #
    # To create an instance from an existing instance, I<proto> must
    # be an instance, not a class name.  I<config> is ignored.
    my($ci) = ref($proto) ? $proto->[$_IDI]->{class_info}
	    : _initialize_class_info($proto, $config);
    # Make a copy of the properties for this instance.  properties
    # is an array_ref for efficiency.
    my($self) = $proto->SUPER::new({@{$ci->{properties}}});
    $self->[$_IDI] = {
	class_info => $ci,
	# Never save the request for first time anonymous classes
        request => ref($proto) ? $req : undef,
	anonymous => 1,
    };
    return $self;
}

sub new_other {
    # Creates a model instance of the specified class.
    my($self) = shift;
    return $self->get_instance(shift)->new($self->get_request, @_);
}

sub put {
    # Not supported.
    CORE::die('put: not supported');
}

sub put_on_request {
    my($self, $durable) = @_;
    # Adds this instance to the request, stored with the key
    # 'Model.<simple package name>'.
    #
    #
    # Adds the model to the request as a durable attribute. The model will
    # survive server redirects.
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

sub set_ephemeral {
    # (self) : self
    my($self) = @_;
    $self->[$_IDI]->{ephmeral} = 1;
    return $self;
}

sub throw_die {
    my($self, $code, $attrs, $package, $file, $line) = @_;
    # Terminate the I<model> as entity and request in I<attrs> with a specific code.
    #
    # I<package>, I<file>, and I<line> need not be defined
    $package ||= (caller)[0];
    $file ||= (caller)[1];
    $line ||= (caller)[2];
    $attrs ||= {};
    ref($attrs) eq 'HASH' || ($attrs = {message => $attrs});
    $attrs->{model} = $self;
    Bivio::Die->throw($code, $attrs, $package, $file, $line);
    # DOES NOT RETURN
}

sub unsafe_get_model {
    # Returns the named PropertyModel associated with this instance.
    # If it can be loaded, it will be.  See
    # L<Bivio::Biz::PropertyModel::is_loaded|Bivio::Biz::PropertyModel/"is_loaded">.
#     my($self, $class, $query) = @_;
#     $query ||= {};
#     return $self->new_other($class)
#         ->unsafe_load({map({($_ => $query->{$_} || $self)}
#             @{$self->get_instance($class)->get_model_keys()})});
    my($self, $name) = @_;
    my($fields) = $self->[$_IDI];
    return ($fields->{models} ||= {})->{$name}
	||= _load_other_model($self, $name);
}

sub unsafe_get_request {
    my($self) = @_;
    # Returns the request associated with this model (if defined).
    # Otherwise, returns the current request, if any.
    my($req);
    $req = $self->[$_IDI]->{request} if ref($self);
    # DON'T SET the request for future calls, because this may
    # be an anonymous model or a singleton.
    Bivio::IO::ClassLoader->simple_require('Bivio::Agent::Request');
    return $req ? $req : Bivio::Agent::Request->get_current;
}

sub _as_string_fields {
    my($sql_support) = @_;
    # Returns as_string_fields.
    return $sql_support->get('as_string_fields')
	if $sql_support->has_keys('as_string_fields');
    my($res) = [@{$sql_support->get('primary_key_names')}];
    unshift(@$res, 'name')
	if $sql_support->has_columns('name') && !grep($_ eq 'name', @$res);
    return $res;
}

sub _assert_class_name {
    my($class) = @_;
    # Ensures that the class conforms to the naming conventions.
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

sub _get_class_info {
    my($class) = @_;
    no strict qw(refs);
    _initialize_class_info($class)
	unless defined *{$class . '::'}{HASH}->{_CLASS_INFO};
    return *{$class . '::'}{HASH}->{_CLASS_INFO};
}

sub _get_model_query {
    my($self, $name) = @_;
    # Returns the model (query, instance) by looking for the model.
    # Asserts operation is valid
    my($sql_support) = $self->internal_get_sql_support;
    my($models) = $sql_support->get('models');
    $self->die("$name: no such model")
	unless defined($models->{$name});
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
		Bivio::IO::Alert->warn(
		    $self,
		    ': loading ', $m->{instance}, ' missing key ',
		    $map->{$pk}->{name});
		return (undef, $mi);
	    }
	    $v = $req->get('auth_id');
	}
	$query->{$pk} = $v;
    }
    return ($query, $mi);
}

sub _initialize_class_info {
    my($class, $config) = @_;
    # Initializes from class or from config.  config is supplied for
    # anonymous models (currently, only ListModels).
    # This may load the models and we'll try to get the class_info
    # again after the models are loaded.
    _load_all_property_models();

    # Have here for safety to avoid infinite recursion if called badly.
#    return if !$config && $_CLASS_INFO{$class};
    {
	no strict qw(refs);
        return if !$config && defined *{$class . '::'}{HASH}->{_CLASS_INFO};
    }

    _assert_class_name($class) unless $config;

    my($stmt) = Bivio::SQL::Statement->new();
    my($sql_support) = $class->internal_initialize_sql_support($stmt, $config);
    my($ci) = {
	sql_support => $sql_support,
        statement => $stmt,
	as_string_fields => _as_string_fields($sql_support),
	# Is an array, because faster than a hash_ref for our purposes
	properties => [map {
		($_, undef);
	    } @{$sql_support->get('column_names')},
	],
    };
    return $ci if $config;
    # $_CLASS_INFO{$class} is sentinel to stop recursion
#    $_CLASS_INFO{$class} = $ci;
    {
	no strict qw(refs);
        *{$class . '::'}{HASH}->{_CLASS_INFO} = $ci;
    }
    $ci->{singleton} = $class->new;
    delete($ci->{singleton}->[$_IDI]->{request});
    $ci->{singleton}->[$_IDI]->{is_singleton} = 1;
    return;
}

sub _load_all_property_models {
    # Loads the property models, if not already loaded.
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

sub _load_other_model {
    my($self, $name) = @_;
    # Does a bunch of asssertion checking
    my($query, $mi) = _get_model_query($self, $name);
    return $mi
	unless $query;
    my($aliases) = $self->get_info('column_aliases');
    my($values) = $self->internal_get;
    return $mi->internal_load_properties({
	map({
	    my($k) = $aliases->{"$name.$_"};
	    unless ($k && exists($values->{$k})) {
		$mi->unauth_load($query);
		return $mi;
	    }
	    ($k => $values->{$k});
	 } @{$mi->get_info('column_names')}),
    });
}

sub _new_args {
    my($proto, $req, $class) = @_;
    # Returns (proto, req, class).  Figures out calling form and returns
    # the correct parameter values.
    if (defined($req) && !ref($req)) {
	Bivio::Die->die($req,
	    ': bad parameter, expecting a Bivio::Agent::Request',
	) if defined($class);
	$class = $req;
	$req = undef;
    }
    return ($proto, $req || $proto->unsafe_get_request, $class);
}

1;
