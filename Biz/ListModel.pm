# Copyright (c) 1999-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::ListModel;
use strict;
use Bivio::Base 'Biz.Model';
use Bivio::IO::Trace;

# C<Bivio::Biz::ListModel> is used to describe queries which return multiple
# rows.  This class is typically subclassed.  However, you can create
# anonymous ListModels by calling
# L<new_anonymous|Bivio::Biz::ListModel/"new_anonymous">.
#
# Here is a an example iteration:
#
#    $list->reset_cursor;
#    while ($list->next_row) {
#        print $list->get('my_attr'), "\n";
#    }
#
# You can also:
#
#    $list->set_cursor_or_not_found(0);
#    print $list->get('my_attr'), "\n";
#
# Or:
#
#    $list->set_cursor_or_die(0);
#    print $list->get('my_attr'), "\n";

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_LOAD_ALL_DIE_FACTOR) = 2;
Bivio::IO::Config->register(my $_CFG = {
    want_page_count => 1,
});
my($_LS) = __PACKAGE__->use('SQL.ListSupport');
my($_LQ) = __PACKAGE__->use('SQL.ListQuery');
my($_QT) = __PACKAGE__->use('Biz.QueryType');

sub EMPTY_KEY_VALUE {
    # The value used to populate keys for rows added by append_empty_rows().
    return '1';
}

sub LAST_ROW {
    # Returns a constant which means the "last_row".
    # Something that isn't likely to be hit by subtracting around zero.
    return -999999;
}

sub LOAD_ALL_SIZE {
    # The number of rows loaded by L<load_all|"load_all">.
    #
    # May be overridden.
    return $_LQ->DEFAULT_MAX_COUNT;
}

sub NOT_FOUND_IF_EMPTY {
    # Returning true causes load to blow up if no rows are returned.
    # Default is false.
    return 0;
}

sub RESET_CURSOR {
    return -1;
}

sub append_empty_rows {
    my($self, $count) = @_;
    # Adds the specified number of empty rows to the end of the list.
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

sub append_load_notes {
    my($self, $msg) = @_;
    # Appends I<msg> to the internal load notes.
    $self->[$_IDI]->{load_notes} .= $msg;
    return;
}

sub assert_has_cursor {
    my($self) = @_;
    # Dies if cursor not set.
    $self->die('no cursor') unless $self->has_cursor;
    return $self;
}

sub can_iterate {
    # Returns true if L<iterate_start|"iterate_start"> can be called.
    # Most ListModels are not set up for iterations.
    #
    # Default is false.
    return shift->get_info('can_iterate');
}

sub can_next_row {
    # Returns true if next_row can be called.
    return defined(shift->[$_IDI]->{cursor}) ? 1 : 0;
}

sub do_rows {
    my($delegator, $do_rows_handler) = shift->delegated_args(@_);
    $delegator->reset_cursor;
    0 while $delegator->next_row && $do_rows_handler->($delegator);
    return $delegator;
}

sub empty_query {
    my($self) = @_;
    # Returns an empty query.  Does not contain an I<auth_id>.
    return $_LQ->new(
	{}, $self->internal_get_sql_support, $self);
}

sub execute_load_all {
    my($proto, $req) = @_;
    # Loads "all" records of this model.
    $proto->new($req)->load_all();
    return 0;
}

sub execute_load_all_with_query {
    my($proto, $req) = @_;
    my($self) = $proto->new($req);
    $self->load_all($self->parse_query_from_request->put(this => undef));
    return 0;
}

sub execute_load_page {
    my($proto, $req) = @_;
    my($self) = $proto->new($req);
    $self->load_page($self->parse_query_from_request->put(this => undef));
    return 0;
}

sub execute_load_this {
    my($proto, $req) = @_;
    # Executes L<load_this|"load_this"> from I<req> query.
    my($self) = $proto->new($req);
    my($query) = $self->parse_query_from_request();
    $self->throw_die('CORRUPT_QUERY', {
	message => 'missing this',
	query => $self->get_request->unsafe_get('query'),
    }) unless $query->unsafe_get('this');
    $self->load_this($query);
    return 0;
}

sub execute_load_this_or_first {
    my($proto, $req) = @_;
    # Loads I<this> from I<req> query or first element in list.
    my($self) = $proto->new($req);
    $self->load_this_or_first($self->parse_query_from_request());
    return 0;
}

sub find_row_by {
    my($self, $field, $value) = @_;
    # Sets the cursor by I<field> and returns self or returns undef.
    my($t) = $self->get_field_type($field);
    return $self->do_rows(sub {!$t->is_equal($self->get($field), $value)})
	->has_cursor ? $self : undef;
}

sub format_query {
    my($self, $type, $args) = @_;
    # Just the query part of L<format_uri|"format_uri">.  May return undef
    # if this QueryType doesn't have a query (e.g. I<THIS_PATH_NO_QUERY>).
    #
    # If I<args> are provided, they will be forwarded to the query formatting.
    my($fields) = $self->[$_IDI];
    $args = {} unless defined($args);

    # Convert to enum unless already converted
    $type = $_QT->from_name($type) unless ref($type);

    # Get the query using the method defined in QueryType
    my($method) = $type->get_method;
    return undef unless $method;

    # Determine if need to pass in current row
    if ($type->get_name =~ /DETAIL|THIS_CHILD_LIST|THIS_AS_PARENT|PATH/) {
	my($c) = $fields->{cursor};
	Bivio::Die->die('no cursor')
	    unless defined($c) && $c >= 0;
	$args = {%{$self->internal_get}, %$args};
    }
    else {
	Bivio::Die->die('not loaded')
	    unless $fields->{rows};
    }

    return $fields->{query}->$method($self->internal_get_sql_support(), $args);
}

sub format_uri {
    my($self, $type, $uri, $query_args, $req) = _format_uri_args(@_);
    # Returns the formatted uri for I<type> based on the existing query
    # bound to this model.  If I<uri_or_task> is not supplied,
    # uses current request's I<task_id>.
    #
    # If I<uri_or_task> is a valid enum name or is an actual TaskId instance,
    # I<uri_or_task> will be treated as a task.
    #
    # Otherwise, I<uri_or_task> will be treated as a uri.
    #
    # If I<query_args> are provided, they'll be added to the query.
    #
    # If the type is I<THIS_PATH>, the list must have a I<path_info> attribute
    # which doesn't begin with a leading slash and is already URI-escaped.
    # See L<Bivio::Biz::Model::FilePathList|Bivio::Biz::Model::FilePathList>
    # for an example.
    #
    # B<DEPRECATED USAGE:> If I<uri_or_task> is not supplied, gets
    # I<detail_uri> or I<list_uri> from the request.  See
    # L<$_QT|$_QT>.
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

sub format_uri_for_next {
    # B<DEPRECATED>.  Use L<format_uri|"format_uri">.
    return shift->format_uri($_QT->NEXT_DETAIL, @_);
}

sub format_uri_for_next_page {
    # B<DEPRECATED>.  Use L<format_uri|"format_uri">.
    return shift->format_uri($_QT->NEXT_LIST, @_);
}

sub format_uri_for_prev {
    # B<DEPRECATED>.  Use L<format_uri|"format_uri">.
    return shift->format_uri($_QT->PREV_DETAIL, @_);
}

sub format_uri_for_prev_page {
    # B<DEPRECATED>.  Use L<format_uri|"format_uri">.
    return shift->format_uri($_QT->PREV_LIST, @_);
}

sub format_uri_for_sort {
    my($self, $uri_or_task, $direction, @order_fields) = @_;
    # Format I<uri_or_task> for I<THIS_LIST> to sort by the fields
    # I<order_fields> and order by I<direction>.
    # If I<direction> is undefined, uses the first field's default sort order.
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

sub format_uri_for_this {
    # B<DEPRECATED>.  Use L<format_uri|"format_uri">.
    return shift->format_uri($_QT->THIS_DETAIL, @_);
}

sub format_uri_for_this_child {
    # B<DEPRECATED>.  Use L<format_uri|"format_uri">.
    return shift->format_uri($_QT->THIS_CHILD_LIST, @_);
}

sub format_uri_for_this_page {
    # B<DEPRECATED>.  Use L<format_uri|"format_uri">.
    return shift->format_uri($_QT->THIS_LIST, @_);
}

sub get_cursor {
    return shift->[$_IDI]->{cursor};
}

sub get_hidden_field_values {
    my($self) = @_;
    #   Q: Can you say hack?
    #   I knew you could...
    #
    # Emulate L<Bivio::Biz::FormModel::get_hidden_field_values|Bivio::Biz::FormModel/"get_hidden_field_values">
    my($fields) = $self->[$_IDI];
    return $fields->{query}->get_hidden_field_values(
	    $self->internal_get_sql_support());
}

sub get_list_model {
    # Returns itself, the list model.
    return shift;
}

sub get_load_notes {
    my($self) = @_;
    # Return notes about how the query list was loaded.
    #
    # Used by Biz::Util::ListModel.
    return $self->[$_IDI]->{load_notes};
}

sub get_query {
    # Returns the
    # L<$_LQ|$_LQ>
    # associated with this list model.
    return shift->[$_IDI]->{query};
}

sub get_query_as_hash {
    my($self) = shift;
    # Same as L<format_query|"format_query"> except that it returns as an
    # (unescaped) hash, not a string.
    #
    # Returns C<undef> if the query is empty.
    # Easier to do this way than to try to modularize the code for
    # this one case.  Typical case is that the string is empty.
    # If there is one element, it's easy, too.
    my($s) = $self->format_query(@_);
    return length($s) ? Bivio::Agent::HTTP::Query->parse($s) : undef;
}

sub get_result_set_size {
    my($rows) = shift->[$_IDI]->{rows};
    # Returns the number of rows loaded.
    Bivio::Die->die('not loaded') unless $rows;
    return int(@$rows);
}

sub get_summary {
    my($self) = @_;
    _trace(ref($self)) if $_TRACE;
    return $self->use('Model.SummaryList')->new([$self]);
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub has_cursor {
    my($cursor) = shift->[$_IDI]->{cursor};
    # Returns true if there is a row loaded, i.e. cursor is non-negative
    # and defined.
    return defined($cursor) && $cursor >= 0 ? 1 : 0;
}

sub has_next {
    # Is there next page or item to this list model?
    return shift->[$_IDI]->{query}->get('has_next');
}

sub has_prev {
    # Is there prev page or item to this list model?
    return shift->[$_IDI]->{query}->get('has_prev');
}

sub internal_get_rows {
    my($self) = @_;
    # B<FOR INTERNAL USE ONLY.>
    #
    # Returns the rows associated with the query.  If the model
    # hasn't been loaded, blows up.
    return $self->[$_IDI]->{rows} || $self->die('not loaded');
}

sub internal_initialize_sql_support {
    my($proto, $stmt, $config) = @_;
    # Returns the L<Bivio::SQL::ListSupport|Bivio::SQL::ListSupport>
    # for this class.  Calls L<internal_initialize|"internal_initialize">
    # to get the hash_ref to initialize the sql support instance.
    #
    # You can create anonymous list model.  Simply supply the configuration
    # that is returned by C<internal_initialize> to new_anonymous.
    #
    # This method is complicated by the use of Bivio::SQL::Statement to build
    # the model declaration.  We call build_decl_for_sql_support to ask the
    # statement what columns are on this model.

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

    return $_LS->new(
        $proto->merge_initialize_info($decl,
	    $stmt->build_decl_for_sql_support()),
	$stmt);
}

sub internal_is_loaded {
    # Returns true if is loaded.
    return shift->is_loaded();
}

sub internal_load {
    my($self, $rows, $query) = @_;
    # B<FOR INTERNAL USE ONLY.>
    #
    # Loads the ListModel with I<rows>.
    #
    # Calls L<internal_post_load_row|"internal_post_load_row"> after
    # all the rows are loaded if I<self> implements this method.
    #
    # If I<query> is C<undef>, call L<empty_query|"empty_query">.
    $query ||= $self->empty_query;
    # Easier to just replace the hash_ref
    my($empty_properties, $load_notes) = @{$self->[$_IDI]}{
	qw(empty_properties load_notes)};
    $self->[$_IDI] = {
	rows => $rows,
	cursor => $self->RESET_CURSOR,
	query => $query,
	empty_properties => $empty_properties,
 	load_notes => $load_notes,
    };
    $self->internal_clear_model_cache;
    $self->internal_put($empty_properties);
    $self->throw_die('MODEL_NOT_FOUND')
        if $self->NOT_FOUND_IF_EMPTY && !@$rows;
    $self->put_on_request
	unless $self->is_ephemeral;
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

sub internal_load_rows {
    my($self, $query, $stmt, $where, $params, $sql_support) = @_;
    # May be overriden.  Must return the rows loaded.
    return $sql_support->load($query, $stmt, $where, $params, $self);
}

sub internal_pre_load {
    # B<DEPRECATED>, use L<internal_prepare_statement|"internal_prepare_statement">.
    return '';
}

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;
    # Passes I<stmt> so model can modify the SQL query to be generated.
    return;
}

sub internal_set_cursor {
    my($self, $cursor) = @_;
#TODO: This should be deprecated
    $self->set_cursor(defined($cursor) ? $cursor : $self->LAST_ROW);
    return;
}

sub is_empty_row {
    my($self) = @_;
    # If all primary key(s) equal EMPTY_KEY_VALUE.
    foreach my $k (@{$self->get_info('primary_key_names')}) {
	return 0 unless $self->get_field_type($k)->is_equal(
	    $self->get($k), $self->EMPTY_KEY_VALUE,
	);
    }
    return 1;
}

sub is_loaded {
    # Has load been called?
    return shift->[$_IDI]->{rows} ? 1 : 0;
}

sub iterate_next {
    # I<row> is the resultant values by field name.
    # I<converter> is optional and is the name of a
    # L<Bivio::Type|Bivio::Type> method, e.g. C<to_html>.
    #
    # B<Puts row on I<self>, but doesn't clear model cache.>
    #
    # Returns false if there is no next.
    #
    # Subclasses: Calls L<internal_post_load_row|"internal_post_load_row"> after
    # the row is loaded if I<self> implements this method.  Care must
    # be taken when using the values returned, because converter is
    # already applied.  If internal_post_load_row returns false, the row isn't
    # returned and another row is attempted.
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

sub iterate_next_and_load {
    my($self, $it) = @_;
    # Will iterate to the next row and load the model with the row.
    #
    # It appears as if the model was loaded with one row and the
    # cursor was set at 0. Do not call L<next_row|"next_row">,
    # however, or the behaviour will break, i.e. there will be
    # no cursor.
    #
    # There may only be one iteration outstanding on an instance.
    #
    # This is slower than L<iterate_next|"iterate_next">.  The
    # two routines can be used alternately.
    #
    # Returns false if there is no next.
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

sub iterate_start {
    # Begins an iteration which can be used to iterate the rows for this
    # realm with L<iterate_next|"iterate_next"> or
    # L<iterate_next_and_load|"iterate_next_and_load">.
    # L<iterate_end|"iterate_end"> should be called when you are through
    # with the iteration.
    #
    # Use this method when you need to make one pass over the data (efficiently).
    #
    # NOTE: Most ListModels cannot be iterated.  If L<can_iterate|"can_iterate">
    # returns false, this routine will die.
    #
    # Calls L<internal_prepare_statement|"internal_prepare_statement">, but
    # does not call
    # L<internal_load|"internal_load">.  See L<iterate_next|"iterate_next">
    # for semantics of row fixups.
    #
    # B<Deprecated form returns the iterator.>
    return _iterate_start('parse_query', @_);
}

sub load_all {
    my($self, $query) = @_;
    # Loads "all" the records in this realm.
    # If the return is too large, throws a I<Bivio::DieCode::TOO_MANY> exception.
    #
    # B<Does not use the query from the request.>  Does force I<auth_id>,
    # however.
    #
    # Returns I<self>.
    $query = $self->parse_query($query);
    $query->put(count => _load_all_die_count($self));
    _unauth_load($self, $query);
    _assert_all($self);
    return $self;
}

sub load_empty {
    my($self) = @_;
    $self->internal_load([], $self->parse_query({
	# Cannot be overriden value: See Type.PrimaryId
	parent_id => __PACKAGE__->EMPTY_KEY_VALUE,
    }));
    return $self;
}

sub load_page {
    my($self, $query) = @_;
    # Loads the specified page in I<query> which must be a form
    # acceptable to L<$_LQ|$_LQ>
    # unless I<query> is already a ListQuery.
    #
    # I<this> must not be specified.
    #
    # I<count> will be added to I<query> only if it is a hash_ref.
    #
    # I<auth_id> will be put in I<query> using the value in the request.
    #
    # Saves the model in the request.
    my($want_page_count) = $self->internal_get_sql_support
	->unsafe_get('want_page_count');
    $query = $self->parse_query($query)
        ->put(want_page_count => defined($want_page_count)
	    ? $want_page_count : $_CFG->{want_page_count});

    $self->throw_die('CORRUPT_QUERY', {message => 'unexpected this',
	query => $query}) if $query->unsafe_get('this');

    _unauth_load($self, $query);
    return $self;
}

sub load_this {
    my($self, $query) = @_;
    # Loads the specified I<this> in I<query> which must be a form
    # acceptable to L<$_LQ|$_LQ>
    # unless I<query> is already a ListQuery.
    #
    # I<this> must be specified.
    #
    # Dies with MODEL_NOT_FOUND if no rows are returned.
    #
    # I<count> will be added to I<query> only if it is a hash_ref.
    #
    # I<auth_id> will be put in I<query> using the value in the request.
    #
    # Saves the model in the request.
    #
    # Returns I<self> after setting cursor to the first row (0).
    return _load_this($self, $query);
}

sub load_this_or_first {
    my($self, $query) = @_;
    # Same as L<load_this|"load_this">, but if there is no I<this> on the
    # query, loads the first element in the list.  If no first element,
    # returns not found.
    #
    # Returns I<self> after setting cursor to the first row (0).
    return _load_this($self, $query, 1);
}

sub map_primary_key_to_rows {
    my($self) = @_;
    # Maps the primary key to all rows.  The primary key values are separated
    # by perl's subscript separator (C<$;>).
    my($primary_key_names)
	    = $self->internal_get_sql_support->get('primary_key_names');
    return {map {(join($;, @$_{@$primary_key_names}), $_)}
	    @{$self->internal_get_rows}};
}

sub map_rows {
    my($delegator, $map_iterate_handler) = shift->delegated_args(@_);
    my($res) = [];
    $map_iterate_handler ||= sub {
	return shift->get_shallow_copy;
    };
    $delegator->reset_cursor;
    while ($delegator->next_row) {
	push(@$res, $map_iterate_handler->($delegator));
    }
    return $res;
}

sub new {
    # Create a new ListModel associated with the request.
    return _new(shift->SUPER::new(@_));
}

sub new_anonymous {
    my(undef, $config) = @_;
    # Create a new_anonymous ListModel associated with the request.
    # Defaults version and can_iterate to 1.
    if (ref($config) eq 'HASH') {
	$config->{version} ||= 1;
	# Always can_iterate, since pure SQL
	$config->{can_iterate} = 1;
    };
    return _new(shift->SUPER::new_anonymous(@_));
}

sub next_row {
    my($self) = @_;
    # Advances the cursor to the next row and sets the properties
    # to the new row's values.  If there are no more rows, returns
    # false.
    #
    # B<Only returns false ONCE.  After that calls die.>
    my($fields) = $self->[$_IDI];
    Bivio::Die->die('no cursor') unless defined($fields->{cursor});
    $self->internal_clear_model_cache;
    if (++$fields->{cursor} >= int(@{$fields->{rows}})) {
	$fields->{cursor} = undef;
	$self->internal_put({%{$fields->{empty_properties}}});
	return 0;
    }
    $self->internal_put($fields->{rows}->[$fields->{cursor}]);
    return 1;
}

sub next_row_or_die {
    my($self) = shift;
    # Terminates unless L<next_row|"next_row"> succeeds.
    $self->throw_die('expecting next row') unless $self->next_row(@_);
    return;
}

sub parse_query {
    my($self, $query) = @_;
    # Does the processing of I<query>.  Converts to
    # L<$_LQ|$_LQ> which
    # may modify I<query> if it isn't already a ListQuery.
    #
    # See also L<parse_query_from_request|"parse_query_from_request">.
    #
    # Puts I<auth_id> and I<auth_user_id> from request on query in all cases.
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
	return $_LQ->new($query, $sql_support, $self);
    }

    # Already a list query, put auth_id on query
    $query->put(auth_id => $auth_id);
    $query->put(auth_user_id => $auth_user_id);
    return $query;
}

sub parse_query_from_request {
    my($self) = @_;
    # Parses the query from the request.  If not set, uses default query.
    my($query) = $self->get_request->unsafe_get('query');

    # Make a copy of the query, because we modify the value.
    $query = $query ? {%$query} : {};

    # Clean up the query and then parse.
    $_LQ->clean_raw($query, $self->internal_get_sql_support);
    return $self->parse_query($query);
}

sub prev_row {
    my($self) = @_;
    # Backs up the cursor to the previous row and sets the properties
    # to the new row's values.  If we are at the start, returns
    # false.
    #
    # B<Only returns false ONCE.  After that calls die.>
    my($fields) = $self->[$_IDI];
    Bivio::Die->die('no cursor') unless defined($fields->{cursor});
    $self->internal_clear_model_cache;
    if (--$fields->{cursor} < 0) {
	$fields->{cursor} = undef;
	$self->internal_put({%{$fields->{empty_properties}}});
	return 0;
    }
    $self->internal_put($fields->{rows}->[$fields->{cursor}]);
    return 1;
}

sub reset_cursor {
    my($self) = @_;
    return $self->set_cursor($self->RESET_CURSOR);
}

sub save_excursion {
    my($self, $op) = @_;
    my($old_cursor) = $self->get_cursor;
    my(@res) = $op->();
    $self->set_cursor($old_cursor)
	if defined($old_cursor);
    return wantarray ? @res : $res[0];
}

sub set_cursor {
    my($self, $index) = @_;
    # Sets the row to I<index> (starts at 0).  Returns false if
    # just after last row.  Other indices cause termination.
    #
    # Particularly useful for "this" queries.  Can check if
    # "this" loaded by calling C<set_cursor(0)>.
    #
    # I<index> may also be L<LAST_ROW|"LAST_ROW">.
    my($fields) = $self->[$_IDI];
    $self->die('not loaded')
        unless $fields->{rows};
    $self->internal_clear_model_cache;
    my($n) = int(@{$fields->{rows}});
    if ($index == $self->LAST_ROW) {
	$index = $n - 1;
	# Fall through to handle empty list case.
    }
    if ($index >= $n || $index == $self->RESET_CURSOR) {
	$self->die("$index: invalid index")
	    if $index > $n;
	$fields->{cursor} = $index == $n ? undef : $self->RESET_CURSOR;
	$self->internal_put({%{$fields->{empty_properties}}});
	return 0;
    }
    $self->die($index, ': invalid index')
	if $index < 0;
    $self->internal_put($fields->{rows}->[$fields->{cursor} = $index]);
    return 1;
}

sub set_cursor_or_die {
    my($self) = shift;
    # Calls L<set_cursor|"set_cursor"> and dies with DIE
    # if it returns false.
    #
    # Returns self.
    $self->throw_die('DIE', {message => 'no such row', entity => $_[0]})
	unless $self->set_cursor(@_);
    return $self;
}

sub set_cursor_or_not_found {
    my($self) = shift;
    # Calls L<set_cursor|"set_cursor"> and dies with NOT_FOUND
    # if it returns false.
    #
    # Returns self.
    $self->throw_die(
	'MODEL_NOT_FOUND', {message => 'no such row', entity => $_[0]},
    ) unless $self->set_cursor(@_);
    return $self;
}

sub unauth_iterate_start {
    # Begins an iteration which can be used to iterate the rows for this
    # realm with L<iterate_next|"iterate_next"> or
    # L<iterate_next_and_load|"iterate_next_and_load">.
    # L<iterate_end|"iterate_end"> should be called when you are through
    # with the iteration.
    #
    # B<Deprecated form returns the iterator.>
    return _iterate_start(unauth_parse_query => @_);
}

sub unauth_load_all {
    my($self, $query) = @_;
    # Adds in I<count> equal to L<LOAD_ALL_SIZE|"LOAD_ALL_SIZE">.
    #
    # If the return is too large, throws a I<Bivio::DieCode::TOO_MANY> exception.
    #
    # Returns I<self>.
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

sub unauth_parse_query {
    my($self, $query) = @_;
    # Does the processing of I<query>.  Converts to
    # L<$_LQ|$_LQ> which
    # may modify I<query> if it isn't already a ListQuery.
    return UNIVERSAL::isa($query, '$_LQ') ? $query
	: $_LQ->unauth_new(
	    $query || {}, $self->internal_get_sql_support, $self);
}

sub unsafe_load_this {
    my($self, $query) = @_;
    # Loads the specified I<this> in I<query> which must be a form
    # acceptable to L<$_LQ|$_LQ>
    # unless I<query> is already a ListQuery.
    #
    # I<this> must be specified.
    #
    # Does not die if this is not found.  (Does die if this is too_many.)
    return _load_this($self, $query, 0, 1) ? 1 : 0;
}

sub unsafe_load_this_or_first {
    my($self, $query) = @_;
    return _load_this($self, $query, 1, 1) ? 1 : 0;
}

sub _assert_all {
    my($self) = @_;
    # Throws an exception if there are too many rows returned.
    my($fields) = $self->[$_IDI];
    $self->throw_die(Bivio::DieCode->TOO_MANY, 'more than '
        . _load_all_die_count($self) . ' records')
        if $fields->{query}->get('has_next');
    Bivio::IO::Alert->warn('more than ', $self->LOAD_ALL_SIZE,
        ' records returned: ', $self)
        if $self->get_result_set_size > $self->LOAD_ALL_SIZE;
    return;
}

sub _format_uri_args {
    my($self, $type, $uri, $query_args) = @_;
    # Returns ($self, $type, $uri, $query_args, $req) from the arguments.
    my($req) = $self->get_request;

    # Convert to enum unless already converted
    $type = $_QT->from_name($type) unless ref($type);

    Bivio::Die->die('query_args ', $query_args, ' not allowed for ', $type)
	    if $query_args && $type != $_QT->THIS_LIST;

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

sub _load_all_die_count {
    my($self) = @_;
    # Returns the number of rows for LOAD_ALL where load_all() will die()
    # rather than warn().
    return $self->LOAD_ALL_SIZE * $_LOAD_ALL_DIE_FACTOR;
}

sub _load_this {
    my($self, $query, $first_only, $not_found_ok) = @_;
    # Loads this or first.  Sets cursor to 0.
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

sub _new {
    my($self) = @_;
    # Finishes instantiation.
    # NOTE: fields are dynamically replaced.  See, e.g. load.
    $self->[$_IDI] = {
	empty_properties => {%{$self->internal_get}},
	load_notes => '',
    };
    return $self;
}

sub _statement {
    my($self) = @_;
    # Gather changes from internal_prepare_statment and internal_pre_load
    my($stmt) = Bivio::SQL::Statement->new();
    $self->internal_prepare_statement($stmt, $self->get_query());
    return $stmt;
}

sub _unauth_load {
    my($self, $query) = @_;
    # Loads the model without forcing I<auth_id>.  Resets load_notes.
    #
    # I<attrs> is not the same as I<query> of L<load|"load">.  I<attrs> is
    # passed to
    # L<$_LQ::unauth_new|$_LQ/"unauth_new">,
    # while I<query> is L<$_LQ::new|$_LQ/"new">.
    # B<Use the full names of ListQuery attributes.>
    #
    # I<count> will be set to L<PAGE_SIZE|"PAGE_SIZE"> if defined,
    # or the user preference for page_size.  Otherwise, PageSize->get_default.
    #
    # Returns count of rows loaded.
    my($fields) = $self->[$_IDI];
    $fields->{load_notes} =  '';
    my($sql_support) = $self->internal_get_sql_support;

    # Convert to listQuery
    $query = $_LQ->unauth_new($query, $sql_support, $self)
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

sub _where_and_params {
    my($self) = @_;
    # Gather changes from internal_prepare_statment and internal_pre_load
    my($params) = [];
    my($where) = $self->internal_pre_load(
	$self->get_query(),
	$self->internal_get_sql_support(),
	$params,
    );
    return ($where, $params);
}

1;
