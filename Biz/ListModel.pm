# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::ListModel;
use strict;
$Bivio::Biz::ListModel::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::ListModel - an abstract model of an SQL query and result

=head1 SYNOPSIS

=cut

=head1 EXTENDS

L<Bivio::Biz::Model>

=cut

use Bivio::Biz::Model;
@Bivio::Biz::ListModel::ISA = ('Bivio::Biz::Model');

=head1 DESCRIPTION

C<Bivio::Biz::ListModel> is used to describe queries which return multiple
rows.  This class is typically subclassed.  However, you can create
anonymous ListModels by calling
L<new_anonymous|Bivio::Biz::PropertyModel/"new_anonymous">.

=cut


=head1 CONSTANTS

=cut

=for html <a name="LAST_ROW"></a>

=head2 LAST_ROW() : int

Returns a constant which means the "last_row".

=cut

sub LAST_ROW {
    # Something that isn't likely to be hit by subtracting around zero.
    return -999999;
}

=for html <a name="LOAD_ALL_SIZE"></a>

=head2 LOAD_ALL_SIZE : int

The number of rows loaded by L<load_all|"load_all">.

May be overridden.

=cut

sub LOAD_ALL_SIZE {
    return 200;
}

=for html <a name="NOT_FOUND_IF_EMPTY"></a>

=head2 NOT_FOUND_IF_EMPTY : boolean

Returning true causes load to blow up if no rows are returned.
Default is false.

=cut

sub NOT_FOUND_IF_EMPTY {
    return 0;
}

=for html <a name="PAGE_SIZE"></a>

=head2 PAGE_SIZE : int

Default page size for display.

May be overridden, but probably want L<load_all|"load_all">.

=cut

sub PAGE_SIZE {
#TODO: Move this into a preference
    return 15;
}

#=IMPORTS
use Bivio::SQL::ListSupport;
use Bivio::SQL::ListQuery;
use Bivio::Biz::QueryType;
use Bivio::Util;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::Request req) : Bivio::Biz::ListModel

Create a new ListModel associated with the request.

=cut

sub new {
    my($self) = &Bivio::Biz::Model::new(@_);
    # NOTE: fields are dynamically replaced.  See, e.g. load.
    $self->{$_PACKAGE} = {
	empty_properties => $self->internal_get,
    };
    return $self;
}

=for html <a name="new_anonymous"></a>

=head2 static new_anonymous(hash_ref config) : Bivio::Biz::ListModel

=head2 static new_anonymous(hash_ref config, Bivio::Agent::Request req) : Bivio::Biz::ListModel

Create a new_anonymous ListModel associated with the request.

=cut

sub new_anonymous {
    my($self) = &Bivio::Biz::Model::new_anonymous(@_);
    # NOTE: fields are dynamically replaced.  See, e.g. load.
    $self->{$_PACKAGE} = {
	empty_properties => $self->internal_get,
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 static execute(Bivio::Agent::Request req) : boolean

Loads a new instance of this model using the request.

=cut

sub execute {
    my($proto, $req) = @_;
    $proto->new($req)->load_from_request();
    return 0;
}

=for html <a name="execute_load_all"></a>

=head2 execute_load_all(Bivio::Agent::Request req)

Loads "all" records of this model.

=cut

sub execute_load_all {
    my($proto, $req) = @_;
    $proto->new($req)->load_all();
    return 0;
}

=for html <a name="execute_load_page"></a>

=head2 execute_load_page(Bivio::Agent::Request req)

Loads exactly a page.

=cut

sub execute_load_page {
    my($proto, $req) = @_;
    my($self) = $proto->new($req);
    $self->load({count => $self->PAGE_SIZE});
    return 0;
}

=for html <a name="format_query"></a>

=head2 format_query(Bivio::Biz::QueryType type) : string

=head2 format_query(string type) : string

Just the query part of L<format_uri|"format_uri">.  May return undef
if this QueryType doesn't have a query (e.g. I<THIS_PATH_NO_QUERY>).

=cut

sub format_query {
    my($self, $type) = @_;
    my($fields) = $self->{$_PACKAGE};

    # Convert to enum unless already converted
    $type = Bivio::Biz::QueryType->from_name($type) unless ref($type);

    # Get the query using the method defined in QueryType
    my($method) = $type->get_short_desc;
    return undef unless $method;

    # Determine if need to pass in current row
    my($arg);

    if ($type->get_name =~ /DETAIL|THIS_CHILD_LIST|THIS_PATH/) {
	my($c) = $fields->{cursor};
	Carp::croak('no cursor') unless defined($c) && $c >= 0;
	$arg = $self->internal_get();
    }
    else {
	Carp::croak('not loaded') unless $fields->{rows};
    }

#TODO: may not be the right place to escape the uri
    return Bivio::Util::escape_uri($fields->{query}->$method(
	    $self->internal_get_sql_support(), $arg));
}

=for html <a name="format_uri"></a>

=head2 format_uri(Bivio::Biz::QueryType type) : string

=head2 format_uri(string type) : string

=head2 format_uri(Bivio::Biz::QueryType, string uri) : string

=head2 format_uri(string type, string uri) : string

Returns the formatted uri for I<type> based on the existing query
bound to this model.  If I<uri> is not supplied, uses I<detail_uri>
or I<list_uri> depending on the type.

If the type is I<THIS_PATH>, the list must have a I<path_info> attribute
which doesn't begin with a leading slash.  See
L<Bivio::Biz::Model::FilePathList|Bivio::Biz::Model::FilePathList>
for an example.

=cut

sub format_uri {
    my($self, $type, $uri) = @_;
    my($fields) = $self->{$_PACKAGE};

    # Convert to enum unless already converted
    $type = Bivio::Biz::QueryType->from_name($type) unless ref($type);

    # Need to get the list_uri or detail_uri from the request?
    $uri ||= $self->get_request->get($type->get_long_desc);

    if ($type->get_name =~ /THIS_PATH/) {
	my($pi) = $self->get('path_info');
	$uri .= '/'.$pi if length($pi);
    }
    my($query) = $self->format_query($type);

    return $uri unless $query;

    # Push the query on the front of the form context.
    $uri =~ s/\?/?$query&/ || ($uri .= '?'.$query);
    return $uri;
}

=for html <a name="format_uri_for_next"></a>

=head2 format_uri_for_next() : string

=head2 format_uri_for_next(string uri) : string

B<DEPRECATED>.  Use L<format_uri|"format_uri">.

=cut

sub format_uri_for_next {
    return shift->format_uri(Bivio::Biz::QueryType::NEXT_DETAIL(), @_);
}

=for html <a name="format_uri_for_next_page"></a>

=head2 format_uri_for_next_page() : string

=head2 format_uri_for_next_page(string uri) : string

B<DEPRECATED>.  Use L<format_uri|"format_uri">.

=cut

sub format_uri_for_next_page {
    return shift->format_uri(Bivio::Biz::QueryType::NEXT_LIST(), @_);
}

=for html <a name="format_uri_for_prev"></a>

=head2 format_uri_for_prev() : string

=head2 format_uri_for_prev(string uri) : string

B<DEPRECATED>.  Use L<format_uri|"format_uri">.

=cut

sub format_uri_for_prev {
    return shift->format_uri(Bivio::Biz::QueryType::PREV_DETAIL(), @_);
}

=for html <a name="format_uri_for_prev_page"></a>

=head2 format_uri_for_prev_page() : string

=head2 format_uri_for_prev_page(string uri) : string

B<DEPRECATED>.  Use L<format_uri|"format_uri">.

=cut

sub format_uri_for_prev_page {
    return shift->format_uri(Bivio::Biz::QueryType::PREV_LIST(), @_);
}

=for html <a name="format_uri_for_this"></a>

=head2 format_uri_for_this() : string

=head2 format_uri_for_this(string uri) : string

B<DEPRECATED>.  Use L<format_uri|"format_uri">.

=cut

sub format_uri_for_this {
    return shift->format_uri(Bivio::Biz::QueryType::THIS_DETAIL(), @_);
}

=for html <a name="format_uri_for_this_child"></a>

=head2 format_uri_for_this_child() : string

=head2 format_uri_for_this_child(string uri) : string

B<DEPRECATED>.  Use L<format_uri|"format_uri">.

=cut

sub format_uri_for_this_child {
    return shift->format_uri(Bivio::Biz::QueryType::THIS_CHILD_LIST(), @_);
}

=for html <a name="format_uri_for_this_page"></a>

=head2 format_uri_for_this_page() : string

=head2 format_uri_for_this_page(string uri) : string

B<DEPRECATED>.  Use L<format_uri|"format_uri">.

=cut

sub format_uri_for_this_page {
    return shift->format_uri(Bivio::Biz::QueryType::THIS_LIST(), @_);
}

=for html <a name="get_cursor"></a>

=head2 get_cursor() : int

Returns the position.  Returns -1 before the list is read and
undef after the list is read.

=cut

sub get_cursor {
    return shift->{$_PACKAGE}->{cursor};
}

=for html <a name="get_hidden_field_values"></a>

=head2 get_hidden_field_values() : array_ref

  Q: Can you say hack?
  I knew you could...

Emulate L<Bivio::Biz::FormModel::get_hidden_field_values|Bivio::Biz::FormModel/"get_hidden_field_values">

=cut

sub get_hidden_field_values {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{query}->get_hidden_field_values(
	    $self->internal_get_sql_support());
}

=for html <a name="get_query"></a>

=head2 get_query() : Bivio::SQL::ListQuery

Returns the
L<Bivio::SQL::ListQuery|Bivio::SQL::ListQuery>
associated with this list model.

=cut

sub get_query {
    return shift->{$_PACKAGE}->{query};
}

=for html <a name="get_result_set_size"></a>

=head2 get_result_set_size() : int

Returns the number of rows loaded.

=cut

sub get_result_set_size {
    my($rows) = shift->{$_PACKAGE}->{rows};
    Carp::croak('not loaded') unless $rows;
    return int(@$rows);
}

=for html <a name="get_search_as_html"></a>

=head2 get_search_as_html() : string

Returns the search string as an html field value.

=cut

sub get_search_as_html {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{query}->get_search_as_html();
}

=for html <a name="has_next"></a>

=head2 has_next() : boolean

Is there next page or item to this list model?

=cut

sub has_next {
    return shift->{$_PACKAGE}->{query}->get('has_next');
}

=for html <a name="has_prev"></a>

=head2 has_prev() : boolean

Is there prev page or item to this list model?

=cut

sub has_prev {
    return shift->{$_PACKAGE}->{query}->get('has_prev');
}

=for html <a name="internal_get_rows"></a>

=head2 internal_get_rows() : array_ref

B<FOR INTERNAL USE ONLY.>

Returns the rows associated with the query.  If the model
hasn't been loaded, blows up.

=cut

sub internal_get_rows {
    my($rows) = shift->{$_PACKAGE}->{rows};
    Carp::croak('not loaded') unless $rows;
    return $rows;
}

=for html <a name="internal_initialize_sql_support"></a>

=head2 static internal_initialize_sql_support() : Bivio::SQL::Support

=head2 static internal_initialize_sql_support(hash_ref config) : Bivio::SQL::Support

Returns the L<Bivio::SQL::ListSupport|Bivio::SQL::ListSupport>
for this class.  Calls L<internal_initialize|"internal_initialize">
to get the hash_ref to initialize the sql support instance.

You can create anonymous list model.  Simply supply the configuration
that is returned by C<internal_initialize> to new_anonymous.

=cut

sub internal_initialize_sql_support {
    my($proto, $config) = @_;
    return Bivio::SQL::ListSupport->new(
	    $config || $proto->internal_initialize);
}

=for html <a name="internal_load"></a>

=head2 internal_load(array_ref rows, Bivio::SQL::ListQuery query)

B<FOR INTERNAL USE ONLY.>

Loads the ListModel with I<rows>.

=cut

sub internal_load {
    my($self, $rows, $query) = @_;
    my($empty_properties) = $self->{$_PACKAGE}->{empty_properties};
    # Easier to just replace the hash_ref
    $self->{$_PACKAGE} = {
	rows => $rows,
	cursor => -1,
	query => $query,
	empty_properties => $empty_properties,
    };
    $self->internal_clear_model_cache;
    $self->internal_put($empty_properties);
    $self->die('NOT_FOUND') if $self->NOT_FOUND_IF_EMPTY && !@$rows;
    my($req) = $self->unsafe_get_request;
    $req->put(ref($self) => $self, list_model => $self) if $req;
    return;
}

=for html <a name="internal_pre_load"></a>

=head2 internal_pre_load(Bivio::SQL::ListQuery query, Bivio::SQL::ListSupport support, array_ref params) : string

Returns the where clause and params associated as the result of a
"search" or other "pre_load".

=cut

sub internal_pre_load {
    return '';
}

=for html <a name="internal_load_rows"></a>

=head2 internal_load_rows(Bivio::SQL::ListQuery query, string where, array_ref params, Bivio::SQL::ListSupport sql_support) : array_ref

May be overriden.  Must return the rows loaded.

=cut

sub internal_load_rows {
    my($self, $query, $where, $params, $sql_support) = @_;
    return $sql_support->load($query, $where, $params, $self);
}

=for html <a name="internal_set_cursor"></a>

=head2 internal_set_cursor(int cursor) 

Sets cursor as returned by L<get_cursor|"get_cursor">.

=cut

sub internal_set_cursor {
    my($self, $cursor) = @_;
    $cursor = $self->LAST_ROW unless defined($cursor);
    if ($cursor < 0) {
	$self->reset_cursor;
    }
    else {
	$self->set_cursor($cursor);
    }
    return;
}

=for html <a name="load"></a>

=head2 load()

=head2 load(hash_ref query)

=head2 load(Bivio::SQL::ListQuery query)

Loads the property model from I<query> which must be a form
acceptable to L<Bivio::SQL::ListQuery|Bivio::SQL::ListQuery>
unless I<query> is already a ListQuery.

I<count> will be added to I<query> only if it is a hash_ref.

I<auth_id> will be put in I<query> using the value in the request.

If the load is successful, saves the model in the request.

=cut

sub load {
    my($self, $query) = @_;

    # May be called without args
    $query = {} unless defined($query);

    my($auth_id) = $self->get_request->get('auth_id');
    if (ref($query) eq 'HASH') {
	my($sql_support) = $self->internal_get_sql_support;
	$query->{auth_id} = $auth_id;
	# Let user override page count
	$query = Bivio::SQL::ListQuery->new($query, $sql_support, $self);
    }
    else {
	$query->put('auth_id' => $auth_id);
    }
    $self->unauth_load($query);
    return;
}

=for html <a name="load_all"></a>

=head2 load_all()

Loads "all" the records in this realm.
If the return is too large, throws a I<Bivio::DieCode::TOO_MANY> exception.

B<Does not use the query from the request.>  Does force I<auth_id>,
however.

=cut

sub load_all {
    my($self) = @_;
    $self->load({count => $self->LOAD_ALL_SIZE});
    _assert_all($self);
    return;
}

=for html <a name="load_from_request"></a>

=head2 load_from_request()

Executes the load from the query string in the request.

=cut

sub load_from_request {
    my($self) = @_;
    my($query) = $self->get_request->unsafe_get('query');
    # Pass a copy of the query, because it is trashed by ListQuery.
    $self->load($query ? {%$query} : {});
    return;
}

=for html <a name="map_primary_key_to_rows"></a>

=head2 map_primary_key_to_rows() : hash_ref

Maps the primary key to all rows.  The primary key values are separated
by perl's subscript separator (C<$;>).

=cut

sub map_primary_key_to_rows {
    my($self) = @_;
    my($primary_key_names)
	    = $self->internal_get_sql_support->get('primary_key_names');
    return {map {(join($;, @$_{@$primary_key_names}), $_)}
	    @{$self->internal_get_rows}};
}

=for html <a name="next_row"></a>

=head2 next_row() : boolean

Advances the cursor to the next row and sets the properties
to the new row's values.  If there are no more rows, returns
false.

B<Only returns false ONCE.  After that calls die.>

=cut

sub next_row {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    Carp::croak('no cursor') unless defined($fields->{cursor});
    $self->internal_clear_model_cache;
    if (++$fields->{cursor} >= int(@{$fields->{rows}})) {
	$fields->{cursor} = undef;
	$self->internal_put($fields->{empty_properties});
	return 0;
    }
    $self->internal_put($fields->{rows}->[$fields->{cursor}]);
    return 1;
}

=for html <a name="prev_row"></a>

=head2 prev_row() : boolean

Backs up the cursor to the previous row and sets the properties
to the new row's values.  If we are at the start, returns
false.

B<Only returns false ONCE.  After that calls die.>

=cut

sub prev_row {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    Carp::croak('no cursor') unless defined($fields->{cursor});
    $self->internal_clear_model_cache;
    if (--$fields->{cursor} < 0) {
	$fields->{cursor} = undef;
	$self->internal_put($fields->{empty_properties});
	return 0;
    }
    $self->internal_put($fields->{rows}->[$fields->{cursor}]);
    return 1;
}

=for html <a name="reset_cursor"></a>

=head2 reset_cursor()

Places the cursor at the start of the list.

=cut

sub reset_cursor {
    shift->{$_PACKAGE}->{cursor} = -1;
    return;
}

=for html <a name="set_cursor"></a>

=head2 set_cursor(int index) : boolean

Sets the row to I<index> (starts at 0).  Returns false if
just after last row.  Other indices cause termination.

Particularly useful for "this" queries.  Can check if
"this" loaded by calling C<set_cursor(0)>.

I<index> may also be L<LAST_ROW|"LAST_ROW">.

=cut

sub set_cursor {
    my($self, $index) = @_;
    my($fields) = $self->{$_PACKAGE};
    Carp::croak('not loaded') unless $fields->{rows};
    $self->internal_clear_model_cache;
    my($n) = int(@{$fields->{rows}});
    if ($index == $self->LAST_ROW) {
	$index = $n - 1;
	# Fall through to handle empty list case.
    }
    if ($index >= $n) {
	Carp::croak("$index: invalid index") if $index > $n;
	$fields->{cursor} = undef;
	$self->internal_put($fields->{empty_properties});
	return 0;
    }
    Carp::croak("$index: invalid index") if $index < 0;
    $self->internal_put($fields->{rows}->[$fields->{cursor} = $index]);
    return 1;
}

=for html <a name="unauth_load"></a>

=head2 unauth_load(hash_ref attrs)

=head2 unauth_load(Bivio::SQL::ListQuery query)

Loads the model without forcing I<auth_id>.

I<attrs> is not the same as I<query> of L<load|"load">.  I<attrs> is
passed to
L<Bivio::SQL::ListQuery::unauth_new|Bivio::SQL::ListQuery/"unauth_new">,
while I<query> is L<Bivio::SQL::ListQuery::new|Bivio::SQL::ListQuery/"new">.
B<Use the full names of ListQuery attributes.>

I<count> will be set to L<PAGE_SIZE|"PAGE_SIZE"> if not already
set.

=cut

sub unauth_load {
    my($self, $query) = @_;
    my($sql_support) = $self->internal_get_sql_support;

    # Convert to listQuery
    $query = Bivio::SQL::ListQuery->unauth_new($query, $self, $sql_support)
	    if ref($query) eq 'HASH';

    # Add in count if not there
    $query->put(count => $self->PAGE_SIZE()) unless $query->has_keys('count');

    # Let the subclass add specializations to the query.
    my($params) = [];
    my($where) = $self->internal_pre_load($query, $sql_support, $params);
    $where = ' and '.$where if $where;
    $self->internal_load(
	    $self->internal_load_rows($query, $where, $params, $sql_support),
	    $query);
    return;
}

=for html <a name="unauth_load_all"></a>

=head2 unauth_load(hash_ref attrs)

=head2 unauth_load(Bivio::SQL::ListQuery query)

Adds in I<count> equal to L<LOAD_ALL_SIZE|"LOAD_ALL_SIZE">.

If the return is too large, throws a I<Bivio::DieCode::TOO_MANY> exception.

=cut

sub unauth_load_all {
    my($self, $query) = @_;
    if (ref($query) eq 'HASH') {
	$query->{count} = $self->LOAD_ALL_SIZE;
    }
    else {
	$query->put(count => $self->LOAD_ALL_SIZE);
    }
    $self->unauth_load($query);
    _assert_all($self);
    return;
}

#=PRIVATE METHODS

# _assert_all(Bivio::Biz::ListModel self)
#
# Throws an exception if there are too many rows returned.
#
sub _assert_all {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    $self->die(Bivio::DieCode::TOO_MANY(), "more than 200 records")
	    if $fields->{query}->get('has_next');
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
