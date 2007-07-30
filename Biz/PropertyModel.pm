# Copyright (c) 1999-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::PropertyModel;
use strict;
use base 'Bivio::Biz::Model';
use Bivio::Die;
use Bivio::DieCode;
use Bivio::IO::Trace;
use Bivio::SQL::ListQuery;
use Bivio::SQL::PropertySupport;
use Carp ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);

sub cascade_delete {
    my($self, $query) = @_;
    my($support) = $self->internal_get_sql_support;
    my($method) = $support->get('cascade_delete_children') ? 'cascade_delete'
	: 'delete_all';
    my($properties) = $query || $self->get_shallow_copy;
    foreach my $c (@{$support->get_children}) {
	my($child) = $self->new_other($c->[0]);
	my($key_map) = $c->[1];
	$child->$method({
	    map({
		my($ck) = $key_map->{$_};
		exists($properties->{$ck}) ? ($_ => $properties->{$ck}) : ();
	    } keys(%$key_map)),
	});
    }
    $query ? $self->delete_all($query) : $self->delete;
    return;
}

sub create {
    my($self, $new_values) = @_;
    # Creates a new model in the database with the specified values. After creation,
    # this instance takes ownership of I<new_values>.  Dies on error.
    #
    # Returns I<self>.
    $new_values = _dup($new_values);
    my($sql_support) = $self->internal_get_sql_support;
    # Make sure all columns are defined
    my($n);
    foreach $n (@{$sql_support->get('column_names')}) {
	$new_values->{$n} = undef unless exists($new_values->{$n});
    }
    $sql_support->create($new_values, $self);
    return $self->internal_load_properties($new_values);
}

sub create_from_literals {
    my($self, $values) = @_;
    # Converts and validates I<values> calling
    # L<Bivio::Type::from_literal_or_die|Bivio::Type/"from_literal_or_die">
    # for types of I<values>.
    #
    # B<Note: I<from_literal_or_die> dies on NULL.>
    #
    # Only validates keys which exist, i.e. primary keys or values which
    # are defaulted by L<create|"create"> are not validated.
    $values = _dup($values);
    while (my($k, $v) = each(%$values)) {
	$values->{$k} = $self->get_field_type($k)->from_literal_or_die($v);
    }
    return $self->create($values);
}

sub create_or_unauth_update {
    # B<DEPRECATED>
    Bivio::IO::Alert->warn_deprecated('Use unauth_create_or_update instead.');
    return shift->unauth_create_or_update(@_);
}

sub create_or_update {
    my($self, $new_values) = @_;
    # Tries to load the model based on its primary key values.
    # If the load is successful, the model will be updated with
    # the new values. Otherwise, a new model is created.
    #
    # Adds auth_id to I<new_values>. 
    #
    # See also L<unauth_create_or_update|"unauth_create_or_update">.
    return $self->unauth_create_or_update(_add_auth_id($self, $new_values));
}

sub delete {
    my($self) = @_;
    # Deletes the current model from the database.   Dies on error.
    #
    # If I<load_args> is supplied, deletes the model specified by
    # I<load_args> and not the current model.  May be called statically.
    #
    #
    # B<DEPRECATED>
    return $self->internal_get_sql_support->delete($self->internal_get, $self)
	if @_ <= 1;
    my($query);
    ($self, $query) = _load_args(@_);
    $self = $self->new()
	unless ref($self);
    return $self->internal_get_sql_support->delete(
	$self->internal_prepare_query(_add_auth_id($self, $query)),
	$self,
    );
}

sub delete_all {
    my($self, $query) = @_;
    # Deletes all the models of this type with the specified (possibly
    # partial key) query. Returns the number of models deleted.
    $self = $self->new
	unless ref($self);
    my($rows) =  $self->internal_get_sql_support->delete_all(
	$self->internal_prepare_query(_add_auth_id($self, $query)),
	$self,
    );
    _trace($rows, ' ', ref($self)) if $_TRACE;
    return $rows;
}

sub execute_auth_user {
    my($proto, $req) = @_;
    # Loads this auth user's data as if realm_id.
    $proto->new($req)->load_for_auth_user;
    return 0;
}

sub execute_load {
    my($proto, $req) = @_;
    # Loads this model using no params except auth_id.
    $proto->new($req)->load();
    return 0;
}

sub execute_load_parent {
    my($proto, $req) = @_;
    # Loads a new instance of this class using the request using
    # the "parent" on the request query.
    # See L<load_parent_from_request|"load_parent_from_request">
    $proto->new($req)->load_parent_from_request();
    return 0;
}

sub execute_load_this {
    my($proto, $req) = @_;
    # Loads a new instance of this class using the request using
    # the "this" on the request.
    # See L<load_this_from_request|"load_this_from_request">
    $proto->new($req)->load_this_from_request();
    return 0;
}

sub execute_unauth_delete_this {
    my($proto, $req) = @_;
    # Deletes the "this" model by calling get_model for this model.
    # Deletes "this" from list query and query.
    my($lm) = $req->get('list_model');
    $lm->set_cursor_or_not_found(0);
    $lm->get_model($proto->simple_package_name)->unauth_delete;
    $lm->get_query->delete('this');
    delete($req->get('query')->{Bivio::SQL::ListQuery->to_char('this')});
    return;
}

sub execute_unauth_load_this {
    my($proto, $req) = @_;
    # Loads a new instance of this class using the request using
    # the "this" on the request.
    # See L<unauth_load_this_from_request|"unauth_load_this_from_request">
    my($self) = $proto->new($req);
    $self->throw_die('MODEL_NOT_FOUND')
	unless $self->unauth_load_this_from_request;
    return 0;
}

sub format_query_for_parent {
    my($self) = @_;
    # Query string used to identify this instance using "parent" key,
    # so can be used with I<load_parent_from_request>.
    return Bivio::SQL::ListQuery->format_uri_for_this_as_parent(
	    $self->internal_get_sql_support, $self->internal_get);
}

sub format_query_for_this {
    my($self, $query) = @_;
    # Query string used to identify this instance.  If supplied I<load_query>,
    # must contain primary keys for the model.
    return Bivio::SQL::ListQuery->format_uri_for_this(
	    $self->internal_get_sql_support, $query || $self->internal_get);
}

sub get_keys {
    # B<DEPRECATED>
    #
    # Returns a copy of the I<column_names> attribute.
    #
    # TODO: Need to move this up to Model, but I think this might break ListModel and
    # FormModel, because get_keys returns all keys and column_names only returns
    # declared columns.  Some models don't declare all their columns.
    return [@{shift->get_info('column_names')}];
}

sub get_qualified_field_name {
    # Returns qualified field name (Model.field) for field.
    return shift->simple_package_name . '.' . shift(@_);
}

sub internal_get_target {
    my($self, $model, $model_prefix, $values) = @_;
    # Returns the class, target model and optional model prefix. This method is used
    # by subclasses when defining a method which can operate on self, on another
    # model target, or $values. For an example, see RealmOwner.format_email.
    # If values is undef, internal_get is called on the model.
    $model ||= $self;
    return (
	ref($self) || $self,
	$model,
	$model_prefix || '',
	$values || $model->internal_get,
    );
}

sub internal_initialize_sql_support {
    my($proto, $stmt, $config) = @_;
    # Returns the L<Bivio::SQL::PropertySupport|Bivio::SQL::PropertySupport>
    # for this class.  Calls L<internal_initialize|"internal_initialize">
    # to get the hash_ref to initialize the sql support instance.
    die('cannot create anonymous PropertyModels') if $config;
    $config = $proto->internal_initialize;
    $config->{class} = ref($proto) || $proto;
    return  Bivio::SQL::PropertySupport->new($config);
}

sub internal_load_properties {
    my($self, $values) = @_;
    # Loads model with values as properties.  DOES NOT MAKE A COPY of values.
    $self->internal_clear_model_cache;
    unless (__PACKAGE__ eq (caller)[0]) {
	foreach my $k (@{$self->get_info('column_names')}) {
	    $self->die($k, ': missing column')
		unless exists($values->{$k});
	}
    }
    $self->internal_put($values);
    $self->put_on_request;
    return $self;
}

sub internal_prepare_query {
    # Returns I<query> after fixing it up.
    shift;
    return shift;
}

sub internal_unload {
    my($self) = @_;
    # Clears the model state, if loaded.  Deletes from request.
    return $self
	unless $self->is_loaded;
    _unload($self, 1);
    return $self;
}

sub is_loaded {
    # Returns true if the model is loaded (or created), i.e. contains
    # valid values.
    # If we have values, we're loaded.
    return %{shift->internal_get} ? 1 : 0;
}

sub iterate_next_and_load {
    my($self) = shift;
    # Will iterate to the next row and load the model with the row.
    # Can be used to update a row.
    #
    # Returns false if there is no next.
    #
    # B<Deprecated form accepts an iterator as the first argument.>
    my(undef, $row) = $self->internal_iterate_next(@_, {});
    return $row ? _load($self, $row) : _unload($self, 1);
}

sub iterate_next_and_load_new {
    my($self, $row) = shift->internal_iterate_next(@_, {});
    # Same as L<iterate_next_and_load|"iterate_next_and_load">, but
    # returns a new model instance for each row if iteration proceeds.
    # Returns C<undef> if end of iteration.
    #
    # B<Deprecated form accepts an iterator as the first argument.>
    return $row ? $self->new->internal_load_properties($row) : undef;
}

sub iterate_start {
    my($self, $order_by, $query) = @_;
    # Begins an iteration which can be used to iterate the rows for this
    # realm with L<iterate_next|"iterate_next">,
    # L<iterate_next_and_load|"iterate_next_and_load">, or
    # L<iterate_next_and_load_new|"iterate_next_and_load_new">.
    # L<iterate_end|"iterate_end"> should be called when you are through
    # with the iteration.
    #
    # I<order_by> is an SQL C<ORDER BY> clause without the keywords C<ORDER BY>.
    #
    # I<query> is the same as in L<load|"load">.
    #
    # B<Deprecated form returns the iterator.>
    $self->throw_die('DIE', 'no auth_id')
	unless $self->get_request->get('auth_id');
    return $self->unauth_iterate_start(
	$order_by, _add_auth_id($self, $query || {}));
}

sub load {
    my($self) = shift;
    # Loads the model or dies if not found or other error.
    # Subclasses shouldn't override this method.
    #
    # Note: I<query> may be modified by this method.
    #
    # Returns I<self>.
    #
    #
    # B<DEPRECATED>
    return $self if $self->unsafe_load(@_);
    _die_not_found($self, \@_, caller);
    # DOES NOT RETURN
}

sub load_for_auth_user {
    my($self) = @_;
    # Loads the model for auth_user.
    return $self->unauth_load({
	realm_id => (
	    $self->get_request->get('auth_user') || $self->die('no auth_user')
	)->get('realm_id'),
    });
}

sub load_parent_from_request {
    my($self) = @_;
    # Parses the query from the request (or list_model) and then L<load|"load">.
    # Uses "parent" key in query or list model.
    #
    # See also L<unsafe_load_parent_from_request|"unsafe_load_parent_from_request">.
    my($q) = _parse_query($self, 1);
    $self->throw_die(Bivio::DieCode::CORRUPT_QUERY(),
	    {message => 'see previous warning, too'}, caller)
	    unless $q;
    return $self->load($q);
}

sub load_this_from_request {
    my($self) = @_;
    # Parses the query from the request (or list_model) and then L<load|"load">.
    # Uses "this" key in query or list model.
    #
    # See also L<unsafe_load_this_from_request|"unsafe_load_this_from_request">.
    my($q) = _parse_query($self, 0);
    $self->throw_die(Bivio::DieCode::CORRUPT_QUERY(),
	    {message => 'see previous warning, too'}, caller)
	    unless $q;
    return $self->load($q);
}

sub merge_initialize_info {
    my($proto, $parent, $child) = @_;
    Bivio::Die->die('columns, if defined, must be a hash_ref')
        unless ref($parent->{columns} || {}) eq 'HASH'
	    && ref($child->{columns} || {}) eq 'HASH';
    return shift->SUPER::merge_initialize_info($parent, {
	%$child,
	columns => {
	    %{delete($parent->{columns}) || {}},
	    %{$child->{columns} || {}},
	},
    });
}

sub new {
    my($self) = shift->SUPER::new(@_);
    # Create a new PropertyModel associated with the request.
    _unload($self, 0);
    return $self;
}

sub register_child_model {
    return shift->internal_get_sql_support_no_assert->register_child_model(@_);
}

sub unauth_create_or_update {
    my($self, $new_values) = @_;
    # Tries to load the model based on its primary key values.
    # If the load is successful, the model will be updated with
    # the new values. Otherwise, a new model is created.
    #
    # Calls L<unauth_load|"unauth_load">.
    #
    # See also L<create_or_update|"create_or_update">.
    my($pk_values) = _get_primary_keys($self, $new_values);
    return $pk_values && $self->unauth_load($pk_values)
	    ? $self->update($new_values) : $self->create($new_values);
}

sub unauth_create_or_update_keys {
    my($self, $values, $modified_key) = @_;
    # Create or update keys.  I<modified_key> is the key that could be
    # changed/updated.

    $self->do_iterate(sub {
	my($model) = @_;
	$model->delete()
	    unless $model->get($modified_key) eq $values->{$modified_key};
	return 1;
    }, 'unauth_iterate_start', undef, {
	map({$_ => $values->{$_}}
	    grep({$_ ne $modified_key}
	        @{$self->get_info('primary_key_names')}))
    });

    return $self->unauth_create_or_update($values);
}

sub unauth_delete {
    my($self, $load_args) = @_;
    # Deletes the current model from the database.   Doesn't check
    # auth_id.  Dies on error.
    #
    # If I<load_args> is supplied, deletes the model specified by
    # I<load_args> and not the current model.  May be called statically.
    # Just like L<unauth_load|"unauth_load">.
    #
    # Note: I<query> may be modified by this method.
    $load_args ||= $self->internal_get;
    $self = $self->new()
	unless ref($self);
    $self->die('load_args or model must not be empty')
	unless %$load_args;
    return $self->internal_get_sql_support->delete(
	$self->internal_prepare_query({%$load_args}), $self);
}

sub unauth_iterate_start {
    my($self, $order_by, $query) = @_;
    # B<Do not use this method unless you are sure the user is authorized
    # to access all realms or all rows of the table.>
    #
    # Begins an iteration which can be used to iterate the rows for this
    # realm with L<iterate_next|"iterate_next">,
    # L<iterate_next_and_load|"iterate_next_and_load">, or
    # L<iterate_next_and_load_new|"iterate_next_and_load_new">.
    # L<iterate_end|"iterate_end"> should be called when you are through
    # with the iteration.
    #
    # I<order_by> is an SQL C<ORDER BY> clause without the keywords
    # C<ORDER BY>.
    #
    # I<query> is the same as in L<load|"load">.
    #
    # B<Deprecated form returns the iterator.>
    return $self->internal_put_iterator(
	$self->internal_get_sql_support->iterate_start(
	    $self,
	    $order_by || _default_order_by($self),
	    $self->internal_prepare_query(_dup($query)),
	),
    );
}

sub unauth_load {
    my($self, $query) = _load_args(@_);
    # Loads the model as with L<unsafe_load|"unsafe_load">.  However, does
    # not insert security realm into query params.  Use this when you
    # B<are certain> there are no security issues involved with loading
    # the data.
    #
    # On success, saves model in request and returns true.
    #
    # Returns false if not found.  Dies on any other errors.
    #
    # Subclasses should override this method if there model doesn't match
    # the usual property model.  L<unsafe_load|"unsafe_load"> and
    # L<load|"load"> call this method.
    #
    # Note: I<query> may be modified by this method.
    #
    #
    # B<DEPRECATED>
    # Don't bother checking query.  Will kick back if empty.
    my($values) = $self->internal_get_sql_support->unsafe_load(
	$self->internal_prepare_query(_dup($query)), $self);
    return $values ? _load($self, $values) : _unload($self, 1);
}

sub unauth_load_or_die {
    my($self) = shift;
    # See L<unauth_load|"unauth_load"> for params.  Throws a C<MODEL_NOT_FOUND>
    # exception if the load fails.
    #
    # Returns I<self>.
    #
    #
    # B<DEPRECATED>
    return $self if $self->unauth_load(@_);
    _die_not_found($self, \@_, caller);
    # DOES NOT RETURN
}

sub unauth_load_parent_from_request {
    my($self) = @_;
    # Parses the query from the request (or list_model) and then
    # L<unauth_load|"unauth_load">.  If there is no query or the query is
    # corrupt, returns false.
    #
    # See also L<load_parent_from_request|"load_parent_from_request">.
    my($q) = _parse_query($self, 1);
    return $q ? $self->unauth_load($q) : 0;
}

sub unauth_load_this_from_request {
    my($self) = @_;
    # Parses the query from the request (or list_model) and then
    # L<unauth_load|"unauth_load">.  If there is no query or the query is
    # corrupt, returns false.
    #
    # See also L<load_this_from_request|"load_this_from_request">.
    my($q) = _parse_query($self, 0);
    return $q ? $self->unauth_load($q) : 0;
}

sub unsafe_load {
    my($self, $query) = _load_args(@_);
    # Loads the model.  On success, saves model in request and returns true.
    #
    # Returns false if not found.  Dies on all other errors.
    #
    # Subclasses shouldn't override this method.
    #
    # B<This method will be dynamically overridden.  See
    # L<internal_initialize_sql_support|"internal_initialize_sql_support">>.
    #
    # Note: I<query> may be modified by this method.
    #
    #
    # B<DEPRECATED>
    return $self->unauth_load(_add_auth_id($self, $query));
}

sub unsafe_load_parent_from_request {
    my($self) = @_;
    # Loads this model from the parent value in the query on the request.
    my($q) = _parse_query($self, 1);
    return $q ? $self->unsafe_load($q) : 0;
}

sub unsafe_load_this_from_request {
    my($self) = @_;
    # Parses the query from the request (or list_model) and then
    # L<unsafe_load|"unsafe_load">.  If there is no query or the query is corrupt,
    # returns false.
    #
    # See also L<load_this_from_request|"load_this_from_request">.
    my($q) = _parse_query($self, 0);
    return $q ? $self->unsafe_load($q) : 0;
}

sub update {
    my($self, $new_values) = @_;
    # Updates the current model's values.
    # NOTE: load() should be called prior to an update.
    #
    # Returns I<self>.
    $new_values = _dup($new_values);
    Bivio::Die->die('model is not loaded')
	unless $self->is_loaded;
    $self->internal_clear_model_cache;
    my($properties) = $self->internal_get;
    $self->internal_get_sql_support->update($properties, $new_values, $self);
    foreach my $n (keys(%$new_values)) {
	$properties->{$n} =  $new_values->{$n};
    }
    return $self;
}

sub _add_auth_id {
    my($self, $query) = @_;
    # Adds the auth_id field and value to the query, if defined. Returns
    # the query.
    #
    # Ensure we are only accessing data from the realm we are authorized
    # to operate in.
    $query = _dup($query);
    my($sql_support) = $self->internal_get_sql_support;
    my($auth_field) = $sql_support->get('auth_id');
    # Warn if we are overriding an existing value for auth_id
    if ($auth_field) {
	my($id) = $self->get_request->get('auth_id');
	my($n) = $auth_field->{name};
	Bivio::IO::Alert->warn(
	    $self, ": overriding $n=$query->{$n} in query with auth_id=$id",
	    " from request.  You might need to call an unauth_* method instead"
	) if exists($query->{$n}) && $query->{$n} ne $id;
#        Bivio::Die->die() if exists($query->{$n}) && $query->{$n} ne $id;
        $query->{$n} = $id;
    }
    return $query;
}

sub _default_order_by {
    return join(
	',',
	map($_->{sql_name} . ' ' . ($_->{sort_order} ? 'ASC' : 'DESC'),
	    @{shift->get_info('primary_key')}));
}

sub _die_not_found {
    my($self, $args, $pkg, $file, $line) = @_;
    # Dies with appropriate exception.
    ($self, $args) = _load_args($self, @$args);
    $self->throw_die(Bivio::DieCode->MODEL_NOT_FOUND, $args, $pkg,
        $file, $line);
    # DOES NOT RETURN
}

sub _dup {
    my($v) = @_;
    return $v ? {%$v} : {};
}

sub _get_primary_keys {
    my($self, $new_values) = @_;
    # If new_values contains all primary keys, returns a copy as a hash_ref.
    # Else returns undef.
    my(%pk_values);
    my($have_keys) = 1;
    foreach my $pk (@{$self->get_info('primary_key_names')}) {
        unless (exists($new_values->{$pk})) {
            $have_keys = 0;
	    _trace($pk, ': missing primary key') if $_TRACE;
            last;
        }
        $pk_values{$pk} = $new_values->{$pk};
    }
    return $have_keys ? \%pk_values : undef;
}

sub _load {
    # Initializes the self with values and returns 1.
    shift->internal_load_properties(@_);
    return 1;
}

sub _load_args {
    my($self) = shift;
    # Parses load args and returns ($self, $query).
    return ($self, (int(@_) == 1 ? @_ : {@_}));
}

sub _parse_query {
    my($self, $want_parent) = @_;
    # Does work of unsafe_load_this/parent_from_request.
    my($req) = $self->get_request;
    my($support) = $self->internal_get_sql_support;
    my($list_model, $q) = $req->unsafe_get('list_model', 'query');
    # Pass a copy of the query, because it is trashed by ListQuery.
    my($query) = $list_model ? $list_model->get_query()
	    : $q ? Bivio::SQL::ListQuery->new({
		%$q,
		auth_id => $req->get('auth_id'),
		count => 1}, $support, $self)
		    : undef;
    # No query is not a _query_err
    return undef unless $query;

    # Use this if available, else parent_id
    my($key);
    my($pk_cols) = $support->get('primary_key');
    if ($want_parent) {
	my($parent_id) = $query->get('parent_id');
	# parent_id has some restrictions, check them
#TODO: why can't we have a _query_err here.  Too many messages otherwise.
	return undef unless $parent_id;
#TODO: Need to make this work more cleanly
	my($i) = int(@$pk_cols);
	die('expecting one or two primary key columns for parent_id')
		if $i > 2;
	if ($i == 1) {
	    $key = [$parent_id];
	}
	else {
#TODO: Make this cleaner
	    # This is a hack.  We need to add in the auth_id to the
	    # query so that the code creating @query works.  However,
	    # load overrides auth_id always.
	    my($auth_col) = $support->get('auth_id');
	    my($auth_id) = $req->get('auth_id');
	    if ($auth_col->{name} eq $pk_cols->[0]->{name}) {
		$key = [$auth_id, $parent_id];
	    }
	    elsif ($auth_col->{name} eq $pk_cols->[1]->{name}) {
		$key = [$parent_id, $auth_id];
	    }
	    else {
		# Should never happen, of course
		die('(auth_id, parent_id) not primary key');
	    }
	}
    }
    else {
	$key = $query->get('this');
	return _query_err($self, 'missing this') unless $key;
    }

    # Create the query acceptable to load (which always adds auth_id)
    my(%query) = ();
    my($i) = 0;
    foreach my $col (@$pk_cols) {
	return _query_err($self, "column $col->{name} is NULL")
		unless defined($key->[$i]);
	$query{$col->{name}} = $key->[$i++];
    }
    return \%query;
}

sub _query_err {
    my($self, $msg) = @_;
    # Outputs a warning and returns undef.
    $self->get_request->warn($self, ' query error: ', $msg);
    return undef;
}

sub _unload {
    my($self, $delete_from_request) = @_;
    # Always returns false.
    $self->internal_clear_model_cache;
    $self->internal_put({});
    $self->delete_from_request if $delete_from_request;
    return 0;
}

1;
