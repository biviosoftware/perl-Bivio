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

=head1 EXAMPLE

The following declaration is taken from
L<Bivio::Biz::ListModel::ClubUser|Bivio::Biz::ListModel::ClubUser>:

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
I<ClubUser.mail_mode>, it is allowed and "why not?".  The restriction on
C<order_by> is that the field may not be null and is ordered in a
way which is visible to the user.  Ordering by PrimaryId makes no
sense, because the user shouldn't every see primary ids.

The I<User.last_name> isn't an C<order_by> field, because it can be null.
We put it in C<other>, so that it is available to be presented to the
user.

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

=item auth_id : string (required)

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
    };
    $proto->init_version($attrs, $decl);
    _init_column_lists($attrs, _init_column_classes($attrs, $decl));
    return &Bivio::SQL::Support::new($proto, $attrs);
}

=head1 METHODS

=cut

=for html <a name="load"></a>

=head2 load(Bivio::SQL::ListQuery query, ref die) : array_ref

Loads the specified rows with data using the parameterized where_clause
and substitution values. At most the specified max rows will be loaded.
Data will be loaded starting at the specified index into the result set.

=cut

sub load {
    my($self, $query, $die) = @_;
    # If there is a select, load with "this" or "list".
    # Otherwise, no select such just return an empty list.
    return $self->has_keys('select') ?
	    $query->get('this') ? _load_this($self, $query, $die)
		    : _load_list($self, $query, $die)
			    : [];
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

# _init_column_classes(hash_ref attrs, hash_ref decl) : string
#
# Initialize the column classes.
# Returns the beginnings of the where clause
#
sub _init_column_classes {
    my($attrs, $decl) = @_;
    my($where) = __PACKAGE__->init_column_classes($attrs, $decl,
	    [qw(auth_id primary_key order_by other)]);

    return undef unless %{$attrs->{models}};

    # auth_id must be exactly one column.  Turn into that column.
    Carp::croak('no auth_id or too many auth_id fields')
		unless int(@{$attrs->{auth_id}}) == 1;
    $attrs->{auth_id} = $attrs->{auth_id}->[0];

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

    # order_by may be empty and stays in specified order.  Update some avlues
    foreach my $c (@{$attrs->{order_by}}) {
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
# using "where" of field identities and column information already in $attrs
# only if "where" is defined (see _init_column_classes).
#
sub _init_column_lists {
    my($attrs, $where) = @_;
    my($columns) = $attrs->{columns};

    # Lists are sorted to keep Oracle's cache happy across invocations
    $attrs->{primary_key_names} = [map {$_->{name}} @{$attrs->{primary_key}}];
    $attrs->{primary_key_types} = [map {$_->{type}} @{$attrs->{primary_key}}];
    # order_by can't be sorted, because order is important
    $attrs->{order_by_names} = [map {$_->{name}} @{$attrs->{order_by}}];
    $attrs->{column_names} = [sort(keys(%{$attrs->{columns}}))];

    # Nothing to select
    return unless defined($where);

    # Order select columns alphabetically, ignoring primary_key and auth_id
    my(%ignore) = map {
	($_->{name}, 1),
    } (@{$attrs->{primary_key}}, $attrs->{auth_id},
	    @{$attrs->{local_columns}});
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

    # Create select from all columns and include auth_id constraint
    # in where
    $attrs->{select} = 'select '.join(',', @select_sql_names)
	    .' from '.join(',',
		    map {
			my($tn) = $_->{instance}->get_info('table_name');
			$tn eq $_->{sql_name}
				? $tn : $tn.' '.$_->{sql_name};
		    } sort(values(%{$attrs->{models}})))
	    .' where '
	    .$attrs->{auth_id}->{sql_name}
	    .'='.Bivio::Type::PrimaryId->to_sql_value('?')
	    .$where;
    # How to select a single item (_load_this)
    $attrs->{select_this} = join(' and ', $attrs->{select},
	    map {$_->{sql_name}.'='.$_->{type}->to_sql_value('?')}
	    @{$attrs->{primary_key}});

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
	    _trace($started ? 'passed fob_start' : 'found just_prior',
		   ' at row #', $statement->rows) if $_TRACE;
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
