# Copyright (c) 1999,2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::SQL::PropertySupport;
use strict;
$Bivio::SQL::PropertySupport::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::SQL::PropertySupport::VERSION;

=head1 NAME

Bivio::SQL::PropertySupport - sql support for PropertyModels

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::SQL::PropertySupport;
    Bivio::SQL::PropertySupport->new($decl);

=cut

=head1 EXTENDS

L<Bivio::SQL::Support>

=cut

use Bivio::SQL::Support;
@Bivio::SQL::PropertySupport::ISA = ('Bivio::SQL::Support');

=head1 DESCRIPTION

C<Bivio::SQL::PropertySupport> is SQL transaction support for
L<Bivio::Biz::PropertyModel>s. PropertyModel life-cycle methods are
supported throught L<"unsafe_load"> L<"create">, L<"delete">, and
L<"update">.

Support uses the L<Bivio::SQL::Connection> for connections and
statement execution.

=head1 ATTRIBUTES

See also L<Bivio::SQL::Support|Bivio::SQL::Support> for more attributes.

=over 4

=item has_blob : boolean

Is true if the PropertModel has a BLOB data type.  Requires special
handling in L<Bivio::SQL::Connection|Bivio::SQL::Connection>.

=item primary_id_name : string

Computed from the columns.  If there is a column which matches the table name
followed by C<_id>, e.g. I<table_name_id> for a table called I<table_name_t>,
this will be the I<primary_id_name> for the table.  See L<create|"create"> for
how it is set automatically from its corresponding sequence.

=item select : string

The list of select_columns followed FROM table.  Does not include
WHERE.

=back

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::Type::DateTime;
use Bivio::HTML;
use Bivio::SQL::Connection;
use Bivio::IO::Trace;
use Bivio::Type::PrimaryId;
use Carp ();

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_EMPTY_ARRAY) = [];
my($_MIN_PRIMARY_ID) = Bivio::Type::PrimaryId->get_min;
Bivio::IO::Config->register(my $_CFG = {
    unused_classes => [qw(RealmFile RealmMail RealmMailBounce Website Forum CalendarEvent JobLock Tuple TupleDef TupleSlotType TupleSlotDef TupleUse Motion MotionVote RealmDAG)],
});

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref decl) : Bivio::SQL::PropertySupport

Creates a SQL support instance. I<decl> is defined as follows:

    {
       version => 1,
       table_name => 'name',
       columns => {
            column_name => [Bivio::Type, Bivio::SQL::Constraint]
            searchable => {
                type => 'MyType',
                constraint => 'NOT_NULL',
                is_searchable => 1,
            },
       }
    }

This module takes ownership of I<decl>.

=cut

sub new {
    my($proto, $decl) = @_;
    my($attrs) = {
	class => $decl->{class},
	parents => {},
	children => [],
	table_name => $decl->{table_name},
	columns => {},
	primary_key => [],
	column_aliases => {},
	has_blob => 0,
    };
    $proto->init_common_attrs($attrs, $decl);
    die("$attrs->{table_name}: invalid table name, must end in _t")
	    unless $attrs->{table_name} =~ m!^\w{1,28}_t$!;

    _init_columns($attrs, $decl->{columns});

    # Get auth_id and other columns
    my($save_count) = int(keys(%{$attrs->{columns}}));
    __PACKAGE__->init_column_classes($attrs, $decl, [qw(auth_id other)]);
    __PACKAGE__->init_model_primary_key_maps($attrs);
    Bivio::Die->die(
        'columns may not be added in "other" or "auth_id" category: ',
        [keys(%{$attrs->{columns}})])
        unless $save_count == int(keys(%{$attrs->{columns}}));

    # auth_id must be at most one column.  Turn into that column or undef.
    Carp::croak('too many auth_id fields')
		if int(@{$attrs->{auth_id}}) > 1;
    $attrs->{auth_id} = $attrs->{auth_id}->[0];
    $attrs->{primary_key_types} = [map {$_->{type}} @{$attrs->{primary_key}}];

    # Cache as much of the statements as possible
    _init_statements($attrs);
    return $proto->SUPER::new($attrs);
}

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(hash new_values)

=head2 create(hash new_values, ref die)

Inserts a new record into to database and loads the model's properties.
Dies on errors.

If there is a I<primary_id_name>, the value will be retrieved from
the sequence I<table_name_s> (table_name sans '_t', that is) I<if it
not already set>.

I<die> must implement L<Bivio::Die::die|Bivio::Die/"die">.

=cut

sub create {
    my($self, $new_values, $die) = @_;
    my($attrs) = $self->internal_get;
    my($sql) = $attrs->{insert};

    # Allow the caller to override primary_id.  Probably should check
    # that isn't a valid sequence.
    my($pid) = $attrs->{primary_id_name};
    if ($pid) {
	if ($new_values->{$pid}) {
#TODO: Need an assertion check about not using sequences....
#	    $die->throw_die('DIE', {message =>
#		'special primary_id greater than min primary id',
#		field => $pid, value => $new_values->{$pid}})
#		    unless $new_values->{$pid} < $_MIN_PRIMARY_ID;
	}
	else {
	    $new_values->{$pid} = Bivio::SQL::Connection->next_primary_id(
		    $attrs->{table_name}, $die);
	}
    }
    my($columns) = $attrs->{columns};
    my(@params) = map {
	$columns->{$_}->{type}->to_sql_param($new_values->{$_});
    } @{$attrs->{column_names}};
    Bivio::SQL::Connection->execute($sql, \@params, $die,
	    $attrs->{has_blob})->finish();
    return;
}

=for html <a name="delete"></a>

=head2 delete(hash_ref values) : boolean

=head2 delete(hash_ref values, ref die) : boolean

Removes the row with identified by the specified parameterized where_clause
and substitution values. If an error occurs during the delete, calls die.

I<die> must implement L<Bivio::Die::die|Bivio::Die/"die">.

Returns true if something was deleted.

=cut

sub delete {
    my($self, $values, $die) = @_;
    my($attrs) = $self->internal_get;
    my($columns) = $attrs->{columns};
    my(@params) = map {
        unless (exists($values->{$_})) {
            $die ||= 'Bivio::Die';
            $die->throw_die('DIE', {
                message => 'missing primary key value for delete',
                entity => $self,
                column => $_});
        }
	$columns->{$_}->{type}->to_sql_param($values->{$_});
    } @{$attrs->{primary_key_names}};
    my($sth) = Bivio::SQL::Connection->execute($attrs->{delete},
	    \@params, $die,
	    $attrs->{has_blob});
    my($rows) = $sth->rows;
    $sth->finish();
    return $rows ? 1 : 0;
}

=for html <a name="delete_all"></a>

=head2 delete_all(hash_ref values, ref die) : int

Deletes all the rows specified by the possibly partial key values.
If an error occurs during the delete, calls die.
Returns the number of rows deleted.

=cut

sub delete_all {
    my($self, $values, $die) = @_;
    my($sql) = 'delete from '.$self->get('table_name').' where ';
    my($params) = [];
    my($first_col) = 1;
    foreach my $col (sort(keys(%$values))) {
	my($info) = $self->get_column_info($col);
	$sql .= ($first_col ? '' : ' and ').$col.'='.$info->{sql_pos_param};
	push(@$params, $info->{type}->to_sql_param($values->{$col}));
	$first_col = 0;
    }
    my($sth) = Bivio::SQL::Connection->execute($sql, $params, $die);
    my($rows) = $sth->rows;
    $sth->finish;
    return $rows ? $rows : 0;
}

=for html <a name="get_children"></a>

=head2 get_children() : array_ref

Returns an array of (model class, key map) pairs.

=cut

sub get_children {
    my($self) = @_;
    return $self->get('children');
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item unused_classes : array_ref (required)

May be empty.  List of PropertyModel classes not in use in this application.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

=for html <a name="iterate_start></a>

=head2 iterate_start(ref die, string order_by, hash_ref query) : ref

Returns a handle which can be used to iterate the rows with
L<iterate_next|"iterate_next">.  L<iterate_end|"iterate_end">
should be called, too.

I<query> is formatted like L<unsafe_load|"unsafe_load">.

I<auth_id> must be the auth_id for the table.  It need not be set
iwc all rows will be returned.

I<order_by> is an SQL C<ORDER BY> clause without the keywords
C<ORDER BY>.

=cut

sub iterate_start {
    my($self, $die, $order_by, $query) = @_;
    my(@params);
    my($sql) = _prepare_select($self, $query, \@params);
    $sql =~ s/(\bwhere\s*)?$/ order by $order_by/i;
    my($iterator) = Bivio::SQL::Connection->execute($sql, \@params, $die,
	    $self->get('has_blob'));
    return $iterator;
}

=for html <a name="register_child_model"></a>

=head2 register_child_model(string child, hash_ref key_map)

Adds the (child, key_map) pair to the model's child list.

=cut

sub register_child_model {
    my($self, $child, $key_map) = @_;
    push(@{$self->get('children')}, $child, $key_map);
    return;
}

=for html <a name="unsafe_load"></a>

=head2 unsafe_load(hash_ref query) : hash_ref

=head2 unsafe_load(hash_ref query, ref die) : hash_ref

Loads the specified properties with data using the parameterized where clause
and substitution values. If successful, the values hash will returned.

I<query> is processed into the where.  Values in the query which
are array_refs are converted with
L<Bivio::Type::to_sql_param_list|Bivio::Type/"to_sql_param_list">.
Other values are processed with
L<Bivio::Type::to_sql_param|Bivio::Type/"to_sql_param">.

Returns undef if no rows were returned.

I<die> must implement L<Bivio::Die::die|Bivio::Die/"die">.

=cut

sub unsafe_load {
    my($self, $query, $die) = @_;
    my($attrs) = $self->internal_get;
    my(@params);
    my($sql) = _prepare_select($self, $query, \@params);
    my($statement) = Bivio::SQL::Connection->execute($sql, \@params, $die,
	   $attrs->{has_blob});
    my($start_time) = Bivio::Type::DateTime->gettimeofday();
    my($row) = $statement->fetchrow_arrayref();
    my($too_many) = $statement->fetchrow_arrayref ? 1 : 0 if $row;
    Bivio::SQL::Connection->increment_db_time($start_time);
    my($values);
    if ($row) {
	if ($too_many) {
	    $statement->finish;
	    $die->throw_die('TOO_MANY', {
		message => 'too many rows returned',
		sql => $sql,
		params => \@params,
	    });
	}
	my($columns) = $attrs->{columns};
	my($i) = 0;
	$values = {map {
	    ($_->{name}, $_->{type}->from_sql_column($row->[$i++]));
	} @{$attrs->{select_columns}}};
    }
    $statement->finish();
    return $values;
}

=for html <a name="update"></a>

=head2 update(hash_ref old_values, hash_ref new_values)

=head2 update(hash_ref old_values, hash_ref new_values, ref die)

Updates the database fields for the specified model extracting primary
keys from I<old_values>.

=cut

sub update {
    my($self, $old_values, $new_values, $die) = @_;
    my($attrs) = $self->internal_get;
    my($columns) = $attrs->{columns};
    my($set);
    my(@params);
    my($n);
    foreach $n (@{$attrs->{column_names}}) {
	next if ! exists($new_values->{$n});
	my($column) = $columns->{$n};
	if ($column->{is_primary_key}) {
            Bivio::IO::Alert->warn('Attempted to change primary key field: ',
                $attrs->{table_name}, '.', $column->{name}, ': (old, new) = (',
                $old_values, ',', $new_values, ')')
                if exists($new_values->{$n}) && $column->{type}->compare(
                    $new_values->{$n}, $old_values->{$n}) != 0;
	    # Ensure primary keys aren't different, because PropertyModel
	    # always copies new_values to old_values on success
	    $new_values->{$n} = $old_values->{$n};
	    # Don't update primary keys
	    next;
	}
	my($old) = $old_values->{$n};
	my($new) = $new_values->{$n};
	# This works for BLOBs, too.  If the scalar_ref is the same,
	# then we don't update.
	next if _equals($old, $new);
	$set .= $n.'='.$column->{sql_pos_param}.',';
	$new = $column->{type}->to_sql_param($new);
	push(@params, $new);
    }
    # check if any changes required
    unless ($set) {
	&_trace(defined($die) ? ($die, ': ') : (), 'no update required')
		if $_TRACE;
	return;
    }
    # remove the extra ',' from set
    chop($set);
    # add primary key values for the primary_where
    my(@pk);
    foreach $n (@{$attrs->{primary_key_names}}) {
	push(@pk, $columns->{$n}->{type}->to_sql_param($old_values->{$n}));
    }
    push(@params, @pk);

    # Need to lock the row before updating if lob
    if ($attrs->{has_blob}) {
	Bivio::SQL::Connection->execute(
		$attrs->{update_lock}, \@pk, $die)->finish();
    }

    Bivio::SQL::Connection->execute(
	    $attrs->{update}.$set.$attrs->{primary_where}, \@params, $die,
	    $attrs->{has_blob})->finish();
    return;
}

#=PRIVATE METHODS

# _add_parent_model(hash_ref attrs, string field, string parent_model, string parent_field)
#
# Adds the specified (parent_model, parent_field) mapping to the current
# model's parent list.
#
sub _add_parent_model {
    my($attrs, $field, $parent_model, $parent_field) = @_;
    my($parents) = $attrs->{parents};
    $parents->{$parent_model} ||= {};

    # use field name to uniquely identify if field already in use
    if (int(grep(/$field/, values(%{$parents->{$parent_model}})))) {
	$parent_model .= '#'.$field;
    }
    $parents->{$parent_model}->{$field} = $parent_field;
    return;
}

# _equals(scalar v, scalar v2) : boolean
#
# Returns true if v is exactly the same as v2

sub _equals {
    my($v, $v2) = @_;
    # oracle treats '' and null the same
    $v = '' unless defined($v);
    $v2 = '' unless defined($v2);
    return $v eq $v2;
}

# _init_columns(hash_ref attrs, hash_ref column_cfg)
#
# Initializes the columns.
#
sub _init_columns {
    my($attrs, $column_cfg) = @_;
    # Sort the columns, so in a guaranteed order.  Makes for better
    # Oracle caching of prepared statements.  We sort first, so
    # primary keys are sorted as well.
    $attrs->{column_names} = [sort(keys(%$column_cfg))];

    foreach my $n (@{$attrs->{column_names}}) {
	my($cfg) = $column_cfg->{$n};
	my($col) = ref($cfg) eq 'HASH' ? $cfg : {
	    type => $cfg->[0],
	    constraint => $cfg->[1],
	};
	$attrs->{columns}->{$n} = $attrs->{column_aliases}->{$n} = $col;
	Bivio::SQL::Support->init_type($col, $col->{type});
	$col->{constraint}
		= Bivio::SQL::Constraint->from_any($col->{constraint});
	$col->{sql_name} = $col->{name} = $n;
	$col->{is_searchable} = $col->{is_searchable} ? 1 : 0;
	$col->{sql_pos_param} = $col->{type}->to_sql_value('?');
	$attrs->{has_blob} = 1
		if UNIVERSAL::isa($col->{type}, 'Bivio::Type::BLOB');
	$col->{is_primary_key}
		= $col->{constraint} eq Bivio::SQL::Constraint::PRIMARY_KEY()
			? 1 : 0;
	push(@{$attrs->{primary_key}}, $col)
		if $col->{is_primary_key};

	# related model field type
	if ($cfg->[0] =~ /^(.*)\.(.*)$/) {
	    my($parent_model, $parent_field) = ($1, $2);
	    _add_parent_model($attrs, $n, $parent_model, $parent_field);
	}
    }
    _register_with_parents($attrs);
    Bivio::Die->die($attrs->{table_name}, ': too many BLOBs')
		if $attrs->{has_blob} > 1;
    Bivio::Die->die($attrs->{table_name}, ': no primary keys')
		unless int(@{$attrs->{primary_key}});

    $attrs->{primary_key_names} = [map {$_->{name}} @{$attrs->{primary_key}}];
    return;
}

# _init_statements(hash_ref)
#
# Initializes select, update etc.
#
sub _init_statements {
    my($attrs) = @_;

    # Select
    $attrs->{select_columns} = [map {
	$attrs->{columns}->{$_};
    } @{$attrs->{column_names}}];

    $attrs->{select} = 'select '.join (',', map {
	$attrs->{columns}->{$_}->{type}->from_sql_value($_);
    } @{$attrs->{column_names}})." from $attrs->{table_name} ";

    # Insert
    $attrs->{insert} = "insert into $attrs->{table_name} ("
	    .join(',', @{$attrs->{column_names}}).') values ('
	    .join(',', map {
		$attrs->{columns}->{$_}->{sql_pos_param}
	    } @{$attrs->{column_names}})
	    .')';

    # Delete & update
    $attrs->{primary_where} = ' where ' . join(' and ',
	    map {
		$_.'='.$attrs->{columns}->{$_}->{sql_pos_param}
	    } @{$attrs->{primary_key_names}});
    $attrs->{delete} = "delete from $attrs->{table_name} "
	    .$attrs->{primary_where};
    $attrs->{update} = "update $attrs->{table_name} set ";

    # Need to lock records for update if has blob.  Coupled with
    # Connection
    $attrs->{update_lock} = "select ".$attrs->{primary_key_names}->[0]
	    ." from $attrs->{table_name} "
		    .$attrs->{primary_where}." for update";

    my($primary_id_name) = $attrs->{table_name};
    $primary_id_name =~ s/_t$/_id/;
    if ($attrs->{columns}->{$primary_id_name}) {
	$attrs->{primary_id_name} = $primary_id_name;
    }
    return;
}

# _prepare_select(Bivio::SQL::PropertySupport self, hash_ref query, array_ref params) : string
#
# Returns select statement including where if there is a query.
#
sub _prepare_select {
    my($self, $query, $params) = @_;
    # Create the where clause and values array
    my($attrs) = $self->internal_get;
    my($columns) = $attrs->{columns};
    my($sql) = $attrs->{select};
    if ($query) {
	$sql .=' where '.join(' and ', map {
	    Bivio::Die->die('invalid field name: ', $_)
		unless $columns->{$_};
	    _prepare_select_param($columns->{$_}, $query->{$_}, $params);
	    # Use a sort to force order which (may) help Oracle's cache.
	} sort keys(%$query));
    }
    return $sql;
}

# _prepare_select_param(hash_ref column, any value, array_ref params) : any
#
# Returns the string for the query.  If undef, adds "IS NULL" test. Pushes the
# value on params, otherwise.  Handles ARRAY parameters as IN (?, ...).
#
sub _prepare_select_param {
    my($column, $value, $params) = @_;
    return $column->{sql_name} . ' IS NULL'
	unless defined($value);
    unless (ref($value) eq 'ARRAY') {
	push(@$params, $column->{type}->to_sql_param($value));
	return $column->{sql_name} . '=' . $column->{sql_pos_param};
    }
    $value = [map($column->{type}->from_literal($_), @$value)];
    push(@$params, @{$column->{type}->to_sql_param_list($value)});
    return $column->{sql_name}
	. ' IN '
	. $column->{type}->to_sql_value_list($value);
}

# _register_with_parents(hash_ref attrs)
#
# Registers the current model class with the each parent model/field
# added during L<"_add_parent_model">.
#
sub _register_with_parents {
    my($attrs) = @_;
    return if grep(
	!$attrs->{class} || $_ eq $attrs->{class}->simple_package_name,
	@{$_CFG->{unused_classes}},
    );
    my($parents) = $attrs->{parents};
    foreach my $parent (keys(%$parents)) {
	my($parent_class) = $parent;
	$parent_class =~ s/^(.*)\#\w+$/$1/;
	Bivio::Biz::Model->get_instance($parent_class)->new()
		    ->register_child_model($attrs->{class},
			    $parents->{$parent});
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
