# Copyright (c) 1999-2006 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::PropertyModel;
use strict;
$Bivio::Biz::PropertyModel::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::PropertyModel::VERSION;

=head1 NAME

Bivio::Biz::PropertyModel - An abstract model with a set of named elements

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::PropertyModel;

=cut

=head1 EXTENDS

L<Bivio::Biz::Model>

=cut

use Bivio::Biz::Model;
@Bivio::Biz::PropertyModel::ISA = ('Bivio::Biz::Model');

=head1 DESCRIPTION

C<Bivio::Biz::PropertyModel> implements the data modification languange (DML)
interface to the database.  Attributes match columns one-to-one.

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::DieCode;
use Bivio::IO::Trace;
use Bivio::SQL::ListQuery;
use Bivio::SQL::PropertySupport;
use Carp ();

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::Request req) : Bivio::Biz::PropertyModel

Create a new PropertyModel associated with the request.

=cut

sub new {
    my($self) = shift->SUPER::new(@_);
    _unload($self, 0);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="cascade_delete"></a>

=head2 cascade_delete()

Deletes all related child models and then the current model.

=cut

sub cascade_delete {
    my($self) = @_;
    my($children) = $self->internal_get_sql_support->get_children;

    # iterate backward, dependencies are reversed
    for (my $i = int(@$children) - 2; $i >= 0; $i -= 2) {
	my($child) = $children->[$i];
	my($key_map) = $children->[$i + 1];

	# copy the current model's key values into the query
	my($query) = {};
	foreach my $key (keys(%$key_map)) {
	    $query->{$key} = $self->get($key_map->{$key});
	}
	$child->delete_all($query);
    }
    $self->delete;
    return;
}

=for html <a name="create"></a>

=head2 create(hash_ref new_values) : Bivio::Biz::PropertyModel

Creates a new model in the database with the specified values. After creation,
this instance takes ownership of I<new_values>.  Dies on error.

Returns I<self>.

=cut

sub create {
    my($self, $new_values) = @_;
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

=for html <a name="create_from_literals"></a>

=head2 create_from_literals(hash_ref values) : self

Converts and validates I<values> calling
L<Bivio::Type::from_literal_or_die|Bivio::Type/"from_literal_or_die">
for types of I<values>.

B<Note: I<from_literal_or_die> dies on NULL.>

Only validates keys which exist, i.e. primary keys or values which
are defaulted by L<create|"create"> are not validated.

=cut

sub create_from_literals {
    my($self, $values) = @_;
    $values = _dup($values);
    while (my($k, $v) = each(%$values)) {
	$values->{$k} = $self->get_field_type($k)->from_literal_or_die($v);
    }
    return $self->create($values);
}

=for html <a name="create_or_unauth_update"></a>

=head2 create_or_unauth_update(hash_ref new_values) : self

B<DEPRECATED>

=cut

sub create_or_unauth_update {
    Bivio::IO::Alert->warn_deprecated('Use unauth_create_or_update instead.');
    return shift->unauth_create_or_update(@_);
}

=for html <a name="create_or_update"></a>

=head2 create_or_update(hash_ref new_values) : self

Tries to load the model based on its primary key values.
If the load is successful, the model will be updated with
the new values. Otherwise, a new model is created.

Adds auth_id to I<new_values>. 

See also L<unauth_create_or_update|"unauth_create_or_update">.

=cut

sub create_or_update {
    my($self, $new_values) = @_;
    return $self->unauth_create_or_update(_add_auth_id($self, $new_values));
}

=for html <a name="delete"></a>

=head2 delete()

=head2 static delete(hash_ref load_args) : boolean

Deletes the current model from the database.   Dies on error.

If I<load_args> is supplied, deletes the model specified by
I<load_args> and not the current model.  May be called statically.

=head2 static delete(hash load_args) : boolean

B<DEPRECATED>

=cut

sub delete {
    my($self) = @_;
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

=for html <a name="delete_all"></a>

=head2 delete_all(hash_ref query) : int

Deletes all the models of this type with the specified (possibly
partial key) query. Returns the number of models deleted.

=cut

sub delete_all {
    my($self, $query) = @_;
    $self = $self->new
	unless ref($self);
    my($rows) =  $self->internal_get_sql_support->delete_all(
	$self->internal_prepare_query(_add_auth_id($self, $query)),
	$self,
    );
    _trace($rows, ' ', ref($self)) if $_TRACE;
    return $rows;
}

=for html <a name="execute_auth_user"></a>

=head2 static execute_auth_user(Bivio::Agent::Request req) : boolean

Loads this auth user's data as if realm_id.

=cut

sub execute_auth_user {
    my($proto, $req) = @_;
    $proto->new($req)->load_for_auth_user;
    return 0;
}

=for html <a name="execute_load"></a>

=head2 static execute_load(Bivio::Agent::Request req) : boolean

Loads this model using no params except auth_id.

=cut

sub execute_load {
    my($proto, $req) = @_;
    $proto->new($req)->load();
    return 0;
}

=for html <a name="execute_load_this"></a>

=head2 static execute_load_this(Bivio::Agent::Request req) : boolean

Loads a new instance of this class using the request using
the "this" on the request.
See L<load_this_from_request|"load_this_from_request">

=cut

sub execute_load_this {
    my($proto, $req) = @_;
    $proto->new($req)->load_this_from_request();
    return 0;
}

=for html <a name="execute_load_parent"></a>

=head2 static execute_load_parent(Bivio::Agent::Request req) : boolean

Loads a new instance of this class using the request using
the "parent" on the request query.
See L<load_parent_from_request|"load_parent_from_request">

=cut

sub execute_load_parent {
    my($proto, $req) = @_;
    $proto->new($req)->load_parent_from_request();
    return 0;
}

=for html <a name="execute_unauth_delete_this"></a>

=head2 static execute_unauth_delete_this(Bivio::Agent::Request req) : boolean

Deletes the "this" model by calling get_model for this model.
Deletes "this" from list query and query.

=cut

sub execute_unauth_delete_this {
    my($proto, $req) = @_;
    my($lm) = $req->get('list_model');
    $lm->set_cursor_or_not_found(0);
    $lm->get_model($proto->simple_package_name)->unauth_delete;
    $lm->get_query->delete('this');
    delete($req->get('query')->{Bivio::SQL::ListQuery->to_char('this')});
    return;
}

=for html <a name="execute_unauth_load_this"></a>

=head2 static execute_unauth_load_this(Bivio::Agent::Request req) : boolean

Loads a new instance of this class using the request using
the "this" on the request.
See L<unauth_load_this_from_request|"unauth_load_this_from_request">

=cut

sub execute_unauth_load_this {
    my($proto, $req) = @_;
    my($self) = $proto->new($req);
    $self->throw_die('MODEL_NOT_FOUND')
	unless $self->unauth_load_this_from_request;
    return 0;
}

=for html <a name="format_query_for_parent"></a>

=head2 format_query_for_parent() : string

Query string used to identify this instance using "parent" key,
so can be used with I<load_parent_from_request>.

=cut

sub format_query_for_parent {
    my($self) = @_;
    return Bivio::SQL::ListQuery->format_uri_for_this_as_parent(
	    $self->internal_get_sql_support, $self->internal_get);
}

=for html <a name="format_query_for_this"></a>

=head2 format_query_for_this() : string

=head2 static format_query_for_this(hash_ref load_query) : string

Query string used to identify this instance.  If supplied I<load_query>,
must contain primary keys for the model.

=cut

sub format_query_for_this {
    my($self, $query) = @_;
    return Bivio::SQL::ListQuery->format_uri_for_this(
	    $self->internal_get_sql_support, $query || $self->internal_get);
}

=for html <a name="get_keys"></a>

=head2 get_keys() : array_ref

B<DEPRECATED>

Returns a copy of the I<column_names> attribute.

TODO: Need to move this up to Model, but I think this might break ListModel and
FormModel, because get_keys returns all keys and column_names only returns
declared columns.  Some models don't declare all their columns.

=cut

sub get_keys {
    return [@{shift->get_info('column_names')}];
}

=for html <a name="get_qualified_field_name"></a>

=head2 get_qualified_field_name(string field) : string

Returns qualified field name (Model.field) for field.

=cut

sub get_qualified_field_name {
    return shift->simple_package_name . '.' . shift(@_);
}

=for html <a name="internal_get_target"></a>

=head2 internal_get_target() : (proto, Bivio::Biz::Model, string)

=head2 static internal_get_target(Bivio::Biz::Model model, string model_prefix, hash_ref values) : (proto, Bivio::Biz::Model, string, values)

Returns the class, target model and optional model prefix. This method is used
by subclasses when defining a method which can operate on self, on another
model target, or $values. For an example, see RealmOwner.format_email.
If values is undef, internal_get is called on the model.

=cut

sub internal_get_target {
    my($self, $model, $model_prefix, $values) = @_;
    $model ||= $self;
    return (
	ref($self) || $self,
	$model,
	$model_prefix || '',
	$values || $model->internal_get,
    );
}

=for html <a name="internal_initialize_sql_support"></a>

=head2 static internal_initialize_sql_support(Bivio::SQL::Statement stmt) : Bivio::SQL::Support

=head2 static internal_initialize_sql_support(Bivio::SQL::Statement stmt, hash_ref config) : Bivio::SQL::Support

Returns the L<Bivio::SQL::PropertySupport|Bivio::SQL::PropertySupport>
for this class.  Calls L<internal_initialize|"internal_initialize">
to get the hash_ref to initialize the sql support instance.

=cut

sub internal_initialize_sql_support {
    my($proto, $stmt, $config) = @_;
    die('cannot create anonymous PropertyModels') if $config;
    $config = $proto->internal_initialize;
    $config->{class} = ref($proto) || $proto;
    return  Bivio::SQL::PropertySupport->new($config);
}

=for html <a name="internal_load_properties"></a>

=head2 internal_load_properties(hash_ref values) : self

Loads model with values as properties.  DOES NOT MAKE A COPY of values.

=cut

sub internal_load_properties {
    my($self, $values) = @_;
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

=for html <a name="internal_prepare_query"></a>

=head2 internal_prepare_query(hash_ref query) : hash_ref

Returns I<query> after fixing it up.

=cut

sub internal_prepare_query {
    shift;
    return shift;
}

=for html <a name="internal_unload"></a>

=head2 internal_unload() : self

Clears the model state, if loaded.  Deletes from request.

=cut

sub internal_unload {
    my($self) = @_;
    return $self
	unless $self->is_loaded;
    _unload($self, 1);
    return $self;
}

=for html <a name="is_loaded"></a>

=head2 is_loaded() : boolean

Returns true if the model is loaded (or created), i.e. contains
valid values.

=cut

sub is_loaded {
    # If we have values, we're loaded.
    return %{shift->internal_get} ? 1 : 0;
}

=for html <a name="iterate_next_and_load"></a>

=head2 iterate_next_and_load() : boolean

Will iterate to the next row and load the model with the row.
Can be used to update a row.

Returns false if there is no next.

B<Deprecated form accepts an iterator as the first argument.>

=cut

sub iterate_next_and_load {
    my($self) = shift;
    my(undef, $row) = $self->internal_iterate_next(@_, {});
    return $row ? _load($self, $row) : _unload($self, 1);
}

=for html <a name="iterate_next_and_load_new"></a>

=head2 iterate_next_and_load_new() : Bivio::Biz::PropertyModel

Same as L<iterate_next_and_load|"iterate_next_and_load">, but
returns a new model instance for each row if iteration proceeds.
Returns C<undef> if end of iteration.

B<Deprecated form accepts an iterator as the first argument.>

=cut

sub iterate_next_and_load_new {
    my($self, $row) = shift->internal_iterate_next(@_, {});
    return $row ? $self->new->internal_load_properties($row) : undef;
}

=for html <a name="iterate_start></a>

=head2 iterate_start(string order_by)

=head2 iterate_start(string order_by, hash_ref query)

Begins an iteration which can be used to iterate the rows for this
realm with L<iterate_next|"iterate_next">,
L<iterate_next_and_load|"iterate_next_and_load">, or
L<iterate_next_and_load_new|"iterate_next_and_load_new">.
L<iterate_end|"iterate_end"> should be called when you are through
with the iteration.

I<order_by> is an SQL C<ORDER BY> clause without the keywords C<ORDER BY>.

I<query> is the same as in L<load|"load">.

B<Deprecated form returns the iterator.>

=cut

sub iterate_start {
    my($self, $order_by, $query) = @_;
    $self->throw_die('DIE', 'no auth_id')
	unless $self->get_request->get('auth_id');
    return $self->unauth_iterate_start(
	$order_by, _add_auth_id($self, $query || {}));
}

=for html <a name="load"></a>

=head2 load(hash_ref query) : self

Loads the model or dies if not found or other error.
Subclasses shouldn't override this method.

Note: I<query> may be modified by this method.

Returns I<self>.

=head2 load(hash query) : self

B<DEPRECATED>

=cut

sub load {
    my($self) = shift;
    return $self if $self->unsafe_load(@_);
    _die_not_found($self, \@_, caller);
    # DOES NOT RETURN
}

=for html <a name="load_for_auth_user"></a>

=head2 load_for_auth_user() : self

Loads the model for auth_user.

=cut

sub load_for_auth_user {
    my($self) = @_;
    return $self->unauth_load({
	realm_id => (
	    $self->get_request->get('auth_user') || $self->die('no auth_user')
	)->get('realm_id'),
    });
}

=for html <a name="load_parent_from_request"></a>

=head2 load_parent_from_request() : self

Parses the query from the request (or list_model) and then L<load|"load">.
Uses "parent" key in query or list model.

See also L<unsafe_load_parent_from_request|"unsafe_load_parent_from_request">.

=cut

sub load_parent_from_request {
    my($self) = @_;
    my($q) = _parse_query($self, 1);
    $self->throw_die(Bivio::DieCode::CORRUPT_QUERY(),
	    {message => 'see previous warning, too'}, caller)
	    unless $q;
    return $self->load($q);
}

=for html <a name="load_this_from_request"></a>

=head2 load_this_from_request() : self

Parses the query from the request (or list_model) and then L<load|"load">.
Uses "this" key in query or list model.

See also L<unsafe_load_this_from_request|"unsafe_load_this_from_request">.

=cut

sub load_this_from_request {
    my($self) = @_;
    my($q) = _parse_query($self, 0);
    $self->throw_die(Bivio::DieCode::CORRUPT_QUERY(),
	    {message => 'see previous warning, too'}, caller)
	    unless $q;
    return $self->load($q);
}

=for html <a name="merge_initialize_info"></a>

=head2 static merge_initialize_info(hash_ref parent, hash_ref child) : hash_ref

Merges two model field definitions (I<child> into I<parent>) into a new
hash_ref.

=cut

sub merge_initialize_info {
    my($proto, $parent, $child) = @_;
    Bivio::Die->die('columns => takes a hash_ref')
        unless ref($parent->{columns} || {}) eq 'HASH'
	    && ref($child->{columns} || {}) eq 'HASH';
    return {
	%$parent,
        %$child,
	columns => {
	    %{$parent->{columns} || {}},
	    %{$child->{columns} || {}},
	},
    };
}

=for html <a name="register_child_model"></a>

=head2 register_child_model(string child, hash_ref key_map)

Adds the specified (child, key_map) pair to the child list. Called by
PropertySupport.

=cut

sub register_child_model {
    my($self, $child, $key_map) = @_;
    $self->internal_get_sql_support->register_child_model($child, $key_map);
    return;
}

=for html <a name="unauth_create_or_update"></a>

=head2 unauth_create_or_update(hash_ref new_values) : self

Tries to load the model based on its primary key values.
If the load is successful, the model will be updated with
the new values. Otherwise, a new model is created.

Calls L<unauth_load|"unauth_load">.

See also L<create_or_update|"create_or_update">.

=cut

sub unauth_create_or_update {
    my($self, $new_values) = @_;
    my($pk_values) = _get_primary_keys($self, $new_values);
    return $pk_values && $self->unauth_load($pk_values)
	    ? $self->update($new_values) : $self->create($new_values);
}

=for html <a name="unauth_create_or_update_keys"></a>

=head2 unauth_create_or_update_keys(hash_ref values, string modified_key)

Create or update keys.  I<modified_key> is the key that could be
changed/updated.

=cut

sub unauth_create_or_update_keys {
    my($self, $values, $modified_key) = @_;

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

=for html <a name="unauth_delete"></a>

=head2 unauth_delete()

=head2 static unauth_delete(hash_ref load_args) : boolean

Deletes the current model from the database.   Doesn't check
auth_id.  Dies on error.

If I<load_args> is supplied, deletes the model specified by
I<load_args> and not the current model.  May be called statically.
Just like L<unauth_load|"unauth_load">.

Note: I<query> may be modified by this method.

=cut

sub unauth_delete {
    my($self, $load_args) = @_;
    $load_args ||= $self->internal_get;
    $self = $self->new()
	unless ref($self);
    $self->die('load_args or model must not be empty')
	unless %$load_args;
    return $self->internal_get_sql_support->delete(
	$self->internal_prepare_query({%$load_args}), $self);
}

=for html <a name="unauth_iterate_start"></a>

=head2 unauth_iterate_start(string order_by) : ref

=head2 unauth_iterate_start(string order_by, hash_ref query) : ref

B<Do not use this method unless you are sure the user is authorized
to access all realms or all rows of the table.>

Begins an iteration which can be used to iterate the rows for this
realm with L<iterate_next|"iterate_next">,
L<iterate_next_and_load|"iterate_next_and_load">, or
L<iterate_next_and_load_new|"iterate_next_and_load_new">.
L<iterate_end|"iterate_end"> should be called when you are through
with the iteration.

I<order_by> is an SQL C<ORDER BY> clause without the keywords
C<ORDER BY>.

I<query> is the same as in L<load|"load">.

B<Deprecated form returns the iterator.>

=cut

sub unauth_iterate_start {
    my($self, $order_by, $query) = @_;
    return $self->internal_put_iterator(
	$self->internal_get_sql_support->iterate_start(
	    $self,
	    $order_by || _default_order_by($self),
	    $self->internal_prepare_query(_dup($query)),
	),
    );
}

=for html <a name="unauth_load"></a>

=head2 unauth_load(hash_ref query) : boolean

Loads the model as with L<unsafe_load|"unsafe_load">.  However, does
not insert security realm into query params.  Use this when you
B<are certain> there are no security issues involved with loading
the data.

On success, saves model in request and returns true.

Returns false if not found.  Dies on any other errors.

Subclasses should override this method if there model doesn't match
the usual property model.  L<unsafe_load|"unsafe_load"> and
L<load|"load"> call this method.

Note: I<query> may be modified by this method.

=head2 unauth_load(hash query) : boolean

B<DEPRECATED>

=cut

sub unauth_load {
    my($self, $query) = _load_args(@_);
    # Don't bother checking query.  Will kick back if empty.
    my($values) = $self->internal_get_sql_support->unsafe_load(
	$self->internal_prepare_query(_dup($query)), $self);
    return $values ? _load($self, $values) : _unload($self, 1);
}

=for html <a name="unauth_load_or_die"></a>

=head2 unauth_load_or_die(hash_ref query) : Bivio::Biz::Model

See L<unauth_load|"unauth_load"> for params.  Throws a C<MODEL_NOT_FOUND>
exception if the load fails.

Returns I<self>.

=head2 unauth_load_or_die(hash query) : Bivio::Biz::Model

B<DEPRECATED>

=cut

sub unauth_load_or_die {
    my($self) = shift;
    return $self if $self->unauth_load(@_);
    _die_not_found($self, \@_, caller);
    # DOES NOT RETURN
}

=for html <a name="unauth_load_this_from_request"></a>

=head2 unauth_load_this_from_request() : boolean

Parses the query from the request (or list_model) and then
L<unauth_load|"unauth_load">.  If there is no query or the query is
corrupt, returns false.

See also L<load_this_from_request|"load_this_from_request">.

=cut

sub unauth_load_this_from_request {
    my($self) = @_;
    my($q) = _parse_query($self, 0);
    return $q ? $self->unauth_load($q) : 0;
}

=for html <a name="unauth_load_parent_from_request"></a>

=head2 unauth_load_parent_from_request() : boolean

Parses the query from the request (or list_model) and then
L<unauth_load|"unauth_load">.  If there is no query or the query is
corrupt, returns false.

See also L<load_parent_from_request|"load_parent_from_request">.

=cut

sub unauth_load_parent_from_request {
    my($self) = @_;
    my($q) = _parse_query($self, 1);
    return $q ? $self->unauth_load($q) : 0;
}

=for html <a name="unsafe_load"></a>

=head2 unsafe_load(hash_ref query) : boolean

Loads the model.  On success, saves model in request and returns true.

Returns false if not found.  Dies on all other errors.

Subclasses shouldn't override this method.

B<This method will be dynamically overridden.  See
L<internal_initialize_sql_support|"internal_initialize_sql_support">>.

Note: I<query> may be modified by this method.

=head2 unsafe_load(hash query) : boolean

B<DEPRECATED>

=cut

sub unsafe_load {
    my($self, $query) = _load_args(@_);
    return $self->unauth_load(_add_auth_id($self, $query));
}

=for html <a name="unsafe_load_this_from_request"></a>

=head2 unsafe_load_this_from_request() : boolean

Parses the query from the request (or list_model) and then
L<unsafe_load|"unsafe_load">.  If there is no query or the query is corrupt,
returns false.

See also L<load_this_from_request|"load_this_from_request">.

=cut

sub unsafe_load_this_from_request {
    my($self) = @_;
    my($q) = _parse_query($self, 0);
    return $q ? $self->unsafe_load($q) : 0;
}

=for html <a name="unsafe_load_parent_from_request"></a>

=head2 unsafe_load_parent_from_request() : boolean

Loads this model from the parent value in the query on the request.

=cut

sub unsafe_load_parent_from_request {
    my($self) = @_;
    my($q) = _parse_query($self, 1);
    return $q ? $self->unsafe_load($q) : 0;
}

=for html <a name="update"></a>

=head2 update(hash_ref new_values) : Bivio::Biz::PropertyModel

Updates the current model's values.
NOTE: load() should be called prior to an update.

Returns I<self>.

=cut

sub update {
    my($self, $new_values) = @_;
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

#=PRIVATE METHODS

# _add_auth_id(self, hash_ref query) : hash_ref
#
# Adds the auth_id field and value to the query, if defined. Returns
# the query.
#
# Ensure we are only accessing data from the realm we are authorized
# to operate in.
#
sub _add_auth_id {
    my($self, $query) = @_;
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

# _die_not_found(self, array_ref args, string pkg, string file, string line)
#
# Dies with appropriate exception.
#
sub _die_not_found {
    my($self, $args, $pkg, $file, $line) = @_;
    ($self, $args) = _load_args($self, @$args);
    $self->throw_die(Bivio::DieCode->MODEL_NOT_FOUND, $args, $pkg,
        $file, $line);
    # DOES NOT RETURN
}

#
sub _default_order_by {
    return join(
	',',
	map($_->{sql_name} . ' ' . ($_->{sort_order} ? 'ASC' : 'DESC'),
	    @{shift->get_info('primary_key')}));
}

# _dup(hash_ref v) : hash_ref
sub _dup {
    my($v) = @_;
    return $v ? {%$v} : {};
}

# _get_primary_keys(self, hash_ref new_values) : hash_ref
#
# If new_values contains all primary keys, returns a copy as a hash_ref.
# Else returns undef.
#
sub _get_primary_keys {
    my($self, $new_values) = @_;
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

# _load_pro(Bivio::Biz::PropertyModel self, hash_ref values) : boolean
#
# Initializes the self with values and returns 1.
#
sub _load {
    shift->internal_load_properties(@_);
    return 1;
}

# _load_args(self, hash_ref query) : array
# _load_args(self, hash query) : array
#
# Parses load args and returns ($self, $query).
#
sub _load_args {
    my($self) = shift;
    return ($self, (int(@_) == 1 ? @_ : {@_}));
}

# _parse_query(self, boolean want_parent) : hash_ref
#
# Does work of unsafe_load_this/parent_from_request.
#
sub _parse_query {
    my($self, $want_parent) = @_;
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

# _query_err(self, string msg) : undef
#
# Outputs a warning and returns undef.
#
sub _query_err {
    my($self, $msg) = @_;
    $self->get_request->warn($self, ' query error: ', $msg);
    return undef;
}

# _unload(self, boolean delete_from_request) : boolean
#
# Always returns false.
#
sub _unload {
    my($self, $delete_from_request) = @_;
    $self->internal_clear_model_cache;
    $self->internal_put({});
    $self->delete_from_request if $delete_from_request;
    return 0;
}

=head1 COPYRIGHT

Copyright (c) 1999-2006 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
