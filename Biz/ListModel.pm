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
rows.  This class is always subclassed.

=cut


=head1 CONSTANTS

=cut

=for html <a name="PAGE_SIZE"></a>

=head2 PAGE_SIZE : int

Default page size for display.

May be overridden.

=cut

sub PAGE_SIZE {
#TODO: Move this into a preference
    return 15;
}

#=IMPORTS
use Bivio::SQL::ListSupport;
use Bivio::SQL::ListQuery;

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

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 static execute(Bivio::Agent::Request req)

Loads a new instance of this model using the request.

=cut

sub execute {
    my($proto, $req) = @_;
    my($query) = $req->unsafe_get('query');
    # Pass a copy of the query, because it is trashed by ListQuery.
    $proto->new($req)->load($query ? {%$query} : {});
    return;
}

=for html <a name="format_uri_for_next"></a>

=head2 format_uri_for_next() : string

Returns the formated uri for next row.  The request bound to next list model
must have a I<detail_uri> attribute not including the query string.

=cut

sub format_uri_for_next {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($c) = $fields->{cursor};
    Carp::croak('no cursor') unless defined($c) && $c >= 0;
    my($sql_support) = $self->internal_get_sql_support();
    return $self->get_request->get('detail_uri')
	    .'?'.$fields->{query}->format_uri_for_next($sql_support);
}

=for html <a name="format_uri_for_next_page"></a>

=head2 format_uri_for_next_page() : string

Returns the formated uri for the next page.  The request bound to this list
model must have a I<list_uri> attribute not including the query string.

=cut

sub format_uri_for_next_page {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    Carp::croak('not loaded') unless $fields->{rows};
    my($sql_support) = $self->internal_get_sql_support();
    my($row) = $fields->{rows}->[$#{$fields->{rows}}];
    return $self->get_request->get('list_uri').'?'
	    .$fields->{query}->format_uri_for_next_page($sql_support);
}

=for html <a name="format_uri_for_prev"></a>

=head2 format_uri_for_prev() : string

Returns the formated uri for prev row.  The request bound to prev list model
must have a I<detail_uri> attribute not including the query string.

=cut

sub format_uri_for_prev {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($c) = $fields->{cursor};
    Carp::croak('no cursor') unless defined($c) && $c >= 0;
    my($sql_support) = $self->internal_get_sql_support();
    return $self->get_request->get('detail_uri')
	    .'?'.$fields->{query}->format_uri_for_prev($sql_support);
}

=for html <a name="format_uri_for_prev_page"></a>

=head2 format_uri_for_prev_page() : string

Returns the formated uri for the previous page.  The request bound to this list
model must have a I<list_uri> attribute not including the query string.

=cut

sub format_uri_for_prev_page {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    Carp::croak('not loaded') unless $fields->{rows};
    my($sql_support) = $self->internal_get_sql_support();
    my($row) = $fields->{rows}->[0];
    return $self->get_request->get('list_uri').'?'
	    .$fields->{query}->format_uri_for_prev_page($sql_support);
}

=for html <a name="format_uri_for_this"></a>

=head2 format_uri_for_this() : string

Returns the formated uri for this row.  The request bound to this list model
must have a I<detail_uri> attribute not including the query string.

=cut

sub format_uri_for_this {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($c) = $fields->{cursor};
    Carp::croak('no cursor') unless defined($c) && $c >= 0;
    my($sql_support) = $self->internal_get_sql_support();
    return $self->get_request->get('detail_uri')
	    .'?'.$fields->{query}->format_uri_for_this(
		    $self->internal_get(), $sql_support);
}

=for html <a name="format_uri_for_this_child"></a>

=head2 format_uri_for_this_child() : string

Returns the formated uri for this row which is a child list.  The primary key
of such this list must be a single primary id.  The request bound to this list
model must have a I<detail_uri> attribute not including the query string.

=cut

sub format_uri_for_this_child {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($c) = $fields->{cursor};
    Carp::croak('no cursor') unless defined($c) && $c >= 0;
    my($sql_support) = $self->internal_get_sql_support();
    return $self->get_request->get('detail_uri')
	    .'?'.$fields->{query}->format_uri_for_this_child(
		    $self->internal_get(), $sql_support);
}

=for html <a name="format_uri_for_this_page"></a>

=head2 format_uri_for_this_page() : string

Returns the formated uri for the page which contains I<this>.  The request
bound to this list model must have a I<list_uri> attribute not including the
query string.

=cut

sub format_uri_for_this_page {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($c) = $fields->{cursor};
    Carp::croak('no cursor') unless defined($c) && $c >= 0;
    my($sql_support) = $self->internal_get_sql_support();
    return $self->get_request->get('list_uri')
	    .'?'.$fields->{query}->format_uri_for_this_page($sql_support);
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

Returns the L<Bivio::SQL::ListSupport|Bivio::SQL::ListSupport>
for this class.  Calls L<internal_initialize|"internal_initialize">
to get the hash_ref to initialize the sql support instance.

=cut

sub internal_initialize_sql_support {
    return Bivio::SQL::ListSupport->new(shift->internal_initialize);
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
    $self->get_request->put(ref($self) => $self, list_model => $self);
    return;
}

=for html <a name="internal_search"></a>

=head2 internal_search(Bivio::SQL::ListQuery query, Bivio::SQL::ListSupport support, array_ref params) : string

Returns the where clause and params associated as the result of a
"search".

=cut

sub internal_search {
    # Returns empty where when user passes in search string and
    # search string is not supported.
#TODO: throw corrupt_query?
    return '';
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
    # Clear out old query
    my($auth_id) = $self->get_request->get('auth_id');
    my($sql_support) = $self->internal_get_sql_support;
    $query = {} unless defined($query);
    if (ref($query) eq 'HASH') {
	$query->{auth_id} = $auth_id;
	# Let user override page count
	$query->{count} = $self->PAGE_SIZE() unless $query->{count};
	$query = Bivio::SQL::ListQuery->new($query, $sql_support, $self);
    }
    else {
	$query->put('auth_id' => $auth_id);
    }
    my($where, $params) = ('', []);
    $where = $self->internal_search($query, $sql_support, $params)
	    if defined($query->{search});
    $self->internal_load($sql_support->load($query, $where, $params,
	    $self), $query);
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

=for html <a name="reset_cursor"></a>

=head2 reset_cursor()

Places the cursor at the start of the list.

=cut

sub reset_cursor {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{cursor} = -1;
    return;
}

=for html <a name="set_cursor"></a>

=head2 set_cursor(int index) : boolean

Sets the row to I<index> (starts at 0).  Returns false if
just after last row.  Other indices cause termination.

Particularly useful for "this" queries.  Can check if
"this" loaded by calling C<set_cursor(0)>.

=cut

sub set_cursor {
    my($self, $index) = @_;
    my($fields) = $self->{$_PACKAGE};
    Carp::croak('not loaded') unless $fields->{rows};
    $self->internal_clear_model_cache;
    my($n) = int(@{$fields->{rows}});
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

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
