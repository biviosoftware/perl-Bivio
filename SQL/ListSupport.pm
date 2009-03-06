# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::SQL::ListSupport;
use strict;
use Bivio::Base 'Bivio::SQL::Support';
use Bivio::Biz::PropertyModel;
use Bivio::IO::Trace;
use Bivio::SQL::Connection;
use Bivio::Type::Date;
use Bivio::Type::PrimaryId;

# C<Bivio::SQL::ListSupport> provides SQL database access for
# L<Bivio::Biz::ListModel>s.  The loading specification is defined
# by L<Bivio::SQL::ListQuery|Bivio::SQL::ListQuery>.
#
# ListSupport uses the L<Bivio::SQL::Connection> for statement execution.
#
# A field is a name of the form C<Model.field>.
#
# A field identity is an array_ref of fields.  The first field is the
# name that appears in the columns list.  The rest are aliases which
# are joined in the where clause with "=".
#
# Outer joins are supported for field identities.  An alias may end
# with '(+)'.
#
#
# See also L<Bivio::SQL::Support|Bivio::SQL::Support> for more attributes.
#
#
# auth_id : array_ref
#
# auth_id : string
#
# A field or field identity which must be equal to
# request's I<auth_id> attribute.
#
# auth_user_id : array_ref
#
# auth_user_id : string
#
# A field or field identity which must be equal to
# request's I<auth_user_id> attribute.
#
# can_iterate : boolean [0]
#
# By default lists can't be iterated.  If you set this to true, you can
# iterate.
#
# count_distinct : array_ref
#
# The column to be used in the COUNT(DISTINCT x) query.
#
# date : array_ref
#
# date : string
#
# Date qualification field, used to qualify queries.
#
# from : string
#
# Optionally override the FROM clause.  Use this feature with caution.
#
# group_by : array_ref
#
# Optionally, a list of fields and field identities that can be used
# to group the result.
#
# other : array_ref
#
# A list of fields and field identities that have no ordering.
#
# other_query_keys : array_ref
#
# Extra keys expected on the query.  Used by L<clean_raw|"clean_raw">.
#
# order_by : array_ref
#
# A list of fields and field identities that can be used to sort
# the result.
#
# order_by_names : array_ref
#
# List of columns order_by columns (in order).
#
# orabug_fetch_all_select : boolean
#
# If set, then selects must be read to completion.  We were seeing ORA-03113
# because the oracle slave was crashing with a SEGV
# on the test system only.  It isn't happening any more.  We don't know
# why, but we've taken it out of RealmUserList.  I've left the code in,
# because it may need to be added quickly.  Just add it to internal_initialize
# of the list model, e.g.
#
#     # This select causes the oracle db slave to crash.  The next
#     # operation fails.  See ListSupport for more details.
#     orabug_fetch_all_select => 1,
#
# parent_id : array_ref
#
# parent_id : string
#
# A field or field identity which further qualifies a query.
# Used when a list "this" points to another list, e.g.
# InstrumentSummaryList leads the user to InstrumentTransactionList.
#
# parent_id_type : string
#
# The type class of the parent_id field.
#
# primary_key : array_ref (required)
#
# The list of fields and field that uniquely identifies a row.
#
# primary_key_types : array_ref
#
# List of primary key types in the order of I<primary_key_names>.
#
# select_value : string
#
# The raw SQL to be substituted into the SQL query for the column.
#
# version : int
#
# The version of this particular combination of fields.  It will be
# set in all query strings.  It should be changed whenever the
# declaration changes.  It is used to reject an out-dated query.
#
# want_date : boolean [0]
#
# #TODO: It may make sense to just use the "date" field.
#
# want_select : boolean [1]
#
# Is this going to be in the select?  If false, like setting
# in_select to false for all columns.
#
# want_select_distinct : boolean [0]
#
# Use SELECT DISTINCT instead of SELECT.
#
# want_level_in_select : boolean [0]
#
# Add C<LEVEL> to the select.  This is an Oracle specific field.
# It is used with C<CONNECT BY>.
#
# want_page_count : boolean [Bivio::Biz::ListModel want_page_count]
#
# Should the number of pages be calculated for this list if paged?
#
# where : array_ref
#
# A list of fields which will be ANDed to rest of the where clause.
# If an element matches a column_name or alias, then the appropriate
# sql_name for the column_name or alias will be substituted.
#
#
#
# The following declaration is taken from
# L<Bivio::Biz::Model::ClubUserList|Bivio::Biz::Model::ClubUserList>:
#
#     Bivio::SQL::ListSupport->new({
# 	version => 1,
# 	order_by => [qw(
#             RealmOwner.name
#             ClubUser.mail_mode
#             RealmUser.role
# 	)],
# 	other => [qw(
# 	    User.last_name
# 	    User.middle_name
# 	    User.first_name
# 	)],
# 	primary_key => [
# 	    [qw(User.user_id ClubUser.user_id RealmOwner.realm_id
#                 RealmUser.user_id)],
# 	],
# 	auth_id => [qw(ClubUser.club_id RealmUser.realm_id)],
#     });
#
# This declaration will produce the following properties:
#
#     User.last_name
#     RealmOwner.name
#     ClubUser.mail_mode
#     RealmUser.role
#     User.user_id
#     ClubUser.club_id
#
# This is the first version.  Any time the field names change, you should change
# the version.  Field identities do not affect the version, because they do not
# affect the external representation, just the implementation of the query.
#
# You can order this model by I<RealmOwner.name>, I<ClubUser.mail_mode>, or
# I<RealmUser.role>.  While it may not make the most sense to order by
# I<ClubUser.mail_mode>, it is allowed and "why not?".
#
# The I<User.user_id> and its aliases
# I<ClubUser.user_id>, I<RealmOwner.realm_id>, and I<RealmUser.user_id>,
# is the C<primary_key> for this ListSupport.  It is guaranteed to be
# unique to each row of the ListSupport.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_PRIMARY_ID_SQL_VALUE) = Bivio::Type::PrimaryId->to_sql_value('?');
my($_DATE_SQL_VALUE) = Bivio::Type::Date->to_sql_value('?');
my($_CONSTANT_COLS) = [qw(auth_id auth_user_id parent_id)];

sub get_statement {
    my($self) = @_;
    # Return the statement for this instance.
    return $self->internal_get()->{statement};
}

sub iterate_next {
    my($self) = shift;
    return 0
	unless $self->SUPER::iterate_next(@_);
    my($model, $iterator, $row, $converter) = @_;
    _add_constant_values($self, $model->get_query, $row, $converter);
    return 1;
}

sub iterate_start {
    # Returns a handle which can be used to iterate the rows with
    # L<iterate_next|"iterate_next">.  L<iterate_end|"iterate_end">
    # should be called, too.
    #
    # Arguments are the same as L<load|"load">.
    return _execute_select(@_);
}

sub load {
    my($self, $query, $stmt, $where, $params, $die) = @_;
    # Loads the specified rows with data using the parameterized where_clause
    # and substitution values. At most the specified max rows will be loaded.
    # Data will be loaded starting at the specified index into the result set.
    #
    # I<where> is added to the internally generated select with I<params>.
    #
    # If I<want_this> or I<this> is set, only loads one element.

    # If no select such just return an empty list.  Only local fields.
    return [] unless _select($self);

    # Detail or list?
    return $query->get('this') || $query->unsafe_get('want_first_only')
	    ? _load_this($self, $query, _execute_select(@_), $die)
	    : _load_list(@_);
}

sub new {
    my($proto, $decl, $stmt) = @_;
    # Creates a SQL list support instance from a declaration.  A I<decl> is a list of
    # keyed categories.  The keys are described below.  The values are either an
    # array_ref or a string (except I<version>).  The array_ref may contain strings
    # (fields) or array_refs of strings (field identities).  A field is composed of a
    # table qualifier and the column name.  The first field in a field identity is
    # a property.  The others are supplied for the I<WHERE> clause.
    #
    # The table qualifier is the table name with the trailing I<t> replaced by
    # a digit.  The digits start at I<1>.
    #
    # The types of the columns will be extracted from the property
    # models corresponding to the table names.
    my($attrs) = {
	statement => $stmt,
	# All columns by qualified name
	columns => {},
	# All models by qualified name
	models => {},
	# All fields and field identities by qualified name
	column_aliases => {},
	# The columns returned by select in order (not including auth_id)
	select_columns => [],
	# Columns which have no corresponding property model field
	local_columns => [],
	# See discussion of =item orabug_fetch_all_select
	orabug_fetch_all_select => $decl->{orabug_fetch_all_select},
	# Default is false
	map({
	    $_ => $decl->{$_} ? 1 : 0;
	} qw(can_iterate want_date)),
	# Default is true
	want_select => !defined($decl->{want_select}) || $decl->{want_select}
	         ? 1 : 0,
	other_query_keys => !defined($decl->{other_query_keys})
	    || ref($decl->{other_query_keys}) eq 'ARRAY'
	    ? $decl->{other_query_keys}
	    : Bivio::Die->die(
		$decl->{other_query_keys}, ': invalid other_query_keys'),
	want_page_count => $decl->{want_page_count},
    };
    $proto->init_common_attrs($attrs, $decl);

    # We add this to the declaration in the case that 
    if ($decl->{want_level_in_select}) {
	$decl->{other} = [] unless ref($decl->{other});
	push(@{$decl->{other}},
	    {
		name => 'level',
		type => 'Integer',
		constraint => 'NOT_NULL',
		in_select => 1,
	    },
	);
    }

    _init_column_lists($attrs, $decl, _init_column_classes($attrs, $decl));
    my($self) = $proto->SUPER::new($attrs);
    Bivio::SQL::ListQuery->initialize_support($self);
#TODO: make $self read_only?
    return $self;
}

sub _add_constant_values {
    my($self, $query, $row, $converter) = @_;
    my($attrs) = $self->internal_get;
    _map_constant_cols(sub {
        my($f) = @_;
	return
	    unless my $i = $self->unsafe_get($f);
	my($v) = $query->unsafe_get($f);
	$row->{$i->{name}} = $converter ? $i->{type}->$converter($v) : $v;
	return;
    });
    return $row;
}

sub _count_pages {
    my($self, $query, $from_where, $params) = @_;
    # Sets page_count and adjusts page_number.  Returns page_count.
    my($statement) = Bivio::SQL::Connection->execute(
	$self->get('select_count') . ' ' . $from_where, $params);
    my($row_count) = $statement->fetchrow_array;
    my($page_count) = _page_number($query, $row_count);
    my($page_number) = $query->get('page_number');
    _trace('page_count=', $page_count) if $_TRACE;
    if ($page_number > $page_count) {
	_trace('page_number (',  $page_number, ') > count') if $_TRACE;
	$query->put(page_number => $page_number = $page_count);
    }
    $query->put(page_count => $page_count, row_count => $row_count);
    return $page_count;
}

sub _execute_select {
    # Prepare and execute the select statement.
    return Bivio::SQL::Connection->execute((_prepare_statement(@_))[0,1]);
}

sub _find_list_start {
    my($self, $query, $sql, $params, $die) = @_;
    # Returns $rows and $statement after finding first row to return.
    my($db) = Bivio::SQL::Connection->get_instance;
    my($statement, $row);
    my($page_number, $count) = $query->get(qw(page_number count));
    my($can_limit_and_offset) = $db->CAN_LIMIT_AND_OFFSET;
    foreach my $is_second_try (0 .. 1) {
	# Set prev first, because there is a return in the for loop
	if ($page_number > $query->FIRST_PAGE) {
	    $query->put(has_prev => 1, prev_page => $page_number - 1);
	}
	else {
	    $query->put(has_prev => 0, prev_page => undef,
		# Avoids problems if page_number is negative
		page_number => ($page_number = $query->FIRST_PAGE));
	}
	if ($can_limit_and_offset) {
	    # We always get one more, so has_next works
	    $statement = $db->execute(
		$sql . sprintf(' OFFSET %d LIMIT %d',
		    ($page_number - 1) * $count, $count + 1),
		 $params);
	    return ($row, $statement)
		if $row = $statement->fetchrow_arrayref;
	    $statement->finish;
	    return (undef, undef)
		if $is_second_try || $page_number == $query->FIRST_PAGE;
	    $can_limit_and_offset = 0;
	}
	# No LIMIT/OFFSET, so go through rows serially
	my($start) = ($page_number - $query->FIRST_PAGE()) * $count;
#TODO: Is this needed?  $count has to be > 0, no?
	$start = 0 if $start < 0;
	$statement = $db->execute($sql, $params);
	my($num_rows) = 0;

	0 while $row = $statement->fetchrow_arrayref and ++$num_rows <= $start;
	return ($row, $statement)
	    if $row;
	$statement->finish;
	unless ($num_rows) {
	    _trace('no rows found') if $_TRACE;
	    return (undef, undef);
	}
	$query->put(page_number =>
	    $page_number = _page_number($query, $num_rows));
    }
    continue {
	_trace('last page=', $page_number, ', retrying') if $_TRACE;
    }
    ($die || 'Bivio::Die')->throw_die('DB_ERROR', {
	message => 'unable to find page in list',
	page_number => $page_number,
	where => $sql,
	params => $params,
    });
    # DOES NOT RETURN
}

sub _init_column_classes {
    my($attrs, $decl) = @_;
    # Initialize the column classes.
    # Returns the beginnings of the where clause
    my($where) = __PACKAGE__->init_column_classes($attrs, $decl,
	[@$_CONSTANT_COLS,
	qw(date primary_key order_by group_by other count_distinct)]);

    if ($decl->{where}) {
	my(@decl_where) = ();
	foreach my $e (@{$decl->{where}}) {
	    if (defined($attrs->{column_aliases}->{$e})) {
		push(@decl_where, $attrs->{column_aliases}->{$e}->{sql_name});
	    }
	    elsif (defined($attrs->{models}->{$e})) {
#TODO: This doesn't work for qualified columns, but it works for
#      what I need right now.
		push(@decl_where, $attrs->{models}->{$e}->{sql_name});
	    }
	    else {
		push(@decl_where, $e);
	    }
	}
	$where = join(' AND ', grep($_, $where, join(' ', @decl_where)));
    }
    foreach my $c (@$_CONSTANT_COLS, qw(date count_distinct)) {
	Bivio::Die->die("too many $c fields")
	    if @{$attrs->{$c}} > 1;
	$attrs->{$c} = $attrs->{$c}->[0];
    }
    # order_by may be empty and stays in specified order.
    my($i) = 0;
    foreach my $c (@{$attrs->{order_by}}) {
	$c->{order_by_index} = $i++;
    }
    return undef
	unless %{$attrs->{models}} && $attrs->{want_select};

    # primary_key must be at least one column if there are models.
    Bivio::Die->die('no primary_key fields')
        unless @{$attrs->{primary_key}} || !%{$attrs->{models}};
    # Sort all names in a select alphabetically.
    $attrs->{primary_key} = [sort {$a->{name} cmp $a->{name}}
	@{$attrs->{primary_key}}];

    # other can be empty.  No reformatting necessary

    # Ensure that (qual) columns defined for all (qual) models and their
    # primary keys and initialize primary_key_map.
    __PACKAGE__->init_model_primary_key_maps($attrs);

    return $where;
}

sub _init_column_lists {
    my($attrs, $decl, $where) = @_;
    # Creates many of the lists in $attrs which are derived from the class
    # lists (primary_key, order_by).  Creates select and select_this
    # using "where" of field identities and column information already in $attrs
    # only if "where" is defined (see _init_column_classes).

    # Lists are sorted to keep Oracle's cache happy across invocations
    $attrs->{primary_key_names} = [map {$_->{name}} @{$attrs->{primary_key}}];
    $attrs->{primary_key_types} = [map {$_->{type}} @{$attrs->{primary_key}}];
    # order_by can't be sorted, because order is important
    $attrs->{order_by_names} = [map {$_->{name}} @{$attrs->{order_by}}];
    $attrs->{column_names} = [sort(keys(%{$attrs->{columns}}))];

    if ($attrs->{parent_id}) {
	$attrs->{parent_id_type} = $attrs->{parent_id}->{type};
    }
    foreach my $c (values(%{$attrs->{columns}})) {
	Bivio::Die->die($c->{name}, ': cannot have a blob in a ListModel')
	    if $c->{type} eq 'Bivio::Type::BLOB';
    }

    # Nothing to select
    return unless defined($where);

    # Order select columns alphabetically, ignoring primary_key, primary_id
    # and auth_id and any other columns with in_select turned off.
    my(@sel_cols) =
	sort {$a->{name} cmp $b->{name}}
	(grep($_->{in_select}, values(%{$attrs->{columns}})));

    # Go through the list and delete cols we don't return or in the
    # case of the primary key, what we return first.  Yes, this probably
    # could be done in one giant grep, but better to get right than
    # tricky. <g>
    foreach my $col (
	@{$attrs->{primary_key}},
	_map_constant_cols(sub {
	    my($x) = $attrs->{shift(@_)};
	    return $x ? $x : ();
	}),
    ) {
	@sel_cols = grep($_ ne $col, @sel_cols);
    }

    # Put primary key back on front, if it is part of select
    $attrs->{can_load_this} = 1;
    unshift(@sel_cols,
	grep($_->{in_select} || ($attrs->{can_load_this} = 0),
	    @{$attrs->{primary_key}}));
    $attrs->{select_columns} = \@sel_cols;

    # Get names and set select_index
    my($i) = 0;
    my(@select_sql_names) = map {
	$_->{select_index} = $i++;
        $_->{select_value} || $_->{type}->from_sql_value($_->{sql_name});
    } @{$attrs->{select_columns}};

    # Create select from all columns
    $attrs->{decl_from} = $decl->{from};
    $attrs->{sql_from} = ' ' . (
	$decl->{from}
	|| 'FROM '. join(',',
	    sort(map($_->{model_from_sql}, values(%{$attrs->{models}}))))
    );
    $where =~ s/^\s*AND\s+//i;
    $attrs->{sql_where} = $where;

    my($select) = ($decl->{want_select_distinct} ? 'DISTINCT ' : '')
        . join(',', @select_sql_names);
    my($select_count) = $decl->{want_select_distinct}
	? $attrs->{count_distinct}
	    ? 'DISTINCT ' . $attrs->{count_distinct}->{sql_name}
	    : $select
	: '*';
    $attrs->{select} = "SELECT $select";
    $attrs->{select_count} = "SELECT COUNT($select_count)";
    return;
}

sub _load_list {
    my($self, $query, undef, undef, undef, $die) = @_;
    my($sql, $params, $from_where) = _prepare_statement(@_);
    _count_pages($self, $query, $from_where, $params)
	if $from_where && $query->unsafe_get('want_page_count');
    my($attrs) = $self->internal_get;
    my($count) = $query->get('count');
    my($row, $statement)
	= _find_list_start($self, $query, $sql, $params, $die);
    return []
	unless $row;
    my($select_columns) = $attrs->{select_columns};
    my(@rows);
    for (;;) {
	my($i) = 0;
	push(@rows, _add_constant_values($self, $query, {
	    (map {
		($_->{name}, $_->{type}->from_sql_column($row->[$i++]));
	    } @$select_columns),
	}));
	last
	    if --$count <= 0;
	unless ($row = $statement->fetchrow_arrayref) {
	    $statement->finish;
	    return \@rows;
	}
    }

    # Is there a next?
    if ($statement->fetchrow_arrayref) {
	$query->put(has_next => 1,
	    next_page => $query->get('page_number') + 1);
	# See discussion of =item orabug_fetch_all_select
	if ($attrs->{orabug_fetch_all_select}) {
	    0 while $statement->fetchrow_arrayref;
	}
    }
    $statement->finish();

    # Return the page
    return \@rows;
}

sub _load_this {
    my($self, $query, $statement, $die) = @_;
    # Load "this" from statement.  We search serially through all records.
    # There doesn't appear to be a better way to do this, because we need
    # to know "prev".  Eventually, this will have to be PL/SQL.
    my($attrs) = $self->internal_get;
    $die->throw_die('DIE', 'cannot load this, primary key must be in_select')
	unless $attrs->{can_load_this};
    my($count, $this) = $query->get(qw(count this));
    my($want_first) = $query->unsafe_get('want_first_only');
    _trace($want_first ? 'looking for first'
	: ('looking for this ', $attrs->{primary_key_names}, ' = ', $this))
	if $_TRACE;
    my($types) = $attrs->{primary_key_types};
    my($prev, $row);
    my($row_count) = 0;
    for (;;) {
	$statement->finish(), return []
		unless $row = $statement->fetchrow_arrayref;
	$row_count++;

	# Convert the entire primary key and save in $prev if no match
	my($j) = 0;
	my($match) = 1;
	my(@prev) = map {
	    my($v) = $_->from_sql_column($row->[$j]);
#TODO: Should this be "is_equal"?  This is probably "good enough".
#      It will slow it down a lot to make a method call for each
#      row/attribute.  "eq" works in all cases and probably in future.
	    $match &&= $want_first || $this->[$j] eq $v;
	    $j++;
	    $v;
	} @$types;
	if ($want_first) {
	    $query->put(this => $this = \@prev);
	    _trace('found first ', $attrs->{primary_key_names}, ' = ', \@prev)
		    if $_TRACE;
	    last;
	}
	last if $match;
	$prev = \@prev;
    }

    # Found it, copy all columns of this
    _trace('found this at row #', $row_count) if $_TRACE;
    my($i) = 0;
    my($rows) = [_add_constant_values($self, $query, {
	(map {
	    ($_->{name}, $_->{type}->from_sql_column($row->[$i++]));
	} @{$attrs->{select_columns}}),
    })];

    # Set prev if defined
    $query->put(prev => $prev, has_prev => 1) if $prev;

    # Set next if more rows
    my($next) = $statement->fetchrow_arrayref;
    if ($next) {
	my($j) = 0;
	$query->put(has_next => 1,
		next => [map {
		    $_->from_sql_column($row->[$j++]);
		} @$types]);
	# See discussion of =item orabug_fetch_all_select
	if ($attrs->{orabug_fetch_all_select}) {
	    0 while $statement->fetchrow_arrayref;
	}
    }
    $statement->finish;

    # Which page are we on?
    $query->put(page_number => _page_number($query, $row_count));
    return $rows;
}

sub _map_constant_cols {
    my($op) = @_;
    return map($op->($_), @$_CONSTANT_COLS);
}

sub _merge_where {
    my($self, $_where) = @_;
    # Merge any internal, literal where predicates with where clause
    #   returned by internal_pre_load
    return $_where
	unless $self->unsafe_get('sql_where');
    _trace('sql_where: ', $self->get('sql_where'));
    return join(' AND ', grep($_, $self->get('sql_where'), $_where));
}

sub _page_number {
    my($query, $num_rows) = @_;
    # Returns the page number that $num_rows is on.
    return int(--$num_rows/$query->get('count')) + $query->FIRST_PAGE();
}

sub _prepare_ordinal_clauses {
    my($self, $query) = @_;
    # Generates the order_by and group_by clauses.
    my($attrs) = $self->internal_get;
    my($res) = '';
    $res .= ' GROUP BY '
	. join(
	    ',',
	    map($_->{type}->to_group_by_value($_->{sql_name}),
		@{$attrs->{group_by}}),
	)
        if @{$attrs->{group_by}};
    my($qob);
    if (@{$attrs->{order_by}} and $qob = $query->get('order_by') and @$qob) {
	my $max_i = $query->unsafe_get('want_only_one_order_by') ? 2 : @$qob;
        $res .= ' ORDER BY';
        for (my($i) = 0; $i < $max_i; $i += 2) {
	    my($c) = $attrs->{columns}->{$qob->[$i]};
	    $res .= ' '
		. $c->{type}->to_order_by_value($c->{sql_name})
	        . ($qob->[$i+1] ? ',' : ' desc,');
	}
	chop($res);
    }
    _trace('group_by/order_by: ', $res);
    return $res;
}

sub _prepare_query_values {
    my($self, $stmt, $query) = @_;
    _map_constant_cols(sub {
        my($col) = @_;
	if (defined(my $v = $query->unsafe_get($col))) {
	    $stmt->where([$self->get($col)->{name}, [$v]]);
	}
	return;
    });
    if ($self->unsafe_get('date')) {
	my($begin_date, $interval, $end_date)
	    = $query->get(qw(begin_date interval date));
	unless ($end_date || $begin_date) {
	    b_warn($interval, ': interval but no date, ignoring; ', $query)
		if $interval;
	}
	else {
	    # Won't have both a begin_date and interval (see ListQuery)
	    $begin_date = $interval->dec($end_date)
		if $interval;
	    $stmt->where($stmt->GTE($self->get('date')->{name}, [$begin_date]))
		    if $begin_date;
	    $stmt->where($stmt->LTE($self->get('date')->{name}, [$end_date]))
		    if $end_date;
	}
    }
    return;
}

sub _prepare_statement {
    my($self, $query, $stmt, $_where, $_params, $die) = @_;
    _trace('_where: ', $_where);
    $stmt ||= Bivio::SQL::Statement->new;
    _prepare_query_values($self, $stmt, $query);
    my($where, $params) = $stmt->build_for_list_support_prepare_statement(
        $self, $self->get('statement'), _merge_where($self, $_where),
	$_params);

    _trace('where: ', $where);
    return ($where . _prepare_ordinal_clauses($self, $query), $params, undef)
	if $where =~ s/^WHERE SELECT\b/SELECT/;

    ($die || 'Bivio::Die')->throw_die('DIE', 'must support select')
	unless my $select = _select($self);

    my(@from_where) = ();
    # if $where has a FROM clause, ignore $sql_from
    #   otherwise, append $where to $sql_from
    unless ($where && $where =~ /^\s*FROM/is) {
	push(@from_where, $self->get('sql_from'));
    }
    push(@from_where, $where);

    return (
        join(' ', $select, @from_where,
	    _prepare_ordinal_clauses($self, $query)),
	$params,
        join(' ', @from_where)
    );
}

sub _select {
    my($self) = @_;
    # Ask statement to build select string. 
    return $self->get_statement()
	->build_select_for_sql_support($self);
}

1;
