# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::SQL::ListSupport;
use strict;
$Bivio::SQL::ListSupport::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::SQL::ListSupport - sql support for ListModels

=head1 SYNOPSIS

    use Bivio::SQL::ListSupport;
    Bivio::SQL::ListSupport->new($decl);

=cut

=head1 EXTENDS

L<Bivio::SQL::Support>

=cut

use Bivio::SQL::Support;
@Bivio::SQL::ListSupport::ISA = ('Bivio::SQL::Support');

=head1 DESCRIPTION

C<Bivio::SQL::ListSupport> provides SQL database access for
L<Bivio::Biz::ListModel>s.  The loading specification is defined
by L<Bivio::SQL::ListQuery|Bivio::SQL::ListQuery>.

ListSupport uses the L<Bivio::SQL::Connection> for statement execution.

=head1 ATTRIBUTES

See also L<Bivio::SQL::Support|Bivio::SQL::Support> for more attributes.

=over 4


The categories:

=over 4

=item auth_id : array_ref (required)

=item auth_id : string (required)

A field or field identity which must be equal to
request's I<auth_id> attribute.

=item other : array_ref

A list of fields and field identities that have no ordering.

=item order_by : array_ref

A list of fields and field identities that can be used to sort
the result.

=item order_by_names : array_ref

List of columns order_by columns (in order).

=item orabug_fetch_all_select : boolean

If set, then selects must be read to completion.  We were seeing ORA-03113
because the oracle slave was crashing with a SEGV
on the test system only.  It isn't happening any more.  We don't know
why, but we've taken it out of RealmUserList.  I've left the code in,
because it may need to be added quickly.  Just add it to internal_initialize
of the list model, e.g.

    # This select causes the oracle db slave to crash.  The next
    # operation fails.  See ListSupport for more details.
    orabug_fetch_all_select => 1,

=item parent_id : array_ref

=item parent_id : string

A field or field identity which further qualifies a query.
Used when a list "this" points to another list, e.g.
InstrumentSummaryList leads the user to InstrumentTransactionList.

=item primary_key : array_ref (required)

The list of fields and field that uniquely identifies a row.

=item primary_key_types : array_ref

List of primary key types in the order of I<primary_key_names>.

=item version : int

The version of this particular combination of fields.  It will be
set in all query strings.  It should be changed whenever the
declaration changes.  It is used to reject an out-dated query.

=item want_level_in_select : boolean

Add C<LEVEL> to the select.  This is an Oracle specific field.
It is used with C<CONNECT BY>.

=item where : array_ref

A list of fields which will be ANDed to rest of the where clause.
If an element matches a column_name or alias, then the appropriate
sql_name for the column_name or alias will be substituted.

=back

=head1 EXAMPLE

The following declaration is taken from
L<Bivio::Biz::Model::ClubUserList|Bivio::Biz::Model::ClubUserList>:

    Bivio::SQL::ListSupport->new({
	version => 1,
	order_by => [qw(
            RealmOwner.name
            ClubUser.mail_mode
            RealmUser.role
	)],
	other => [qw(
	    User.last_name
	    User.middle_name
	    User.first_name
	)],
	primary_key => [
	    [qw(User.user_id ClubUser.user_id RealmOwner.realm_id
                RealmUser.user_id)],
	],
	auth_id => [qw(ClubUser.club_id RealmUser.realm_id)],
    });

This declaration will produce the following properties:

    User.last_name
    RealmOwner.name
    ClubUser.mail_mode
    RealmUser.role
    User.user_id
    ClubUser.club_id

This is the first version.  Any time the field names change, you should change
the version.  Field identities do not affect the version, because they do not
affect the external representation, just the implementation of the query.

You can order this model by I<RealmOwner.name>, I<ClubUser.mail_mode>, or
I<RealmUser.role>.  While it may not make the most sense to order by
I<ClubUser.mail_mode>, it is allowed and "why not?".

The I<User.user_id> and its aliases
I<ClubUser.user_id>, I<RealmOwner.realm_id>, and I<RealmUser.user_id>,
is the C<primary_key> for this ListSupport.  It is guaranteed to be
unique to each row of the ListSupport.

The I<ClubUser.club_id> and its alias I<RealmUser.realm_id> must
be equal to the C<auth_id> of the
L<Bivio::Agent::Request|Bivio::Agent::Request>.  This ensures
data security, i.e. a user can't hack the request to get by this.
The user cannot set the C<auth_id>.

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::Biz::PropertyModel;
use Bivio::SQL::Connection;
use Bivio::Type::PrimaryId;
use Bivio::Util;
use Carp ();

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PRIMARY_ID_SQL_VALUE) = Bivio::Type::PrimaryId->to_sql_value('?');

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref decl) : Bivio::SQL::ListSupport

Creates a SQL list support instance from a declaration.  A I<decl> is a list of
keyed categories.  The keys are described below.  The values are either an
array_ref or a string (except I<version>).  The array_ref may contain strings
(fields) or array_refs of strings (field identities).  A field is composed of a
table qualifier and the column name.  The first field in a field identity is
a property.  The others are supplied for the I<WHERE> clause.

The table qualifier is the table name with the trailing I<t> replaced by
a digit.  The digits start at I<1>.

The types of the columns will be extracted from the property
models corresponding to the table names.

=cut

sub new {
    my($proto, $decl) = @_;
    my($attrs) = {
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
    };
    $proto->init_version($attrs, $decl);

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

    _init_column_lists($attrs, _init_column_classes($attrs, $decl));
    my($self) = Bivio::SQL::Support::new($proto, $attrs);
    Bivio::SQL::ListQuery->initialize_support($self);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="load"></a>

=head2 load(Bivio::SQL::ListQuery query, string where, array_ref params, ref die) : array_ref

Loads the specified rows with data using the parameterized where_clause
and substitution values. At most the specified max rows will be loaded.
Data will be loaded starting at the specified index into the result set.

I<where> is added to the internally generated select with I<params>.

=cut

sub load {
    my($self, $query, $where, $params, $die) = @_;
    my($select) = $self->unsafe_get('select');
    # If no select such just return an empty list.  Only local fields.
    return [] unless $select;
    $select .= $where;
    my($statement) = _execute_select($self, $query, \$select, $params, $die);
    return $query->get('this')
	    ? _load_this($self, $query, $statement, $die)
		    : _load_list($self, $query, $statement, $select, $params);
}

#=PRIVATE METHODS

# _execute_select(Bivio::SQL::ListSupport self, Bivio::SQL::ListQuery query, string_ref select, array_ref params) : DBI::Statement
#
# Create and execute the select statement based on query, auth_id, and
# parent_id.  Assumes select takes an "auth_id" as the first element and
# "parent_id" as second element (if defined), so unshifts onto "params" instead
# of pushing.
#
sub _execute_select {
    my($self, $query, $select, $params, $die) = @_;
    my($attrs) = $self->internal_get;

    # Insert parent_id and auth_id
    my($parent_id, $qob) =  $query->get('parent_id', 'order_by');
    unshift(@$params, Bivio::Type::PrimaryId->to_sql_param($parent_id))
	    if $attrs->{parent_id};
    unshift(@$params, Bivio::Type::PrimaryId->to_sql_param(
	    $query->get('auth_id')))
	    if $attrs->{auth_id};

    # Formats order_by clause if there are order_by columns
    if (@{$attrs->{order_by}}) {
	my($columns) = $attrs->{columns};
	$$select .= ' order by';
	for (my($i) = 0; $i < int(@$qob); $i += 2) {
	    # Append to order_by (name, order)
	    $$select .= ' '.$columns->{$qob->[$i]}->{sql_name}
		    .($qob->[$i+1] ? ',' : ' desc,');
	}
	# Remove trailing comma
	chop($$select);
    }

    # Execute the query
    return Bivio::SQL::Connection->execute($$select, $params);
}

# _init_column_classes(hash_ref attrs, hash_ref decl) : string
#
# Initialize the column classes.
# Returns the beginnings of the where clause
#
sub _init_column_classes {
    my($attrs, $decl) = @_;
    my($where) = __PACKAGE__->init_column_classes($attrs, $decl,
	    [qw(auth_id parent_id primary_key order_by other)]);

    if ($decl->{where}) {
	$where .= length($where) ? ' and ' : ' where ';
	foreach my $e (@{$decl->{where}}) {
	    if (defined($attrs->{column_aliases}->{$e})) {
		$where .= ' ' . $attrs->{column_aliases}->{$e}->{sql_name};
	    }
	    elsif (defined($attrs->{models}->{$e})) {
#TODO: This doesn't work for qualified columns, but it works for
#      what I need right now.
		$where .= ' ' . $attrs->{models}->{$e}->{sql_name};
	    }
	    else {
		$where .= ' ' . $e;
	    }
	}
    }
    # auth_id must be at most one column.  Turn into that column or undef.
    Carp::croak('too many auth_id fields')
		if int(@{$attrs->{auth_id}}) > 1;

    # Unwind one level--wrapped in array by _init_column_classes
    foreach my $c ('auth_id', 'parent_id') {
	$attrs->{$c} = $attrs->{$c}->[0];
    }
    return undef unless %{$attrs->{models}};

    # primary_key must be at least one column if there are models.
    Carp::croak('no primary_key fields')
		unless @{$attrs->{primary_key}} || !%{$attrs->{models}};
    # Sort all names in a select alphabetically.
    $attrs->{primary_key} = [sort {$a->{name} cmp $a->{name}}
	@{$attrs->{primary_key}}];

    # other can be empty.  No reformatting necessary

    # Ensure that (qual) columns defined for all (qual) models and their
    # primary keys and initialize primary_key_map.
    __PACKAGE__->init_model_primary_key_maps($attrs);

    # order_by may be empty and stays in specified order.
    my($i) = 0;
    foreach my $c (@{$attrs->{order_by}}) {
	$c->{order_by_index} = $i++;
    }

    return $where;
}

# _init_column_lists(hash_ref attrs, string where)
#
# Creates many of the lists in $attrs which are derived from the class
# lists (primary_key, order_by).  Creates select and select_this
# using "where" of field identities and column information already in $attrs
# only if "where" is defined (see _init_column_classes).
#
sub _init_column_lists {
    my($attrs, $where) = @_;

    # Lists are sorted to keep Oracle's cache happy across invocations
    $attrs->{primary_key_names} = [map {$_->{name}} @{$attrs->{primary_key}}];
    $attrs->{primary_key_types} = [map {$_->{type}} @{$attrs->{primary_key}}];
    # order_by can't be sorted, because order is important
    $attrs->{order_by_names} = [map {$_->{name}} @{$attrs->{order_by}}];
    $attrs->{column_names} = [sort(keys(%{$attrs->{columns}}))];

    # No BLOBs
    foreach my $c (values(%{$attrs->{columns}})) {
	Carp::croak($c->{name}, ': cannot have a blob in a ListModel')
		    if $c->{type} eq 'Bivio::Type::BLOB';
    }

    # Nothing to select
    return unless defined($where);

    # Order select columns alphabetically, ignoring primary_key, primary_id
    # and auth_id and any other columns with in_select turned off.
    my(@sel_cols) =
	# Everything but primary_keys, parent_id, auth_id are in column_names
	sort {$a->{name} cmp $b->{name}}
	(grep($_->{in_select}, values(%{$attrs->{columns}})));

    # Go through the list and delete cols we don't return or in the
    # case of the primary key, what we return first.  Yes, this probably
    # could be done in one giant grep, but better to get right than
    # tricky. <g>
    foreach my $col (@{$attrs->{primary_key}},
	    $attrs->{auth_id} ? ($attrs->{auth_id}) : (),
	    $attrs->{parent_id} ? ($attrs->{parent_id}) : ()) {
	@sel_cols = grep($_ ne $col, @sel_cols);
    }

    # Put primary key back on front
    unshift(@sel_cols, @{$attrs->{primary_key}});
    $attrs->{select_columns} = \@sel_cols;

    # Get names and set select_index
    my($i) = 0;
    my(@select_sql_names) = map {
	$_->{select_index} = $i++;
	$_->{type}->from_sql_value($_->{sql_name});
    } @{$attrs->{select_columns}};

    # Create select from all columns and include auth_id and
    # parent_id constraints (if defined) in where.
    $where = ' and '.$attrs->{parent_id}->{sql_name}.'='.$_PRIMARY_ID_SQL_VALUE
	    .$where if $attrs->{parent_id};
    $attrs->{select} = 'select '.join(',', @select_sql_names)
	    .' from '.join(',',
		    map {
			my($tn) = $_->{instance}->get_info('table_name');
			$tn eq $_->{sql_name}
				? $tn : $tn.' '.$_->{sql_name};
		    } sort(values(%{$attrs->{models}})));
    if ($attrs->{auth_id}) {
	$where =~ s/^ where / and /;
	$attrs->{select} .= ' where '
		.$attrs->{auth_id}->{sql_name}.'='.$_PRIMARY_ID_SQL_VALUE
			.$where;
    }
    else {
	$where =~ s/^ and / where /;
	$attrs->{select} .= $where;
    }
    return;
}

# _load_this(Bivio::SQL::Support self, Bivio::SQL::ListQuery, DBI::Statement statement) : array_ref
#
# Load "this" from statement.  We search serially through all records.
# There doesn't appear to be a better way to do this, because we need
# to know "prev".  Eventually, this will have to be PL/SQL.
#
sub _load_this {
    my($self, $query, $statement) = @_;
    my($attrs) = $self->internal_get;
    my($count, $parent_id, $this) = $query->get(qw(count parent_id this));
    my($auth_id) = $attrs->{auth_id} ? $query->get('auth_id') : undef;
    _trace('looking for this ', $attrs->{primary_key_names}, ' = ', $this)
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
	    $match &&= $this->[$j] eq $v;
	    $j++;
	    $v;
	} @$types;
	last if $match;
	$prev = \@prev;
    }

    # Found it, copy all columns of this
    _trace('found this at row #', $row_count) if $_TRACE;
    my($i) = 0;
    my($rows) = [{
	(map {
	    ($_->{name}, $_->{type}->from_sql_column($row->[$i++]));
	} @{$attrs->{select_columns}}),
	# Add in auth_id to every row as constant for convenience
	$attrs->{auth_id} ? ($attrs->{auth_id}->{name} => $auth_id) : (),
	$attrs->{parent_id} ? ($attrs->{parent_id}->{name} => $parent_id) : (),
    }];

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
    $query->put(page_number => int(--$row_count / $count));
    return $rows;
}

# _load_list(Bivio::SQL::Support self, Bivio::SQL::ListQuery, DBI::Statement statement, string select, array_ref params) : array_ref
#
# Search the list until we find our page_number and then return count rows.
# If the page_number exceeds the number of rows, read the last page.
#
sub _load_list {
    my($self, $query, $statement, $select, $params) = @_;
    my($attrs) = $self->internal_get;
    my($count, $page_number, $parent_id)
	    = $query->get(qw(count page_number parent_id));
    my($auth_id) = $attrs->{auth_id} ? $query->get('auth_id') : undef;

    my($row);
 FIND_START: {
	# Set prev first, because there is a return in the for loop
	if ($page_number > 0) {
	    $query->put(has_prev => 1, prev => $page_number - 1);
	}
	else {
	    $query->put(has_prev => 0, prev => undef);
	}

	# Find the page.  We load the first row of the page here.
	my($start) = $page_number * $count;
	for (my($i) = 0; $i <= $start; $i++) {
	    next if $row = $statement->fetchrow_arrayref;

	    # End of list.
	    $statement->finish;

	    # No need to backup, there are no rows
	    unless ($i) {
		_trace('no rows found') if $_TRACE;
		return [];
	    }

	    # Go back to last page.  Have to restart the select.
	    $query->put(page_number => $page_number = int(--$i/$count));
	    _trace('last page=', $page_number, ', retrying') if $_TRACE;
	    $statement = Bivio::SQL::Connection->execute($select, $params);
	    redo FIND_START;
	}
    }

    # Avoid pointer chasing in loop
    my($auth_id_name) =  $attrs->{auth_id} ? $attrs->{auth_id}->{name} : undef;
    my($parent_id_name) = $attrs->{parent_id} ? $attrs->{parent_id}->{name}
	    : undef;
    my($select_columns) = $attrs->{select_columns};

    # Save the rows from the page.  $row comes in from above
    my(@rows);
    for (;;) {
	# Convert the row to a hash_ref
	my($i) = 0;
	push(@rows, {
	    (map {
		($_->{name}, $_->{type}->from_sql_column($row->[$i++]));
	    } @$select_columns),
	    # Add in auth_id and parent_id to every row for convenience
	    ($auth_id_name ? ($auth_id_name => $auth_id) : ()),
	    $parent_id_name ? ($parent_id_name => $parent_id) : (),
	});

	# Have we got enough?
	last if $count-- <= 0;

	# If no more, return what there is
	unless ($row = $statement->fetchrow_arrayref) {
	    $statement->finish;
	    return \@rows;
	}
    }

    # Is there a next?
    if ($statement->fetchrow_arrayref) {
	$query->put(has_next => 1, next => $page_number + 1);
	# See discussion of =item orabug_fetch_all_select
	if ($attrs->{orabug_fetch_all_select}) {
	    0 while $statement->fetchrow_arrayref;
	}
    }
    $statement->finish();

    # Return the page
    return \@rows;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
