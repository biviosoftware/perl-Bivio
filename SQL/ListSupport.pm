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

=item order_by_names : array_ref

List of columns order_by columns (in order).

=item primary_key_types : array_ref

List of primary key types in the order of I<primary_key_names>.

=back

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::Biz::PropertyModel;
use Bivio::SQL::Connection;
use Bivio::Type::PrimaryId;
use Bivio::Util;
use Carp();

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;

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

The categories:

=over 4

=item auth_id : array_ref (required)

A field or field identity which must be equal to
request's I<auth_id> attribute.

=item other : array_ref

A list of fields and field identities that have no ordering.

=item order_by : array_ref

A list of fields and field identities that can be used to sort
the result.  order_by values must not be null.

=item primary_key : array_ref (required)

The list of fields and field identities that uniquely identifies a
row.

=item version : int

The version of this particular combination of fields.  It will be
set in all query strings.  It should be changed whenever the
declaration changes.  It is used to reject an out-dated query.

=back

Example:

    Bivio::SQL::ListSupport->new({
	version => 1,
	order_by => [qw(
            RealmOwner.name
            ClubUser.mail_mode
            RealmUser.role
	)],
        # last_name can be null, so can't be in order_by
        other => [qw(
	    User.last_name
        )],
	primary_key => [
            # Causes a four table join
 	    [qw(User.user_id ClubUser.user_id RealmUser.user_id
                    RealmOwner.realm_id)],
	],
        # Qualifies the join to work only for a specific club
	auth_id => [qw(ClubUser.club_id RealmUser.realm_id)],
    });

This will produce the following properties:

    User.last_name
    RealmOwner.name
    ClubUser.mail_mode
    RealmUser.role
    User.user_id
    ClubUser.club_id

Note that the I<primary_key> for this query is just C<User.user_id>.  The
C<club_id> is a necessary identity, but the C<user_id> must be unique to each
row returned, whereas C<club_id> will be the same for all rows returned.

=cut

sub new {
    my($proto, $decl) = @_;
    Carp::croak("version: not declared") unless $decl->{version};
    Carp::croak("version: not a scalar") if ref($decl->{version});
    my($attrs) = {
	# All columns by qualified name
	columns => {},
	# All models by qualified name
	models => {},
	# All fields and field identities by qualified name
	column_aliases => {},
	# The columns returned by select in order (not including auth_id)
	select_columns => [],
	version => $decl->{version},
    };
    _init_column_lists($attrs, _init_column_classes($attrs, $decl));
    return &Bivio::SQL::Support::new($proto, $attrs);
}

=head1 METHODS

=cut

=for html <a name="get_column_name"></a>

=head2 get_column_name(string name) : string

Returns the name of the column.  This maps all aliases (including
main column names) to the original column name.

=cut

sub get_column_name {
    my($column_aliases) = shift->get('columns_aliases');
    my($name) = shift;
    my($col) = $column_aliases->{$name};
    Carp::croak("$name: no such column alias") unless $col;
    return $col->{name};
}

=for html <a name="load"></a>

=head2 load(Bivio::SQL::ListQuery query, ref die) : array_ref

Loads the specified rows with data using the parameterized where_clause
and substitution values. At most the specified max rows will be loaded.
Data will be loaded starting at the specified index into the result set.

=cut

sub load {
    my($self, $query, $die) = @_;
    return $query->get('this') ? _load_this($self, $query, $die)
	    : _load_list($self, $query, $die);
}

#=PRIVATE METHODS

# _execute_select(Bivio::SQL::ListSupport self, Bivio::SQL::ListQuery query, scalar_ref fob_start) : DBI::Statement
#
# Create and execute the select statement based on query and auth_id.
#
sub _execute_select {
    my($self, $query, $fob_start) = @_;
    my($attrs) = $self->internal_get;
    my($auth_id) =  $query->get('auth_id');
#TODO: If "this", then completely different query.  No order_by.
#      No begin/end.
    my(@params) = Bivio::Type::PrimaryId->to_sql_param($auth_id);
    my($select) = $attrs->{select};
    $$fob_start = @{$attrs->{order_by}}
	    ? _format_select_order_by($attrs, $query, \$select, \@params)
	    : undef;
    return Bivio::SQL::Connection->execute($select, \@params);
}

# _format_select_order_by(hash_ref attrs, Bivio::SQL::ListQuery query, string_ref select, array_ref params) : any
#
# Formats the order_by constraints and order_by clause.
# Returns the first order by value we should encounter.
#
sub _format_select_order_by {
    my($attrs, $query, $select, $params) = @_;
    # Format constraints
    my($begin, $end, $is_forward) = $query->get('begin', 'end', 'is_forward');
    my($compare, $limit) = '>=';
    my($columns) = $attrs->{columns};
    foreach $limit ($begin, $end) {
	next unless $limit;
	my($k);
	foreach $k (sort(keys(%$limit))) {
	    my($col) = $columns->{$k};
	    $$select .= $col->{$compare};
	    push(@$params, $col->{type}->to_sql_param($limit->{$k}));
	}
    }
    continue {
	$compare = '<=';
    }
    $$select .= ' order by';
    my($qob) = $query->get('order_by');
    my($asc, $desc) = $is_forward ? (',', ' desc,') : (' desc,', ',');
    for (my($i) = 0; $i < int(@$qob); $i += 2) {
	# Append the order_by with appropriate
	$$select .= ' '.$columns->{$qob->[$i]}->{sql_name}
		.($qob->[$i+1] ? $asc : $desc);
    }
    # Remove trailing comma
    chop($$select);

    # Return "order by" value expected in the first row returned.
    my($which) = $is_forward ? $begin : $end;
    return $which && defined($which->{$qob->[0]}) ? $which->{$qob->[0]}
	    : undef;
}

# _init_column(hash_ref attrs, string qual_col, string class, boolean is_alias) : hash_ref
#
# Initializes qual_col (Model(_N).column) in columns if not already
# defined.  Sets $attrs->{clauss}
#
sub _init_column {
    my($attrs, $qual_col, $class, $is_alias) = @_;
    my($columns) = $attrs->{columns};
    my($col);
    unless ($col = $columns->{$qual_col}) {
	my($qual_model, $column) = $qual_col =~ m!^(\w+(?:_\d+)?)\.(\w+)$!;
	Carp::croak("$qual_col: invalid qualified column name")
		    unless $qual_model && $column;
	my($model);
	unless ($model = $attrs->{models}->{$qual_model}) {
	    my($package) = 'Bivio::Biz::PropertyModel::'.$qual_model;
	    $package =~ s!((?:_\d+)?)$!!;
	    my($qual_index) = $1;
	    # Make sure package is loaded
	    Bivio::Util::my_require($package);
	    my($instance) = $package->get_instance;
	    $model = $attrs->{models}->{$qual_model} = {
		name => $qual_model,
		instance => $instance,
		sql_name => $instance->get_info('table_name') . $qual_index,
	    };
	}
	my($type) = $model->{instance}->get_field_type($column);
	$col = {
	    # Bivio::SQL::Support attributes
	    name => $qual_col,
	    type => $type,
	    constraint => $model->{instance}->get_field_constraint($column),

	    # Other attributes
	    column_name => $column,
	    model => $model,
	    sql_name => $model->{sql_name}.'.'.$column,
	};
	$columns->{$qual_col} = $col unless $is_alias;
    }
    push(@{$attrs->{$class}}, $col) unless $is_alias;
    return $col;
}

# _init_column_classes(hash_ref attrs) : string
#
# Initialize the column classes.
# Returns the beginnings of the where clause
#
sub _init_column_classes {
    my($attrs, $decl) = @_;
    my($column_aliases) = $attrs->{column_aliases};
#TODO: Need an "column_aliases" map to deal with primary keys.
    my($where) = '';
    my($class);
    # Initialize all columns and put into appropriate column classes
    foreach $class (qw(auth_id primary_key order_by other)) {
	$attrs->{$class} = [];
	my($list) = $decl->{$class};
	next unless $list;
	# auth_id is only one that is syntactically different
	$list = [$list] if $class eq 'auth_id';
	my($c);
	foreach $c (@$list) {
	    my(@c) = ref($c) ? @$c : ($c);
	    # First column is the official name.  The rest are aliases.
	    my($first) = shift(@c);
	    my($col) = _init_column($attrs, $first, $class, 0);
	    $column_aliases->{$first} = $col;
	    my($alias);
	    foreach $alias (@c) {
		# Creates a temporary column just to get sql_name and
		# to make sure "model" is created if need be.
		my($alias_col) = _init_column($attrs, $alias, $class, 1);
		$where .= ' and '.$col->{sql_name}.'='.$alias_col->{sql_name};
		# All aliases point to main column.  They don't exist
		# outside of this context.
		$column_aliases->{$alias} = $col;
	    }
	}
    }

    # auth_id must be exactly one column.  Turn into that column.
    Carp::croak('no auth_id or too many auth_id fields')
		unless int(@{$attrs->{auth_id}}) == 1;
    $attrs->{auth_id} = $attrs->{auth_id}->[0];

    # primary_key must be at least one column.  Sort alphabetically.
    Carp::croak('no primary_key fields') unless @{$attrs->{primary_key}};

    $attrs->{primary_key} = [sort {$a->{sql_name} cmp $a->{sql_name}}
	@{$attrs->{primary_key}}];

    # other can be empty.  No reformatting necessary
    # Ensure that (qual) columns defined for all (qual) models and their
    # primary keys.
    my($n);
    foreach $n (keys(%{$attrs->{models}})) {
	my($m) = $attrs->{models}->{$n};
	$m->{primary_key} = [];
	my($pk);
	foreach $pk (@{$m->{instance}->get_info('primary_key_names')}) {
	    my($cn) = "$m->{name}.$pk";
	    _init_column($attrs, $cn, 'other', 0)
		    unless $column_aliases->{$cn};
	    push(@{$m->{primary_key}}, $cn);
	}
    }

    # order_by may be empty and stays in specified order.  Update some avlues
    my($c);
    foreach $c (@{$attrs->{order_by}}) {
	my($cc) = $c->{constraint};
#TODO: If SQL::Constraint changes, this will probably break.
#      SQL::Constraint really is a set.
	Carp::croak($c->{name}, ": order_by must not be nullable")
		    if $cc == Bivio::SQL::Constraint::NONE();
	# Used by order_by constraints (begin, end)
	$c->{'<='}
		= ' and '.$c->{sql_name}.'<='.$c->{type}->to_sql_value('?');
	($c->{'>='} = $c->{'<='}) =~ s/\<\=/\>\=/;
    }

    return $where;
}

# _init_column_lists(hash_ref attrs, string where)
#
# Creates many of the lists in $attrs which are derived from the class
# lists (primary_key, order_by).  Creates select and select_this
# using "where" of field identities and column information already in $attrs.
#
sub _init_column_lists {
    my($attrs, $where) = @_;
    my($columns) = $attrs->{columns};
    # All lists are sorted to keep Oracle's cache happy across invocations
    $attrs->{primary_key_names} = [map {
	$_->{name};
    } sort {$a->{name} cmp $b->{name}} (@{$attrs->{primary_key}})];
    $attrs->{primary_key_types} = [
	map {$columns->{$_}->{type}} @{$attrs->{primary_key_names}},
    ];
    $attrs->{order_by_names} = [
	map {$_->{name}} @{$attrs->{order_by}},
    ];
    # Order select columns alphabetically, ignoring primary_key and auth_id
    my(%ignore) = map {
	($_->{name}, 1),
    } (@{$attrs->{primary_key}}, $attrs->{auth_id});
    $attrs->{select_columns} = [
	# Everything but primary_keys and auth_id are in column_names
	sort {$a->{name} cmp $b->{name}} (grep(!defined($ignore{$_->{name}}),
		values(%{$attrs->{columns}}))),
    ];
    # Put primary key at front
    unshift(@{$attrs->{select_columns}}, @{$attrs->{primary_key}});
    # Get names and set select_index
    my($i) = 0;
    my(@select_sql_names) = map {
	$_->{select_index} = $i++;
	$_->{type}->from_sql_value($_->{sql_name});
    } @{$attrs->{select_columns}};

    # Create select from all columns and include auth_id constraint in where
    $attrs->{select} = 'select '.join(',', @select_sql_names)
	    .' from '.join(',',
		    map {
			my($tn) = $_->{instance}->get_info('table_name');
			$tn eq $_->{sql_name} ? $tn : $tn.' '.$_->{sql_name};
		    } sort(values(%{$attrs->{models}})))
	    .' where '
	    .$attrs->{auth_id}->{sql_name}
		    .'='.Bivio::Type::PrimaryId->to_sql_value('?')
	    .$where;

    # How to select a single item (_load_this)
    $attrs->{select_this} = join(' and ', $attrs->{select},
	    map {$_->{sql_name}.'='.$_->{type}->to_sql_value('?')}
	    @{$attrs->{primary_key}});

    # Add in auth_id to column_names
    $attrs->{column_names}
	    = [(map {$_->{name}} @{$attrs->{select_columns}}),
		$attrs->{auth_id}->{name}];
    return;
}

# _load_list(Bivio::SQL::Support self, Bivio::SQL::ListQuery, ref die) : array_ref
#
# Load a list from a list query.  The complexity is caused by trying to pick up
# where we left off.  Rows can disappear so it is insufficient to simply search
# for the last primary key (just_prior).  We also watch for a change in the
# first order_by value.  The first order by value is set by ListQuery to limit
# the result set to the just_prior->fob_value.
#
sub _load_list {
    my($self, $query) = @_;
    my($attrs) = $self->internal_get;
    my($fob_start);
    my($statement) = _execute_select($self, $query, \$fob_start);
#TODO: "this" is a separate query.
    my($auth_id, $count, $is_forward, $just_prior, $order_by) = $query->get(
	    'auth_id', 'count', 'is_forward', 'just_prior', 'order_by');
    my($started) = !$just_prior;
    my($fob_index, $fob_type);
    if (!$started && defined($fob_start)) {
	my($fob_col) = $attrs->{columns}->{$order_by->[0]};
	$fob_index = $fob_col->{select_index};
	$fob_type = $fob_col->{type};
	_trace('looking for fob_start (', $fob_col->{name},
		') = ', $fob_start) if $_TRACE;
    }
    _trace('looking for just_prior ', $attrs->{primary_key_names},
	    ' = ', $just_prior)
	    if $_TRACE && $just_prior;
    my($auth_id_name) = $attrs->{auth_id}->{name};
    my($select_columns) = $attrs->{select_columns};
    my($rows) = [];
    my($row);
    # See note about $has_more at the end of this loop
    my($has_more) = 1;
 ROW: while (($row = $statement->fetchrow_arrayref) || ($has_more = 0)) {
	unless ($started) {
	    # If this row matches just_prior primary key or if the first
	    # order_by value has changed, start saving rows.
	    my($j, $jp) = 0;
	    foreach $jp (@$just_prior) {
		# If the primary key field compares with the returned value,
		# keep iterating.  Else, check fob.
		next if $jp eq
			$select_columns->[$j]->{type}->from_sql_column(
				$row->[$j]);
		_trace('just_prior missed on ', $select_columns->[$j]->{name})
			if $_TRACE;

		# Primary key doesn't compare.  If $fob_start isn't defined,
		# go on to next row.  This is an unlikely case, actually,
		# because $fob_start must be defined.
		next ROW unless defined($fob_start);

		# If fob for this row is same as $fob_start, keep going.
		my($fob) = $fob_type->from_sql_column($row->[$fob_index]);
		_trace('fob_start compare to ', $fob) if $_TRACE;
		next ROW if defined($fob) && $fob_start eq $fob;
		_trace('passed fob_start') if $_TRACE;
#TODO: May want to "go back to" the beginning and process all rows.
#      If we miss the just_prior, do we want an error message?

		# If fob is different, means just_prior primary key not found
		# Just start here (no better place, really).
		$started = 1;
		last;
	    }
	    continue {
		$j++;
	    }
	    # Start with this row if $fob is different, else just_prior
	    # primary key found so start with next.
	    next ROW unless $started++;
	}
	# Save rows until $count reaches zero
	my($i) = 0;
	push(@$rows, {
	    (map {
		($_->{name}, $_->{type}->from_sql_column($row->[$i++]));
	    } @$select_columns),
	    # Add in auth_id to every row as constant for convenience
	    $auth_id_name => $auth_id,
	});
	last ROW if --$count <= 0;
    }
    # Can't simply test $s->fetchrow_arrayref to see if there is more,
    # because this will blow up if we already fetched the last row
    # and were told that, i.e. if while loop exited naturally.
    # In this case, $has_more will be false and won't call fetchrow
    $has_more &&= defined($statement->fetchrow_arrayref);
    $query->put(($is_forward ? 'has_next' : 'has_prev') => $has_more);

    # Reverse the rows so ListModel doesn't need to concern itself
    # with is_forward.
    @$rows = reverse(@$rows) unless $is_forward || int(@$rows) <= 1;
    return $rows;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
