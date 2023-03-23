# Copyright (c) 1999-2012 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model;
use strict;
use Bivio::Base 'Collection.Attributes';

# C<Bivio::Biz::Model> is more interface than implementation, it provides
# a common set of methods for L<Bivio::Biz::PropertyModel>,
# L<Bivio::Biz::ListModel>, L<Bivio::Biz::FormModel>.

our($_TRACE);
my($_LOADED_ALL_PROPERTY_MODELS);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_S) = b_use('SQL.Support');
my($_SS) = b_use('SQL.Statement');
my($_CL) = b_use('IO.ClassLoader');

sub as_string {
    my($self) = @_;
    my($ci) = $self->[$_IDI]->{class_info};
    return ref($self)
        . '('
        . join(
            ',',
            map(
                $self->get_field_type($_)->to_string($self->unsafe_get($_)),
                @{$ci->{as_string_fields}},
            ),
        )
        . ')';
}

sub assert_is_instance {
    my($self) = @_;
    b_die('operation not supported on classes, use get_instance')
        unless ref($self);
    return $self;
}

sub assert_not_singleton {
    my($self) = shift->assert_is_instance;
    b_die("can't create, update, read, or delete singleton instance")
        if $self->[$_IDI]->{is_singleton};
    return $self;
}

sub clone_return_is_self {
    return shift->is_instance ? 0 : 1;
}

sub delete {
    # Not supported.
    die('not supported');
}

sub delete_from_request {
    my($self) = @_;
    return $self->delete_from_req($self->unsafe_get_request || return);
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
    my($self, $handler) = _iterate_args_and_start(@_);
    while ($self->iterate_next_and_load) {
        next
            if $self->internal_verify_do_iterate_result(
                $handler->($self),
            );
        $self->put_on_request
            unless $self->is_ephemeral;
        last;
    }
    $self->iterate_end;
    return $self;
}

sub do_iterate_model_subclasses {
    my($proto, $op) = @_;
    foreach my $m (@{$_CL->map_require_all('Model')}) {
        next
            if !$proto->is_super_of($m)
            || _is_base_class($m);
        last
            unless $op->($m, $m->simple_package_name);
    }
    return;
}

sub field_decl {
    my($proto) = shift;
    if (ref($_[0]) eq 'ARRAY') {
        my($decls, $defaults) = (shift, shift);
        $defaults = {
            type => $defaults,
            constraint => shift,
        } unless ref($defaults) eq 'HASH';
        $defaults->{constraint} ||= 'NONE';
        return map({
            my($decl) = ref($_) ? $_ : [$_];
            my($i) = 0;
            ref($_) eq 'HASH' ? {%$defaults, %$decl} : +{
                %$defaults,
                map(
                    {
                        my($d) = $decl->[$i++];
                        ref($d) eq 'HASH' ? %$d : defined($d) ? ($_ => $d) : ();
                    }
                    qw(name type constraint),
                ),
            };
        } @$decls);
    }
    my($defaults) = [];
    unshift(@$defaults, pop(@_))
        while ref($_[$#_]) ne 'ARRAY';
    Bivio::Die->die('expecting class and declarations')
        unless @_ > 1;
    Bivio::Die->die('uneven (class, declarations) tuples')
        if @_ % 2;
    return map(
        (shift(@_) => [$proto->field_decl(shift(@_), @$defaults)]),
        1 .. @_ / 2,
    );
}

sub field_decl_exclude {
    my($self, $field, $info) = @_;
    $info = b_use('IO.Ref')->nested_copy($info);
    my($ne) = sub {
        my($x) = @_;
        return (ref($x) eq 'HASH' ? $x->{name} : $x) ne $field;
    };
    while (my($k, $v) = each(%$info)) {
        if (ref($v) eq 'ARRAY') {
            @$v = map(
                ref($_) eq 'ARRAY'
                    ? [grep($ne->($_), @$_)]
                    : grep($ne->($_), $_),
                @$v,
            );
        }
        elsif (!ref($v)) {
            delete($info->{$k})
                if ($v || '') eq $field;
        }
        else {
            b_die($k, ': unexpected value type: must be array_ref or scalar');
        }
    }
    return $info;
}

sub field_decl_from_property_model {
    my($self, $class) = @_;
    my($m) = $self->get_instance($class);
    return map(
        $m->simple_package_name . ".$_",
        @{$m->get_info('column_names')},
    );
}

sub field_equals {
    my($self, $field, $value) = @_;
    return $self->get_field_type($field)->is_equal($value, $self->get($field));
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

sub from_req {
    my($proto, $req, $class) = @_;
    return $req->get(_class($proto, $class));
}

sub get_as {
    my($self, $field, $format) = @_;
    return $self->get_field_info($field, 'type')->$format($self->get($field));
}

sub get_auth_id {
    return _well_known_value(@_);
}

sub get_auth_id_name {
    my($self) = @_;
    return _well_known_name(
        $self,
        [qw(auth_id realm_id)],
        $self->get_info('auth_id'),
    );
}

sub get_auth_user_id {
    return _well_known_value(@_);
}

sub get_auth_user_id_name {
    my($self) = @_;
    return _well_known_name(
        $self,
        [qw(auth_user_id user_id)],
        [grep(/\buser_id$/, @{$self->get_info('column_names')})],
    );
}

sub get_field_alias_value {
    my($self, $alias) = @_;
    return $self->get(
        ($self->get_info('column_aliases')->{$alias}
             || $self->die($alias, ': not a field alias')
        )->{name});
}

sub get_field_constraint {
    # Returns the constraint for this field.
    #
    # Calls L<get_field_info|"get_field_info">, so subclasses only need
    # to override C<get_field_info>.
    return shift->get_field_info(shift, 'constraint');
}

sub get_field_info {
    return shift->internal_get_sql_support_no_assert->get_column_info(@_);
}

sub get_field_type {
    # Returns the type of this field.
    #
    # Calls L<get_field_info|"get_field_info">, so subclasses only need
    # to override C<get_field_info>.
    return shift->get_field_info(shift, 'type');
}

sub get_info {
    return shift->internal_get_sql_support_no_assert->get(shift);
}

sub get_instance {
    my($proto, $class) = @_;
    # Returns the singleton for I<class>.  If I<class> is supplied, it may be just
    # the simple name or a fully qualified class name.  It will be loaded with
    # L<Bivio::IO::ClassLoader|Bivio::IO::ClassLoader> using the I<Model> map.
    # I<class> may also be an instance of a model.
    #
    # May not be called on anonymous Models without I<class> argument.
    return _get_class_info(_class($proto, $class))->{singleton};
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

sub get_model_info {
    my($self, $model) = @_;
    return $self->unsafe_get_model_info($model)
        || b_die($model, ': no such model');
}

sub get_primary_id {
    return _well_known_value(@_);
}

sub get_primary_id_name {
    my($self) = @_;
    return _well_known_name(
        $self,
        ['primary_id'],
        $self->get_info('primary_key_names'),
    );
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
    return $self->unsafe_get_request
        || b_die($self, ': request not set');
}

sub handle_call_autoload {
    my($proto) = @_;
    return $proto
        if _is_base_class($proto)
        || $proto->can('internal_initialize') == \&Bivio::Biz::Model::internal_initialize;
    return _new_with_query(@_);
}

sub has_fields {
    return shift->internal_get_sql_support_no_assert->has_columns(@_);
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
    my($self) = @_;
    return $self->assert_is_instance->[$_IDI]->{class_info}->{sql_support};
}

sub internal_get_statement {
    return shift->assert_not_singleton->[$_IDI]->{class_info}->{statement};
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
    Bivio::IO::Alert->warn_deprecated('use field_decl');
    return [shift->field_decl(@_)];
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
    return $self->[$_IDI]->{ephemeral} ? 1 : 0;
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

sub local_field {
    Bivio::IO::Alert->warn_deprecated('use field_decl');
    return shift->field_decl(@_);
}

sub map_iterate {
    my($self, $handler) = _iterate_args_and_start(@_);
    my($res) = [];
    my($op) = _map_iterate_handler($handler);
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
    my($self, $model_name) = (shift, shift);
    return ($_S->is_qualified_model_name($model_name)
        ? $_S->parse_model_name($model_name)->{model}
        : $self->get_instance($model_name)
    )->new($self->get_request, @_);
}

sub new_other_with_query {
    my($proto, $name, $query) = @_;
    return _new_with_query($proto->get_instance($name), $query);
}

sub put {
    # Not supported.
    CORE::die('put: not supported');
}

sub put_on_request {
    my($self, $durable) = @_;
    $self->set_ephemeral(0);
    return $self->unsafe_get_request
        ? $self->put_on_req($self->req, $durable)
        : $self;
}

sub set_ephemeral {
    my($self, $value) = @_;
    $self->[$_IDI]->{ephemeral} = @_ < 2 || $value ? 1 : 0;
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

sub unsafe_get_model_info {
    my($self, $model) = @_;
    return $self->get_info('models')
        ->{ref($model) ? $model->simple_package_name : $model};
}

sub unsafe_get_request {
    my($self) = @_;
    # Returns the request associated with this model (if defined).
    # Otherwise, returns the current request, if any.
    my($req);
    $req = $self->[$_IDI]->{request} if ref($self);
    # DON'T SET the request for future calls, because this may
    # be an anonymous model or a singleton.
    return $req ? $req : b_use('Agent.Request')->get_current;
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
    b_die(
        $class,
        ': is a base class; it cannot be initialized as a model',
    ) if _is_base_class($class);
    my($super) = b_use(
        'Biz',
        (_class_suffix($class) || 'Property') . 'Model',
    );
    b_die($class, ': must be a ', $super)
        unless $super->is_super_of($class);
    return;
}

sub _class {
    my($proto, $class) = @_;
    return ref($proto) || $proto
        unless defined($class);
    return b_use('Model', $class)
        unless ref($class);
    return ref($class) || $class;
}

sub _class_suffix {
    my($class) = @_;
    return $class =~ /(ListForm|Form|List)$/ ? $1 : '';
}

sub _get_class_info {
    my($class) = @_;
    no strict 'refs';
    my($var) = \${*{$class . '::'}}{HASH}->{_CLASS_INFO};
    _initialize_class($class, $var)
        unless $$var;
    return $$var;
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
                $self->req->warn(
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

sub _initialize_class {
    my($class, $var) = @_;
    _load_all_property_models();
    return
        if $$var;
    # Initializes from class or from config.  config is supplied for
    # anonymous models (currently, only ListModels).
    # This may load the models and we'll try to get the class_info
    # again after the models are loaded.
    _assert_class_name($class);
    my($ci) = _initialize_class_info($class);
    $$var = $ci;
    $ci->{singleton} = $class->new;
    delete($ci->{singleton}->[$_IDI]->{request});
    $ci->{singleton}->[$_IDI]->{is_singleton} = 1;
    return;
}

sub _initialize_class_info {
    my($class, $config) = @_;
    my($stmt) = $_SS->new;
    my($sql_support) = $class->internal_initialize_sql_support($stmt, $config);
    return {
        sql_support => $sql_support,
        statement => $stmt,
        as_string_fields => _as_string_fields($sql_support),
        # Is an array, because faster than a hash_ref for our purposes
        properties => [map(($_, undef), @{$sql_support->get('column_names')})],
    };
}

sub _is_base_class {
    my($class) = @_;
    return $class =~ qr{Base(@{[_class_suffix($class)]})?$} ? 1 : 0;
}

sub _iterate_args_and_start {
    my($self, $handler, @args) = @_;
    my($start) = $self->b_can($args[0]) && $args[0] =~ /iterate_start/
        ? shift(@args) : 'iterate_start';
    $self->$start(@args);
    return ($self, $handler);
}

sub _load_all_property_models {
    return
        if $_LOADED_ALL_PROPERTY_MODELS;
    $_LOADED_ALL_PROPERTY_MODELS = 1;
    b_use('Biz.PropertyModel')->do_iterate_model_subclasses(
        sub {
            shift->get_instance;
            return 1;
        },
    );
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

sub _map_iterate_handler {
    my($handler) = @_;
    return $handler
        if ref($handler);
    return sub {shift->get($handler)}
        if defined($handler);
    return sub {shift->get_shallow_copy};
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

sub _new_with_query {
    my($proto, $query) = @_;
    # Instantiates I<model> and loads/processes I<query> if supplied.
    my($self) = $proto->new;
    return $self
        unless $query;
    my($is_unauth) = $proto->my_caller(1) =~ /unauth/;
    if ($self->isa('Bivio::Biz::FormModel')) {
        $self->process($query);
    }
    elsif ($self->isa('Bivio::Biz::ListModel')) {
        my($method) = $is_unauth ? 'unauth_load_all' : 'load_all';
        $self->$method($query);
        $self->set_cursor(0);
    }
    elsif ($self->isa('Bivio::Biz::PropertyModel')) {
        my($method) = $is_unauth ? 'unauth_load_or_die' : 'load';
        $self->$method($query);
    }
    else {
        b_die($self, ': does not support query argument: ', $query);
    }
    return $self;
}

sub _well_known_name {
    my($self, $names, $choices) = @_;
    foreach my $n (@$names) {
        my($constant) = uc($n) . '_FIELD';
        return $self->$constant()
            if $self->can($constant);
    }
    $self->die($names, ': no choices')
        unless defined($choices);
    return $choices->{name}
        if ref($choices) eq 'HASH';
    $self->die($choices, ": too many $names->[0] values")
        if @$choices > 1;
    $self->die($choices, ": too few $names->[0] values")
        if @$choices < 1;
    return $choices->[0];
}

sub _well_known_value {
    my($self) = @_;
    my($name) = $self->my_caller . '_name';
    return $self->get($self->$name());
}

1;
