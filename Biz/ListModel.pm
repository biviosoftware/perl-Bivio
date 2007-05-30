# Copyright (c) 1999-2006 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::ListModel;
use strict;
$Bivio::Biz::ListModel::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::ListModel::VERSION;

=head1 NAME

Bivio::Biz::ListModel - an abstract model of an SQL query and result

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

   use Bivio::Biz::ListModel;

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
L<new_anonymous|Bivio::Biz::ListModel/"new_anonymous">.

Here is a an example iteration:

   $list->reset_cursor;
   while ($list->next_row) {
       print $list->get('my_attr'), "\n";
   }

You can also:

   $list->set_cursor_or_not_found(0);
   print $list->get('my_attr'), "\n";

Or:

   $list->set_cursor_or_die(0);
   print $list->get('my_attr'), "\n";

=cut

=head1 CONSTANTS

=cut

=for html <a name="EMPTY_KEY_VALUE"></a>

=head2 EMPTY_KEY_VALUE : string

The value used to populate keys for rows added by append_empty_rows().

=cut

sub EMPTY_KEY_VALUE {
    return '1';
}

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
    return Bivio::SQL::ListQuery->DEFAULT_MAX_COUNT;
}

=for html <a name="NOT_FOUND_IF_EMPTY"></a>

=head2 NOT_FOUND_IF_EMPTY : boolean

Returning true causes load to blow up if no rows are returned.
Default is false.

=cut

sub NOT_FOUND_IF_EMPTY {
    return 0;
}

#=IMPORTS
use Bivio::Biz::Model::SummaryList;
use Bivio::Biz::QueryType;
use Bivio::Die;
use Bivio::IO::Trace;
use Bivio::SQL::ListQuery;
use Bivio::SQL::ListSupport;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_IDI) = __PACKAGE__->instance_data_index;
my($_LOAD_ALL_DIE_FACTOR) = 2;
Bivio::IO::Config->register(my $_CFG = {
    want_page_count => 1,
});

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::Request req) : Bivio::Biz::ListModel

Create a new ListModel associated with the request.

=cut

sub new {
    return _new(shift->SUPER::new(@_));
}

=for html <a name="new_anonymous"></a>

=head2 static new_anonymous(hash_ref config) : Bivio::Biz::ListModel

=head2 static new_anonymous(hash_ref config, Bivio::Agent::Request req) : Bivio::Biz::ListModel

Create a new_anonymous ListModel associated with the request.
Defaults version and can_iterate to 1.

=cut

sub new_anonymous {
    my(undef, $config) = @_;
    if (ref($config) eq 'HASH') {
	$config->{version} ||= 1;
	# Always can_iterate, since pure SQL
	$config->{can_iterate} = 1;
    };
    return _new(shift->SUPER::new_anonymous(@_));
}

=head1 METHODS

=cut

=for html <a name="append_empty_rows"></a>

=head2 append_empty_rows(int count)

Adds the specified number of empty rows to the end of the list.

=cut

sub append_empty_rows {
    my($self, $count) = @_;
    my($rows) = $self->internal_get_rows;

    # create an empty row
    my($empty_row) = {};
    foreach my $field (@{$self->get_keys}) {
	$empty_row->{$field} = undef;
    }
    # give each key a bogus value
    foreach my $key (@{$self->get_info('primary_key_names')}) {
	$empty_row->{$key} = $self->EMPTY_KEY_VALUE();
    }

    while ($count--) {
	# append a copy of the empty row
	push(@$rows, {%$empty_row});
    }
    return;
}

=for html <a name="append_load_notes"></a>

=head2 append_load_notes(string msg)

Appends I<msg> to the internal load notes.

=cut

sub append_load_notes {
    my($self, $msg) = @_;
    $self->[$_IDI]->{load_notes} .= $msg;
    return;
}

=for html <a name="assert_has_cursor"></a>

=head2 assert_has_cursor() : self

Dies if cursor not set.

=cut

sub assert_has_cursor {
    my($self) = @_;
    $self->die('no cursor') unless $self->has_cursor;
    return $self;
}

=for html <a name="can_iterate"></a>

=head2 can_iterate() : boolean

Returns true if L<iterate_start|"iterate_start"> can be called.
Most ListModels are not set up for iterations.

Default is false.

=cut

sub can_iterate {
    return shift->get_info('can_iterate');
}

=for html <a name="can_next_row"></a>

=head2 can_next_row() : boolean

Returns true if next_row can be called.

=cut

sub can_next_row {
    return defined(shift->[$_IDI]->{cursor}) ? 1 : 0;
}

=for html <a name="do_rows"></a>

=head2 do_rows(code_ref do_rows_handler) : self

Calls L<reset_cursor|"reset_cursor">, then I<do_rows_handler> for each row in
the list.  If I<do_rows_handler> returns false, stops iteration.

=cut

sub do_rows {
    my($self, $do_rows_handler) = @_;
    $self->reset_cursor;
    0 while $self->next_row && $do_rows_handler->($self);
    return $self;
}

=for html <a name="do_rows_handler"></a>

=head2 callback do_rows_handler(self) : boolean

Called by L<do_rows|"do_rows">.

=cut

$_ = <<'}'; # emacs
sub do_rows_handler {
}

=for html <a name="empty_query"></a>

=head2 empty_query() : Bivio::SQL::ListQuery

Returns an empty query.  Does not contain an I<auth_id>.

=cut

sub empty_query {
    my($self) = @_;
    return Bivio::SQL::ListQuery->new(
	{}, $self->internal_get_sql_support, $self);
}

=for html <a name="execute_load_all"></a>

=head2 execute_load_all(Bivio::Agent::Request req) : boolean

Loads "all" records of this model.

=cut

sub execute_load_all {
    my($proto, $req) = @_;
    $proto->new($req)->load_all();
    return 0;
}

=for html <a name="execute_load_all_with_query"></a>

=head2 execute_load_all_with_query(Bivio::Agent::Request req) : boolean

Loads "all" records of this model, using the query (for order_by, etc).

=cut

sub execute_load_all_with_query {
    my($proto, $req) = @_;
    my($self) = $proto->new($req);
    my($query) = $self->parse_query_from_request;

#TODO: Need to check for "this".  It is a corrupt query if it is
#    passed in.
#TODO: I found it useful to have a "this", so maybe it's not a bad idea.
#    For now, we delete the this.
    $query->put(this => undef);

    $self->load_all($query);
    return 0;
}

=for html <a name="execute_load_page"></a>

=head2 execute_load_page(Bivio::Agent::Request req) : boolean

Loads current page from I<req> query.

Requests a I<page_count> by setting I<want_page_count> on the
queury.

=cut

sub execute_load_page {
    my($proto, $req) = @_;
    my($self) = $proto->new($req);
    $self->load_page($self->parse_query_from_request());
    return 0;
}

=for html <a name="execute_load_this"></a>

=head2 static execute_load_this(Bivio::Agent::Request req) : boolean

Executes L<load_this|"load_this"> from I<req> query.

=cut

sub execute_load_this {
    my($proto, $req) = @_;
    my($self) = $proto->new($req);
    my($query) = $self->parse_query_from_request();
    $self->throw_die('CORRUPT_QUERY', {
	message => 'missing this',
	query => $req->unsafe_get('query'),
    }) unless $query->unsafe_get('this');
    $self->load_this($query);
    return 0;
}

=for html <a name="execute_load_this_or_first"></a>

=head2 static execute_load_this_or_first(Bivio::Agent::Request req) : boolean

Loads I<this> from I<req> query or first element in list.

=cut

sub execute_load_this_or_first {
    my($proto, $req) = @_;
    my($self) = $proto->new($req);
    $self->load_this_or_first($self->parse_query_from_request());
    return 0;
}

=for html <a name="find_row_by"></a>

=head2 find_row_by(string field, string value) : self

Sets the cursor by I<field> and returns self or returns undef.

=cut

sub find_row_by {
    my($self, $field, $value) = @_;
    my($t) = $self->get_field_type($field);
    return $self->do_rows(sub {!$t->is_equal($self->get($field), $value)})
	->has_cursor ? $self : undef;
}

=for html <a name="format_query"></a>

=head2 format_query(Bivio::Biz::QueryType type) : string

=head2 format_query(Bivio::Biz::QueryType type, hash_ref args) : string

=head2 format_query(string type) : string

=head2 format_query(string type, hash_ref args) : string

Just the query part of L<format_uri|"format_uri">.  May return undef
if this QueryType doesn't have a query (e.g. I<THIS_PATH_NO_QUERY>).

If I<args> are provided, they will be forwarded to the query formatting.

=cut

sub format_query {
    my($self, $type, $args) = @_;
    my($fields) = $self->[$_IDI];
    $args = {} unless defined($args);

    # Convert to enum unless already converted
    $type = Bivio::Biz::QueryType->from_name($type) unless ref($type);

    # Get the query using the method defined in QueryType
    my($method) = $type->get_method;
    return undef unless $method;

    # Determine if need to pass in current row
    if ($type->get_name =~ /DETAIL|THIS_CHILD_LIST|THIS_AS_PARENT|PATH/) {
	my($c) = $fields->{cursor};
	Carp::croak('no cursor') unless defined($c) && $c >= 0;
	$args = {%{$self->internal_get}, %$args};
    }
    else {
	Carp::croak('not loaded') unless $fields->{rows};
    }

    return $fields->{query}->$method($self->internal_get_sql_support(), $args);
}

=for html <a name="format_uri"></a>

=head2 format_uri(any type, any uri_or_task, hash_ref query_args) : string

Returns the formatted uri for I<type> based on the existing query
bound to this model.  If I<uri_or_task> is not supplied,
uses current request's I<task_id>.

If I<uri_or_task> is a valid enum name or is an actual TaskId instance,
I<uri_or_task> will be treated as a task.

Otherwise, I<uri_or_task> will be treated as a uri.

If I<query_args> are provided, they'll be added to the query.

If the type is I<THIS_PATH>, the list must have a I<path_info> attribute
which doesn't begin with a leading slash and is already URI-escaped.
See L<Bivio::Biz::Model::FilePathList|Bivio::Biz::Model::FilePathList>
for an example.

B<DEPRECATED USAGE:> If I<uri_or_task> is not supplied, gets
I<detail_uri> or I<list_uri> from the request.  See
L<Bivio::Biz::QueryType|Bivio::Biz::QueryType>.

=cut

sub format_uri {
    my($self, $type, $uri, $query_args, $req) = _format_uri_args(@_);
    my($fields) = $self->[$_IDI];

    if ($type->get_name =~ /PATH/) {
	my($c) = $fields->{cursor};
	die('no cursor') unless defined($c) && $c >= 0;
	my($pi) = $self->get('path_info');
	Bivio::Die->die('row ', $c, ': no path_info at cursor')
		    unless defined($pi);
	if (length($pi) && $pi ne '/') {
	    Bivio::IO::Alert->warn_deprecated(
		    'path_info does not begin with leading /')
			if $pi =~ s!^([^/])!/$1!;
	    $uri .= Bivio::HTML->escape_uri($pi);
	}
    }
    my($query) = $self->format_query($type, $query_args);

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

=for html <a name="format_uri_for_sort"></a>

=head2 format_uri_for_sort(any uri_or_task, boolean direction, array order_fields) : string

Format I<uri_or_task> for I<THIS_LIST> to sort by the fields
I<order_fields> and order by I<direction>.
If I<direction> is undefined, uses the first field's default sort order.

=cut

sub format_uri_for_sort {
    my($self, $uri_or_task, $direction, @order_fields) = @_;
    my($order) = defined($direction)
        ? $direction
        : $self->get_field_info($order_fields[0], 'sort_order');
    my(@order_by);

    foreach my $field (@order_fields) {
        push(@order_by, $field, $order);
    }
    return $self->format_uri('THIS_LIST', $uri_or_task, {
        order_by => \@order_by,
        page_number => 1,
    });
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
    return shift->[$_IDI]->{cursor};
}

=for html <a name="get_hidden_field_values"></a>

=head2 get_hidden_field_values() : array_ref

  Q: Can you say hack?
  I knew you could...

Emulate L<Bivio::Biz::FormModel::get_hidden_field_values|Bivio::Biz::FormModel/"get_hidden_field_values">

=cut

sub get_hidden_field_values {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return $fields->{query}->get_hidden_field_values(
	    $self->internal_get_sql_support());
}

=for html <a name="get_list_model"></a>

=head2 get_list_model() : Bivio::Biz::ListModel

Returns itself, the list model.

=cut

sub get_list_model {
    return shift;
}

=for html <a name="get_load_notes"></a>

=head2 get_load_notes() : string

Return notes about how the query list was loaded.

Used by Biz::Util::ListModel.

=cut

sub get_load_notes {
    my($self) = @_;
    return $self->[$_IDI]->{load_notes};
}

=for html <a name="get_query"></a>

=head2 get_query() : Bivio::SQL::ListQuery

Returns the
L<Bivio::SQL::ListQuery|Bivio::SQL::ListQuery>
associated with this list model.

=cut

sub get_query {
    return shift->[$_IDI]->{query};
}

=for html <a name="get_query_as_hash"></a>

=head2 get_query_as_hash(Bivio::Biz::QueryType type) : hash_ref

=head2 get_query_as_hash(string type) : hash_ref

Same as L<format_query|"format_query"> except that it returns as an
(unescaped) hash, not a string.

Returns C<undef> if the query is empty.

=cut

sub get_query_as_hash {
    my($self) = shift;
    # Easier to do this way than to try to modularize the code for
    # this one case.  Typical case is that the string is empty.
    # If there is one element, it's easy, too.
    my($s) = $self->format_query(@_);
    return length($s) ? Bivio::Agent::HTTP::Query->parse($s) : undef;
}

=for html <a name="get_result_set_size"></a>

=head2 get_result_set_size() : int

Returns the number of rows loaded.

=cut

sub get_result_set_size {
    my($rows) = shift->[$_IDI]->{rows};
    Carp::croak('not loaded') unless $rows;
    return int(@$rows);
}

=for html <a name="get_summary"></a>

=head2 get_summary() : Bivio::Biz::Model::SummaryList

Returns the summary list for this model.

=cut

sub get_summary {
    my($self) = @_;
    _trace(ref($self)) if $_TRACE;

    # need to create a new one on each call to avoid circular reference
    return Bivio::Biz::Model::SummaryList->new([$self]);
}

=for html <a name="handle_config"></a>

=head2 handle_config(hash_ref cfg)

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

=for html <a name="has_cursor"></a>

=head2 has_cursor() : boolean

Returns true if there is a row loaded, i.e. cursor is non-negative
and defined.

=cut

sub has_cursor {
    my($cursor) = shift->[$_IDI]->{cursor};
    return defined($cursor) && $cursor >= 0 ? 1 : 0;
}

=for html <a name="has_next"></a>

=head2 has_next() : boolean

Is there next page or item to this list model?

=cut

sub has_next {
    return shift->[$_IDI]->{query}->get('has_next');
}

=for html <a name="has_prev"></a>

=head2 has_prev() : boolean

Is there prev page or item to this list model?

=cut

sub has_prev {
    return shift->[$_IDI]->{query}->get('has_prev');
}

=for html <a name="internal_get_rows"></a>

=head2 internal_get_rows() : array_ref

B<FOR INTERNAL USE ONLY.>

Returns the rows associated with the query.  If the model
hasn't been loaded, blows up.

=cut

sub internal_get_rows {
    my($self) = @_;
    return $self->[$_IDI]->{rows} || $self->die('not loaded');
}

=for html <a name="internal_initialize_sql_support"></a>

=head2 static internal_initialize_sql_support(Bivio::SQL::Statement stmt) : Bivio::SQL::Support

=head2 static internal_initialize_sql_support(Bivio::SQL::Statement stmt, hash_ref config) : Bivio::SQL::Support

=head2 static internal_initialize_sql_support(Bivio::SQL::Statement stmt, code_ref config) : Bivio::SQL::Support

Returns the L<Bivio::SQL::ListSupport|Bivio::SQL::ListSupport>
for this class.  Calls L<internal_initialize|"internal_initialize">
to get the hash_ref to initialize the sql support instance.

You can create anonymous list model.  Simply supply the configuration
that is returned by C<internal_initialize> to new_anonymous.

This method is complicated by the use of Bivio::SQL::Statement to build
the model declaration.  We call build_decl_for_sql_support to ask the
statement what columns are on this model.

=cut

sub internal_initialize_sql_support {
    my($proto, $stmt, $config) = @_;

    my($decl);
    if (ref($config) eq 'CODE') {
	$stmt->config($config->($proto, $stmt));
        $decl = {
            version => 1,
            can_iterate => 1,
	};
    }
    else {
        $decl = $config || $proto->internal_initialize($stmt);
    }
    $decl->{class} = ref($proto) || $proto;

    return Bivio::SQL::ListSupport->new(
        $proto->merge_initialize_info($decl,
	    $stmt->build_decl_for_sql_support()),
	$stmt);
}

=for html <a name="internal_is_loaded"></a>

=head2 internal_is_loaded() : boolean

Returns true if is loaded.

=cut

sub internal_is_loaded {
    return shift->is_loaded();
}

=for html <a name="internal_load"></a>

=head2 internal_load(array_ref rows, Bivio::SQL::ListQuery query)

B<FOR INTERNAL USE ONLY.>

Loads the ListModel with I<rows>.

Calls L<internal_post_load_row|"internal_post_load_row"> after
all the rows are loaded if I<self> implements this method.

If I<query> is C<undef>, call L<empty_query|"empty_query">.

=cut

sub internal_load {
    my($self, $rows, $query) = @_;
    $query ||= $self->empty_query;
    # Easier to just replace the hash_ref
    my($empty_properties, $load_notes) = @{$self->[$_IDI]}{
	qw(empty_properties load_notes)};
    $self->[$_IDI] = {
	rows => $rows,
	cursor => -1,
	query => $query,
	empty_properties => $empty_properties,
 	load_notes => $load_notes,
    };
    $self->internal_clear_model_cache;
    $self->internal_put($empty_properties);
    $self->throw_die('MODEL_NOT_FOUND')
        if $self->NOT_FOUND_IF_EMPTY && !@$rows;
    $self->put_on_request;
    my($req) = $self->unsafe_get_request;
    $req->put(list_model => $self) if $req;

    if ($self->can('internal_post_load_row')) {
	for (my($i) = 0; $i <= $#$rows; $i++) {
	    splice(@$rows, $i--, 1)
		unless $self->internal_post_load_row($rows->[$i]);
	}
    }
    return;
}

=for html <a name="internal_post_load_row"></a>

=head2 abstract internal_post_load_row(hash_ref row) : boolean

Used to fix up a row after loading.  No state should be assumed except
the row itself.

Returns false if the row should be ignored.

=cut

$_ = <<'}'; # emacs
sub internal_post_load_row {
}

=for html <a name="internal_pre_load"></a>

=head2 internal_pre_load(Bivio::SQL::ListQuery query, Bivio::SQL::ListSupport support, array_ref params) : string

B<DEPRECATED>, use L<internal_prepare_statement|"internal_prepare_statement">.

=cut

sub internal_pre_load {
    return '';
}

=for html <a name="internal_load_rows"></a>

=head2 internal_load_rows(Bivio::SQL::ListQuery query, Bivio::SQL::Statement stmt, string where, array_ref params, Bivio::SQL::ListSupport sql_support) : array_ref

May be overriden.  Must return the rows loaded.

=cut

sub internal_load_rows {
    my($self, $query, $stmt, $where, $params, $sql_support) = @_;
    return $sql_support->load($query, $stmt, $where, $params, $self);
}

=for html <a name="internal_prepare_statement"></a>

=head2 internal_prepare_statement(Bivio::SQL::Statement stmt, Bivio::SQL::ListQuery query)

Passes I<stmt> so model can modify the SQL query to be generated.

=cut

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;
    return;
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

=for html <a name="is_loaded"></a>

=head2 is_loaded : boolean

Has load been called?

=cut

sub is_loaded {
    return shift->[$_IDI]->{rows} ? 1 : 0;
}

=for html <a name="is_empty_row"></a>

=head2 is_empty_row : boolean

If all primary key(s) equal EMPTY_KEY_VALUE.

=cut

sub is_empty_row {
    my($self) = @_;
    foreach my $k (@{$self->get_info('primary_key_names')}) {
	return 0 unless $self->get_field_type($k)->is_equal(
	    $self->get($k), $self->EMPTY_KEY_VALUE,
	);
    }
    return 1;
}

=for html <a name="iterate_next"></a>

=head2 iterate_next(hash_ref row) : boolean

=head2 iterate_next(hash_ref row, string converter) : boolean

I<row> is the resultant values by field name.
I<converter> is optional and is the name of a
L<Bivio::Type|Bivio::Type> method, e.g. C<to_html>.

B<Puts row on I<self>, but doesn't clear model cache.>

Returns false if there is no next.

Subclasses: Calls L<internal_post_load_row|"internal_post_load_row"> after
the row is loaded if I<self> implements this method.  Care must
be taken when using the values returned, because converter is
already applied.  If internal_post_load_row returns false, the row isn't
returned and another row is attempted.

=cut

sub iterate_next {
    while () {
	my($self, $row) = shift->internal_iterate_next(@_);
	last unless $row;
	next if $self->can('internal_post_load_row')
	   && !$self->internal_post_load_row($row);
	$self->internal_put($row);
	return 1;
    }
    return 0;
}

=for html <a name="iterate_next_and_load"></a>

=head2 iterate_next_and_load() : boolean

Will iterate to the next row and load the model with the row.

It appears as if the model was loaded with one row and the
cursor was set at 0. Do not call L<next_row|"next_row">,
however, or the behaviour will break, i.e. there will be
no cursor.

There may only be one iteration outstanding on an instance.

This is slower than L<iterate_next|"iterate_next">.  The
two routines can be used alternately.

Returns false if there is no next.

=cut

sub iterate_next_and_load {
    my($self, $it) = @_;
    my($fields) = $self->[$_IDI];
    my($row) = {};
    # Initialize once.  It will be overwritten if a real load happens.
    $fields->{rows} = [$row];
    $fields->{cursor} = 0;
    while ($self->internal_get_sql_support->iterate_next(
	$self, $it || $self->internal_get_iterator, $row)) {
	next if $self->can('internal_post_load_row')
	    && !$self->internal_post_load_row($row);
	$self->internal_clear_model_cache;
	$self->internal_put($row);
	return 1;
    }
    $self->internal_clear_model_cache;
    $self->internal_put({%{$fields->{empty_properties}}});
    $fields->{rows} = undef;
    return 0;
}

=head2 iterate_start(hash_ref query) : ref

=head2 iterate_start(Bivio::SQL::ListQuery query) : ref

Begins an iteration which can be used to iterate the rows for this
realm with L<iterate_next|"iterate_next"> or
L<iterate_next_and_load|"iterate_next_and_load">.
L<iterate_end|"iterate_end"> should be called when you are through
with the iteration.

Use this method when you need to make one pass over the data (efficiently).

NOTE: Most ListModels cannot be iterated.  If L<can_iterate|"can_iterate">
returns false, this routine will die.

Calls L<internal_prepare_statement|"internal_prepare_statement">, but
does not call
L<internal_load|"internal_load">.  See L<iterate_next|"iterate_next">
for semantics of row fixups.

B<Deprecated form returns the iterator.>

=cut

sub iterate_start {
    return _iterate_start('parse_query', @_);
}

=for html <a name="load_all"></a>

=head2 load_all()

=head2 load_all(hash_ref attrs)

=head2 load_all(Bivio::SQL::ListQuery query)

Loads "all" the records in this realm.
If the return is too large, throws a I<Bivio::DieCode::TOO_MANY> exception.

B<Does not use the query from the request.>  Does force I<auth_id>,
however.

Returns I<self>.

=cut

sub load_all {
    my($self, $query) = @_;
    $query = $self->parse_query($query);
    $query->put(count => _load_all_die_count($self));
    _unauth_load($self, $query);
    _assert_all($self);
    return $self;
}

=for html <a name="load_page"></a>

=head2 load_empty(any query) : self

Loads instance with empty list.

=cut

sub load_empty {
    my($self, $query) = @_;
    $self->internal_load([], $self->parse_query({
	parent_id => 1,
    }));
    return $self;
}

=for html <a name="load_page"></a>

=head2 load_page(hash_ref query)

=head2 load_page(Bivio::SQL::ListQuery query) : self

Loads the specified page in I<query> which must be a form
acceptable to L<Bivio::SQL::ListQuery|Bivio::SQL::ListQuery>
unless I<query> is already a ListQuery.

I<this> must not be specified.

I<count> will be added to I<query> only if it is a hash_ref.

I<auth_id> will be put in I<query> using the value in the request.

Saves the model in the request.

=cut

sub load_page {
    my($self, $query) = @_;
    $query = $self
	->parse_query($query)
        ->put(want_page_count => $_CFG->{want_page_count});

    $self->throw_die('CORRUPT_QUERY', {message => 'unexpected this',
	query => $query}) if $query->unsafe_get('this');

    _unauth_load($self, $query);
    return $self;
}

=for html <a name="load_this"></a>

=head2 load_this(hash_ref query) : Bivio::Biz::ListModel

=head2 load_this(Bivio::SQL::ListQuery query) : Bivio::Biz::ListModel

Loads the specified I<this> in I<query> which must be a form
acceptable to L<Bivio::SQL::ListQuery|Bivio::SQL::ListQuery>
unless I<query> is already a ListQuery.

I<this> must be specified.

Dies with MODEL_NOT_FOUND if no rows are returned.

I<count> will be added to I<query> only if it is a hash_ref.

I<auth_id> will be put in I<query> using the value in the request.

Saves the model in the request.

Returns I<self> after setting cursor to the first row (0).

=cut

sub load_this {
    my($self, $query) = @_;
    return _load_this($self, $query);
}

=for html <a name="load_this_or_first"></a>

=head2 load_this_or_first(hash_ref query) : Bivio::Biz::ListModel

=head2 load_this_or_first(Bivio::SQL::ListQuery query) : Bivio::Biz::ListModel

Same as L<load_this|"load_this">, but if there is no I<this> on the
query, loads the first element in the list.  If no first element,
returns not found.

Returns I<self> after setting cursor to the first row (0).

=cut

sub load_this_or_first {
    my($self, $query) = @_;
    return _load_this($self, $query, 1);
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

=for html <a name="map_rows"></a>

=head2 map_rows(code_ref map_iterate_handler) : array_ref

Like L<Bivio::Biz::Model::map_iterate|Bivio::Biz::Model/"map_iterate">, but
operates on rows of the table.  Calls L<next_row|"next_row"> until it returns
false.  It calls L<reset_cursor|"reset_cursor"> first.  Typical usage:

    my($rows) = Bivio::Biz::Model->new($req, 'MyList')->load_all->map_rows;

Returns the aggregated result of L<map_iterate_handler|"map_iterate_handler">
as an array_ref.

If I<map_iterate_handler> is C<undef>, the default handler simply returns all
the rows.

=cut

sub map_rows {
    my($self, $map_iterate_handler) = @_;
    my($res) = [];
    $map_iterate_handler ||= sub {
	return shift->get_shallow_copy;
    };
    $self->reset_cursor;
    while ($self->next_row) {
	push(@$res, $map_iterate_handler->($self));
    }
    return $res;
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
    my($fields) = $self->[$_IDI];
    Carp::croak('no cursor') unless defined($fields->{cursor});
    $self->internal_clear_model_cache;
    if (++$fields->{cursor} >= int(@{$fields->{rows}})) {
	$fields->{cursor} = undef;
	$self->internal_put({%{$fields->{empty_properties}}});
	return 0;
    }
    $self->internal_put($fields->{rows}->[$fields->{cursor}]);
    return 1;
}

=for html <a name="next_row_or_die"></a>

=head2 next_row_or_die()

Terminates unless L<next_row|"next_row"> succeeds.

=cut

sub next_row_or_die {
    my($self) = shift;
    $self->throw_die('expecting next row') unless $self->next_row(@_);
    return;
}

=for html <a name="parse_query"></a>

=head2 parse_query(hash_ref query) : Bivio::SQL::ListQuery

=head2 parse_query(Bivio::SQL::ListQuery query) : Bivio::SQL::ListQuery

Does the processing of I<query>.  Converts to
L<Bivio::SQL::ListQuery|Bivio::SQL::ListQuery> which
may modify I<query> if it isn't already a ListQuery.

See also L<parse_query_from_request|"parse_query_from_request">.

Puts I<auth_id> and I<auth_user_id> from request on query in all cases.

=cut

sub parse_query {
    my($self, $query) = @_;
    # May be called without args
    $query = {} unless defined($query);

    my($sql_support) = $self->internal_get_sql_support;
    my($auth_id) = $sql_support->get('auth_id')
	? $self->get_request->get('auth_id') : undef;
    my($auth_user_id) = $sql_support->get('auth_user_id')
	? $self->get_request->get('auth_user_id') : undef;
    if (ref($query) eq 'HASH') {
	$query->{auth_id} = $auth_id;
	$query->{auth_user_id} = $auth_user_id;
	# Let user override page count
	return Bivio::SQL::ListQuery->new($query, $sql_support, $self);
    }

    # Already a list query, put auth_id on query
    $query->put(auth_id => $auth_id);
    $query->put(auth_user_id => $auth_user_id);
    return $query;
}

=for html <a name="parse_query_from_request"></a>

=head2 parse_query_from_request() : Bivio::SQL::ListQuery

Parses the query from the request.  If not set, uses default query.

=cut

sub parse_query_from_request {
    my($self) = @_;
    my($query) = $self->get_request->unsafe_get('query');

    # Make a copy of the query, because we modify the value.
    $query = $query ? {%$query} : {};

    # Clean up the query and then parse.
    Bivio::SQL::ListQuery->clean_raw($query, $self->internal_get_sql_support);
    return $self->parse_query($query);
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
    my($fields) = $self->[$_IDI];
    Carp::croak('no cursor') unless defined($fields->{cursor});
    $self->internal_clear_model_cache;
    if (--$fields->{cursor} < 0) {
	$fields->{cursor} = undef;
	$self->internal_put({%{$fields->{empty_properties}}});
	return 0;
    }
    $self->internal_put($fields->{rows}->[$fields->{cursor}]);
    return 1;
}

=for html <a name="reset_cursor"></a>

=head2 reset_cursor() : self

Places the cursor before the start of the list.

=cut

sub reset_cursor {
    my($self) = @_;
    $self->internal_clear_model_cache;
    $self->[$_IDI]->{cursor} = -1;
    return $self;
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
    my($fields) = $self->[$_IDI];
    $self->die('not loaded')
        unless $fields->{rows};
    $self->internal_clear_model_cache;
    my($n) = int(@{$fields->{rows}});
    if ($index == $self->LAST_ROW) {
	$index = $n - 1;
	# Fall through to handle empty list case.
    }
    if ($index >= $n) {
	$self->die("$index: invalid index")
	    if $index > $n;
	$fields->{cursor} = undef;
	$self->internal_put({%{$fields->{empty_properties}}});
	return 0;
    }
    $self->die("$index: invalid index")
	if $index < 0;
    $self->internal_put($fields->{rows}->[$fields->{cursor} = $index]);
    return 1;
}

=for html <a name="set_cursor_or_die"></a>

=head2 set_cursor_or_die(int index) : Bivio::Biz::ListModel

Calls L<set_cursor|"set_cursor"> and dies with DIE
if it returns false.

Returns self.

=cut

sub set_cursor_or_die {
    my($self) = shift;
    $self->throw_die('DIE', {message => 'no such row', entity => $_[0]})
	unless $self->set_cursor(@_);
    return $self;
}

=for html <a name="set_cursor_or_not_found"></a>

=head2 set_cursor_or_not_found(int index) : Bivio::Biz::ListModel

Calls L<set_cursor|"set_cursor"> and dies with NOT_FOUND
if it returns false.

Returns self.

=cut

sub set_cursor_or_not_found {
    my($self) = shift;
    $self->throw_die(
	'MODEL_NOT_FOUND', {message => 'no such row', entity => $_[0]},
    ) unless $self->set_cursor(@_);
    return $self;
}

=head2 unauth_iterate_start(hash_ref query) : ref

=head2 unauth_iterate_start(Bivio::SQL::ListQuery query) : ref

Begins an iteration which can be used to iterate the rows for this
realm with L<iterate_next|"iterate_next"> or
L<iterate_next_and_load|"iterate_next_and_load">.
L<iterate_end|"iterate_end"> should be called when you are through
with the iteration.

B<Deprecated form returns the iterator.>

=cut

sub unauth_iterate_start {
    return _iterate_start(unauth_parse_query => @_);
}

=for html <a name="unauth_load_all"></a>

=head2 unauth_load_all(hash_ref attrs) : Bivio::Biz::Model::ListModel

=head2 unauth_load_all(Bivio::SQL::ListQuery query) : Bivio::Biz::Model::ListModel

Adds in I<count> equal to L<LOAD_ALL_SIZE|"LOAD_ALL_SIZE">.

If the return is too large, throws a I<Bivio::DieCode::TOO_MANY> exception.

Returns I<self>.

=cut

sub unauth_load_all {
    my($self, $query) = @_;
    $query ||= {};
    if (ref($query) eq 'HASH') {
	$query->{count} = _load_all_die_count($self);
    }
    else {
	$query->put(count => _load_all_die_count($self));
    }
    _unauth_load($self, $query);
    _assert_all($self);
    return $self;
}

=for html <a name="unauth_parse_query"></a>

=head2 unauth_parse_query(hash_ref query) : Bivio::SQL::ListQuery

=head2 unauth_parse_query(Bivio::SQL::ListQuery query) : Bivio::SQL::ListQuery

Does the processing of I<query>.  Converts to
L<Bivio::SQL::ListQuery|Bivio::SQL::ListQuery> which
may modify I<query> if it isn't already a ListQuery.

=cut

sub unauth_parse_query {
    my($self, $query) = @_;
    return UNIVERSAL::isa($query, 'Bivio::SQL::ListQuery') ? $query
	: Bivio::SQL::ListQuery->unauth_new(
	    $query || {}, $self->internal_get_sql_support, $self);
}

=for html <a name="unsafe_load_this"></a>

=head2 unsafe_load_this(any query) : boolean

Loads the specified I<this> in I<query> which must be a form
acceptable to L<Bivio::SQL::ListQuery|Bivio::SQL::ListQuery>
unless I<query> is already a ListQuery.

I<this> must be specified.

Does not die if this is not found.  (Does die if this is too_many.)

=cut

sub unsafe_load_this {
    my($self, $query) = @_;
    return _load_this($self, $query, 0, 1) ? 1 : 0;
}

#=PRIVATE METHODS

# _assert_all(Bivio::Biz::ListModel self)
#
# Throws an exception if there are too many rows returned.
#
sub _assert_all {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    $self->throw_die(Bivio::DieCode->TOO_MANY, 'more than '
        . _load_all_die_count($self) . ' records')
        if $fields->{query}->get('has_next');
    Bivio::IO::Alert->warn('more than ', $self->LOAD_ALL_SIZE,
        ' records returned: ', $self)
        if $self->get_result_set_size > $self->LOAD_ALL_SIZE;
    return;
}

# _format_uri_args(self, any type, any uri, hash_ref query_args) : array
#
# Returns ($self, $type, $uri, $query_args, $req) from the arguments.
# 
#
sub _format_uri_args {
    my($self, $type, $uri, $query_args) = @_;
    my($req) = $self->get_request;

    # Convert to enum unless already converted
    $type = Bivio::Biz::QueryType->from_name($type) unless ref($type);

    Bivio::Die->die('query_args ', $query_args, ' not allowed for ', $type)
	    if $query_args && $type != Bivio::Biz::QueryType->THIS_LIST;

    if (defined($uri)) {
	if (!ref($uri)) {
	    $uri = Bivio::Agent::TaskId->$uri()
		    if Bivio::Agent::TaskId->is_valid_name($uri);
	}

        if (ref($uri) eq 'Bivio::Agent::TaskId') {
	    $uri = $req->format_stateless_uri($uri);
	}
	else {
	    $self->die('unknown type for uri_or_task: ', $uri)
                if ref($uri);
	}
    }
    else {
	# Need to get the list_uri or detail_uri from the request?
	# If specific uri not found, use current task.
#TODO: DEPRECATED usage if there is a detail_uri or list_uri.
	$uri = $req->unsafe_get($type->get_uri_attr) ||
		$req->format_stateless_uri($req->get('task_id'));
    }
    return ($self, $type, $uri, $query_args, $req);
}

# _load_all_die_count(self) : int
#
# Returns the number of rows for LOAD_ALL where load_all() will die()
# rather than warn().
#
sub _load_all_die_count {
    my($self) = @_;
    return $self->LOAD_ALL_SIZE * $_LOAD_ALL_DIE_FACTOR;
}

# _load_this(self, Bivio::SQL::ListQuery query)
#
# Loads this or first.  Sets cursor to 0.
#
sub _load_this {
    my($self, $query, $first_only, $not_found_ok) = @_;
    $query = $self->parse_query($query);
    unless ($query->unsafe_get('this')) {
	$self->throw_die('DIE', {
	    message => 'missing this',
	    query => $query,
	    program_error => 1,
	}) unless $first_only;
	$query->put(want_first_only => 1);
    }
    my($count) = _unauth_load($self, $query);
    return $self->set_cursor_or_die(0)
	if $count == 1;
    $self->throw_die(TOO_MANY => {
	message => 'expecting just one this',
	query => $query,
    }) if $count;
    $self->throw_die(
	MODEL_NOT_FOUND => {
	    message => 'this not found',
	    query => $query,
	},
    ) unless $not_found_ok;
    return;
}

# _new(Bivio::Biz::ListModel self) : Bivio::Biz::ListModel
#
# Finishes instantiation.
#
sub _new {
    my($self) = @_;
    # NOTE: fields are dynamically replaced.  See, e.g. load.
    $self->[$_IDI] = {
	empty_properties => {%{$self->internal_get}},
	load_notes => '',
    };
    return $self;
}

# _iterate_start(string parse_query, self, any query) : ref
sub _iterate_start {
    my($parse_query, $self, $query) = @_;
    $self->throw_die('DIE', 'iteration not supported')
	unless $self->can_iterate;
    my($fields) = $self->[$_IDI];
    $fields->{query} = $self->$parse_query($query);
    return $self->internal_put_iterator(
	$self->internal_get_sql_support->iterate_start(
	    $fields->{query},
	    _statement($self),
	    _where_and_params($self),
	    $self,
        ),
    );
}

# _statement(self) : Bivio::SQL::Statement
#
# Gather changes from internal_prepare_statment and internal_pre_load
#
sub _statement {
    my($self) = @_;
    my($stmt) = Bivio::SQL::Statement->new();
    $self->internal_prepare_statement($stmt, $self->get_query());
    return $stmt;
}

# _unauth_load(Bivio::Biz::ListModel self, hash_ref attrs) : int
# _unauth_load(Bivio::Biz::ListModel self, Bivio::SQL::ListQuery query) : int
#
# Loads the model without forcing I<auth_id>.  Resets load_notes.
#
# I<attrs> is not the same as I<query> of L<load|"load">.  I<attrs> is
# passed to
# L<Bivio::SQL::ListQuery::unauth_new|Bivio::SQL::ListQuery/"unauth_new">,
# while I<query> is L<Bivio::SQL::ListQuery::new|Bivio::SQL::ListQuery/"new">.
# B<Use the full names of ListQuery attributes.>
#
# I<count> will be set to L<PAGE_SIZE|"PAGE_SIZE"> if defined,
# or the user preference for page_size.  Otherwise, PageSize->get_default.
#
# Returns count of rows loaded.
#
sub _unauth_load {
    my($self, $query) = @_;
    my($fields) = $self->[$_IDI];
    $fields->{load_notes} =  '';
    my($sql_support) = $self->internal_get_sql_support;

    # Convert to listQuery
    $query = Bivio::SQL::ListQuery->unauth_new($query, $self, $sql_support)
	if ref($query) eq 'HASH';

    # Add in count if not there
    unless ($query->has_keys('count')) {
	my($count) = Bivio::Type->get_instance('PageSize')->get_default;
	if ($self->can('PAGE_SIZE')) {
	    $count = $self->PAGE_SIZE();
	}
	# only check preferences if that model is present
	else {
	    Bivio::Auth::Support->unsafe_get_user_pref(
		     'PAGE_SIZE', $self->get_request, \$count);
	}
	$query->put(count => $count);
    }
    $fields->{query} = $query;
    $self->internal_load(
	$self->internal_load_rows(
	    $query,
	    _statement($self),
	    _where_and_params($self),
	    $sql_support,
	),
	$query,
    );
    # fields is invalid at this point
    return scalar(@{$self->[$_IDI]->{rows}});
}

# _where_and_params(self) : (string, array_ref)
#
# Gather changes from internal_prepare_statment and internal_pre_load
#
sub _where_and_params {
    my($self) = @_;
    my($params) = [];
    my($where) = $self->internal_pre_load(
	$self->get_query(),
	$self->internal_get_sql_support(),
	$params,
    );
    return ($where, $params);
}

=head1 COPYRIGHT

Copyright (c) 1999-2006 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
