# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::PropertyModel;
use strict;
$Bivio::Biz::PropertyModel::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::PropertyModel - An abstract model with a set of named elements

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

=head2 static new(Bivio::Agent::Request req) : Bivio::Biz::ListModel

Create a new PropertyModel associated with the request.

=cut

sub new {
    return &Bivio::Biz::Model::new(@_);
}

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(hash_ref new_values)

Creates a new model in the database with the specified values. After creation,
this instance takes ownership of I<new_values>.  Dies on error.

=cut

sub create {
    my($self, $new_values) = @_;
    my($sql_support) = $self->internal_get_sql_support;
    # Make sure all columns are defined
    my($n);
    foreach $n (@{$sql_support->get('column_names')}) {
	$new_values->{$n} = undef unless exists($new_values->{$n});
    }
    $sql_support->create($new_values, $self);
    $self->internal_clear_model_cache;
    $self->internal_put($new_values);
    my($req) = $self->unsafe_get_request;
    $req->put(ref($self), $self) if $req;
    return;
}

=for html <a name="delete"></a>

=head2 delete()

=head2 static delete(hash load_args) : boolean

Deletes the current model from the database.   Dies on error.

If I<load_args> is supplied, deletes the model specified by
I<load_args> and not the current model.  May be called statically.

=cut

sub delete {
    my($self) = shift;
    if (@_) {
	my($self) = $self->new();
	my($sql_support) = $self->internal_get_sql_support;
	# Is always an "auth_load" unless no auth_id
	my($load_args) = {@_};
	my($f) = $sql_support->get('auth_id');
	$load_args->{$f->{name}} = $self->get_request->get('auth_id') if $f;
	return $sql_support->delete($load_args, $self);
    }
    return $self->internal_get_sql_support->delete($self->internal_get, $self);
}

=for html <a name="execute"></a>

=head2 static execute(Bivio::Agent::Request req) : boolean

Loads a new instance of this module using the request.

=cut

sub execute {
    my($proto, $req) = @_;
    $proto->new($req)->load_from_request();
    return 0;
}

=for html <a name="execute_auth_user"></a>

=head2 static execute_auth_user(Bivio::Agent::Request req) : boolean

Loads this auth user's data as if realm_id.

=cut

sub execute_auth_user {
    my($proto, $req) = @_;
    my($user) = $req->get('auth_user');
    Bivio::Die->die('no auth_user') unless $user;
    my($self) = $proto->new($req);
    $self->unauth_load(realm_id => $user->get('realm_id'));
    return 0;
}

=for html <a name="execute_auth_realm"></a>

=head2 static execute_load(Bivio::Agent::Request req) : boolean

Loads this model using no params except auth_id.

=cut

sub execute_load {
    my($proto, $req) = @_;
    $proto->new($req)->load();
    return 0;
}

=for html <a name="format_query"></a>

=head2 format_query() : string

Query string used to identify this instance.

=cut

sub format_query {
    my($self) = @_;
    return Bivio::SQL::ListQuery->format_uri_for_this(
	    $self->internal_get_sql_support, $self->internal_get);
}

=for html <a name="internal_initialize_sql_support"></a>

=head2 static internal_initialize_sql_support() : Bivio::SQL::Support

=head2 static internal_initialize_sql_support(hash_ref config) : Bivio::SQL::Support

Returns the L<Bivio::SQL::PropertySupport|Bivio::SQL::PropertySupport>
for this class.  Calls L<internal_initialize|"internal_initialize">
to get the hash_ref to initialize the sql support instance.

=cut

sub internal_initialize_sql_support {
    my($proto, $config) = @_;
    die('cannot create anonymous PropertyModels') if $config;
    my($sql_support) =  Bivio::SQL::PropertySupport->new(
	    $proto->internal_initialize);
    return $sql_support;
}

=for html <a name="iterate_start></a>

=head2 iterate_start(string order_by) : ref

=head2 iterate_start(string order_by, hash_ref query) : ref

Returns a handle which can be used to iterate the rows for this
realm with L<iterate_next|"iterate_next">.  L<iterate_end|"iterate_end">
should be called, too.

I<order_by> is an SQL C<ORDER BY> clause without the keywords C<ORDER BY>.

I<query> is the same as in L<load|"load">.

=cut

sub iterate_start {
    my($self, $order_by, $query) = @_;
    my($auth_id) = $self->get_request->get('auth_id');
    $self->throw_die('DIE', 'no auth_id') unless $auth_id;
    my($support) = $self->internal_get_sql_support;
    $query ||= {};
    $query->{$support->get('auth_id')->{name}} = $auth_id;
    return $support->iterate_start($self, $order_by, $query);
}

=for html <a name="iterate_next_and_load"></a>

=head2 iterate_next_and_load(ref iterator) : boolean

I<iterator> was returned by L<iterate_start|"iterate_start">.
Will iterate to the next row and load the model with the row.
Can be used to update a row.

Returns false if there is no next.

=cut

sub iterate_next_and_load {
    my($self, $it) = @_;
    my($values) = {};
    unless ($self->internal_get_sql_support->iterate_next(
	    $it, $values)) {
	$self->internal_clear_model_cache;
	$self->internal_put({});
	return 0;
    }

    return _load($self, $values);
}

=for html <a name="load"></a>

=head2 load(hash query)

Loads the model or dies if not found or other error.
Subclasses shouldn't override this method.

=cut

sub load {
    my($self) = shift;
    $self->unsafe_load(@_) && return;
    $self->throw_die(Bivio::DieCode::NOT_FOUND(), {@_}, caller);
}

=for html <a name="load_from_request"></a>

=head2 load_from_request()

Loads the model from the query string generated by
L<format_query|"format_query"> or by
L<Bivio::SQL::ListQuery|Bivio::SQL::ListQuery>.

Uses I<this> or I<parent_id> from the query.

=cut

sub load_from_request {
    my($self) = @_;
    my($req) = $self->get_request;
    my($support) = $self->internal_get_sql_support;
    my($list_model, $q) = $req->unsafe_get('list_model', 'query');
    # Pass a copy of the query, because it is trashed by ListQuery.
    my($query) = $list_model ? $list_model->get_query()
	    : $q ? Bivio::SQL::ListQuery->new({
		%$q,
		auth_id => $req->get('auth_id'),
		count => 1}, $support, $self)
		    : $self->throw_die(Bivio::DieCode::CORRUPT_QUERY(),
			    'missing query');

    # Use this if available, else parent_id
    my($this, $parent_id) = $query->get('this', 'parent_id');
    my($pk_cols) = $support->get('primary_key');
    unless ($this) {
	# parent_id has some restrictions, check them
	$self->throw_die(Bivio::DieCode::CORRUPT_QUERY(), 'missing this')
	       unless $parent_id;
#TODO: Need to make this work more cleanly
	my($i) = int(@$pk_cols);
	die('expecting one or two primary key columns for parent_id')
		if $i > 2;
	if ($i == 1) {
	    $this = [$parent_id];
	}
	else {
#TODO: Make this cleaner
	    # This is a hack.  We need to add in the auth_id to the
	    # query so that the code creating @query works.  However,
	    # load overrides auth_id always.
	    my($auth_col) = $support->get('auth_id');
	    my($auth_id) = $req->get('auth_id');
	    if ($auth_col->{name} eq $pk_cols->[0]->{name}) {
		$this = [$auth_id, $parent_id];
	    }
	    elsif ($auth_col->{name} eq $pk_cols->[1]->{name}) {
		$this = [$parent_id, $auth_id];
	    }
	    else {
		# Should never happen, of course
		die('(auth_id, parent_id) not primary key');
	    }
	}
    }

    # Create the query acceptable to load (which always adds auth_id)
    my(@query) = ();
    my($i) = 0;
    foreach my $col (@$pk_cols) {
	$self->throw_die(Bivio::DieCode::CORRUPT_QUERY(),
		{column => $col->{name}, , error => 'NULL'})
		unless defined($this->[$i]);
	push(@query, $col->{name}, $this->[$i++]);
    }

    # Success with parsing, let's see if it is there
    return $self->load(@query);
}

=for html <a name="unauth_iterate_start"></a>

=head2 unauth_iterate_start(string order_by) : ref

=head2 unauth_iterate_start(string order_by, hash_ref query) : ref

B<Do not use this method unless you are sure the user is authorized
to access all realms or all rows of the table.>

Returns a handle which can be used to iterate ALL rows in
the table (not just this realm) with
L<iterate_next|"iterate_next">.  L<iterate_end|"iterate_end">
should be called, too.

I<order_by> is an SQL C<ORDER BY> clause without the keywords
C<ORDER BY>.

I<query> is the same as in L<load|"load">.


=cut

sub unauth_iterate_start {
    my($self) = shift;
    return $self->internal_get_sql_support->iterate_start($self, @_);
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
    # Don't bother checking query.  Will kick back if empty.
    my($values) = $self->internal_get_sql_support->unsafe_load(\%query, $self);
    return 0 unless $values;
    return _load($self, $values);
}

=for html <a name="unauth_load_or_die"></a>

=head2 unauth_load_or_die(hash query)

See L<unauth_load|"unauth_load"> for params.  Throws a C<NOT_FOUND>
exception if the load fails.

=cut

sub unauth_load_or_die {
    my($self) = shift;
    return if $self->unauth_load(@_);
    $self->throw_die(Bivio::DieCode::NOT_FOUND(), {@_}, caller);
}

=for html <a name="unsafe_load"></a>

=head2 unsafe_load(hash query) : boolean

Loads the model.  On success, saves model in request and returns true.

Returns false if not found.  Dies on all other errors.

Subclasses shouldn't override this method.

B<This method will be dynamically overridden.  See
L<internal_initialize_sql_support|"internal_initialize_sql_support">>.

=cut

sub unsafe_load {
    my($self) = shift;
    # Ensure we are only getting data from the realm we are authorized
    # to operate in.
    my($sql_support) = $self->internal_get_sql_support;
    my($k) = $sql_support->get('auth_id');

    # Will override existing value for auth_id if model has an auth_id
    push(@_, $k->{name}, $self->get_request->get('auth_id')) if $k;

    return $self->unauth_load(@_);
}

=for html <a name="update"></a>

=head2 update(hash_ref new_values)

Updates the current model's values.
NOTE: find should be called prior to an update.

=cut

sub update {
    my($self, $new_values) = @_;
    my($properties) = $self->internal_get;
    $self->internal_get_sql_support->update($properties, $new_values, $self);
    my($n);
    foreach $n (keys(%$new_values)) {
	$properties->{$n} =  $new_values->{$n};
    }
    return;
}

#=PRIVATE METHODS

# _load(Bivio::Biz::PropertyModel self, hash_ref values) : boolean
#
# Initializes the self with values and returns 1.
#
sub _load {
    my($self, $values) = @_;
    $self->internal_clear_model_cache;
    $self->internal_put($values);
    # If found, put a reference to this model in request
    my($req) = $self->unsafe_get_request;
    $req->put(ref($self), $self) if $req;
    return 1;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
