# Copyright (c) 1999-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::SQL::PropertySupport;
use strict;
use base 'Bivio::SQL::Support';
use Bivio::Die;
use Bivio::HTML;
use Bivio::IO::Trace;
use Bivio::SQL::Connection;
use Bivio::Type::DateTime;
use Bivio::Type::PrimaryId;
use Carp ();

# C<Bivio::SQL::PropertySupport> is SQL transaction support for
# L<Bivio::Biz::PropertyModel>s. PropertyModel life-cycle methods are
# supported throught L<"unsafe_load"> L<"create">, L<"delete">, and
# L<"update">.
#
# Support uses the L<Bivio::SQL::Connection> for connections and
# statement execution.
#
#
# See also L<Bivio::SQL::Support|Bivio::SQL::Support> for more attributes.
#
#
# has_blob : boolean
#
# Is true if the PropertModel has a BLOB data type.  Requires special
# handling in L<Bivio::SQL::Connection|Bivio::SQL::Connection>.
#
# primary_id_name : string
#
# Computed from the columns.  If there is a column which matches the table name
# followed by C<_id>, e.g. I<table_name_id> for a table called I<table_name_t>,
# this will be the I<primary_id_name> for the table.  See L<create|"create"> for
# how it is set automatically from its corresponding sequence.
#
# select : string
#
# The list of select_columns followed FROM table.  Does not include
# WHERE.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_EMPTY_ARRAY) = [];
my($_MIN_PRIMARY_ID) = Bivio::Type::PrimaryId->get_min;
Bivio::IO::Config->register(my $_CFG = {
    unused_classes => [qw(RealmFile RealmMail RealmMailBounce Website Forum CalendarEvent JobLock Tuple TupleDef TupleSlotType TupleSlotDef TupleUse Motion MotionVote RealmDAG OTP NonuniqueEmail CRMThread)],
});
my($_C) = __PACKAGE__->use('SQL.Constraint');

sub create {
    my($self, $new_values, $die) = @_;
    # Inserts a new record into to database and loads the model's properties.
    # Dies on errors.
    #
    # If there is a I<primary_id_name>, the value will be retrieved from
    # the sequence I<table_name_s> (table_name sans '_t', that is) I<if it
    # not already set>.
    #
    # I<die> must implement L<Bivio::Die::die|Bivio::Die/"die">.
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
    Bivio::SQL::Connection->execute($sql, \@params, $die, $attrs->{has_blob})
        ->finish;
    return;
}

sub delete {
    my($self, $values, $die) = @_;
    # Removes the row with identified by the specified parameterized where_clause
    # and substitution values. If an error occurs during the delete, calls die.
    #
    # I<die> must implement L<Bivio::Die::die|Bivio::Die/"die">.
    #
    # Returns true if something was deleted.
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

sub delete_all {
    my($self, $values, $die) = @_;
    # Deletes all the rows specified by the possibly partial key values.
    # If an error occurs during the delete, calls die.
    # Returns the number of rows deleted.
    my($sql) = 'delete from ' . $self->get('table_name');
    my($params) = [];
    my($first_col) = 1;
    foreach my $col (sort(keys(%$values))) {
	my($info) = $self->get_column_info($col);
	$sql .= ($first_col ? ' where ' : ' and ')
	    . $col . '=' . $info->{sql_pos_param};
	push(@$params, $info->{type}->to_sql_param($values->{$col}));
	$first_col = 0;
    }
    my($sth) = Bivio::SQL::Connection->execute($sql, $params, $die);
    my($rows) = $sth->rows;
    $sth->finish;
    return $rows ? $rows : 0;
}

sub get_children {
    return shift->get('children');
}

sub handle_config {
    my(undef, $cfg) = @_;
    # unused_classes : array_ref (required)
    #
    # May be empty.  List of PropertyModel classes not in use in this application.
    $_CFG = $cfg;
    return;
}

sub iterate_start {
    my($self, $die, $order_by, $query) = @_;
    # Returns a handle which can be used to iterate the rows with
    # L<iterate_next|"iterate_next">.  L<iterate_end|"iterate_end">
    # should be called, too.
    #
    # I<query> is formatted like L<unsafe_load|"unsafe_load">.
    #
    # I<auth_id> must be the auth_id for the table.  It need not be set
    # iwc all rows will be returned.
    #
    # I<order_by> is an SQL C<ORDER BY> clause without the keywords
    # C<ORDER BY>.
    my(@params);
    my($sql) = _prepare_select($self, $query, \@params);
    $sql =~ s/(\bwhere\s*)?$/ order by $order_by/i;
    my($iterator) = Bivio::SQL::Connection->execute($sql, \@params, $die,
	    $self->get('has_blob'));
    return $iterator;
}

sub new {
    my($proto, $decl) = @_;
    # Creates a SQL support instance. I<decl> is defined as follows:
    #
    #     {
    #        version => 1,
    #        table_name => 'name',
    #        columns => {
    #             column_name => [Bivio::Type, Bivio::SQL::Constraint]
    #             searchable => {
    #                 type => 'MyType',
    #                 constraint => 'NOT_NULL',
    #                 is_searchable => 1,
    #             },
    #        }
    #     }
    #
    # This module takes ownership of I<decl>.
    my($attrs) = {
	class => $decl->{class},
	parents => {},
	children => [],
	table_name => $decl->{table_name},
	columns => {},
	primary_key => [],
	column_aliases => {},
	has_blob => 0,
	cascade_delete_children => $decl->{cascade_delete_children} || 0,
    };
    $proto->init_common_attrs($attrs, $decl);
    die("you must declare table_name")
	unless defined($attrs->{table_name});
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

sub register_child_model {
    unshift(@{shift->get('children')}, [@_]);
    return;
}

sub unsafe_load {
    my($self, $query, $die) = @_;
    # Loads the specified properties with data using the parameterized where clause
    # and substitution values. If successful, the values hash will returned.
    #
    # I<query> is processed into the where.  Values in the query which
    # are array_refs are converted with
    # L<Bivio::Type::to_sql_param_list|Bivio::Type/"to_sql_param_list">.
    # Other values are processed with
    # L<Bivio::Type::to_sql_param|Bivio::Type/"to_sql_param">.
    #
    # Returns undef if no rows were returned.
    #
    # I<die> must implement L<Bivio::Die::die|Bivio::Die/"die">.
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

sub update {
    my($self, $old_values, $new_values, $die) = @_;
    # Updates the database fields for the specified model extracting primary
    # keys from I<old_values>.
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

    # Need to lock the row before updating if blob
    if ($attrs->{has_blob}) {
	Bivio::SQL::Connection->execute(
		$attrs->{update_lock}, \@pk, $die)->finish();
    }

    Bivio::SQL::Connection->execute(
	    $attrs->{update}.$set.$attrs->{primary_where}, \@params, $die,
	    $attrs->{has_blob})->finish();
    return;
}

sub _add_parent_model {
    my($attrs, $field, $parent_model, $parent_field) = @_;
    my($parents) = $attrs->{parents};
    $parents->{$parent_model} ||= {};
    $parent_model .= " $field"
	if grep(/$field/, values(%{$parents->{$parent_model}}));
    $parents->{$parent_model}->{$field} = $parent_field;
    return;
}

sub _equals {
    my($v, $v2) = @_;
    $v = '' unless defined($v);
    $v2 = '' unless defined($v2);
    return $v eq $v2;
}

sub _init_columns {
    my($attrs, $column_cfg) = @_;
    # Initializes the columns.
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
	my($type_decl) = $col->{type};
	$attrs->{columns}->{$n} = $attrs->{column_aliases}->{$n} = $col;
	Bivio::SQL::Support->init_type($col, $col->{type});
	$col->{constraint} = $_C->from_any($col->{constraint});
	$col->{sql_name} = $col->{name} = $n;
	$col->{is_searchable} = $col->{is_searchable} ? 1 : 0;
	$col->{sql_pos_param} = $col->{type}->to_sql_value('?');
	$col->{sql_pos_param_for_insert} ||= $col->{type}->to_sql_value('?');
	$attrs->{has_blob} = 1
	    if UNIVERSAL::isa($col->{type}, 'Bivio::Type::BLOB');
	$col->{is_primary_key} = $col->{constraint}->eq_primary_key;
	push(@{$attrs->{primary_key}}, $col)
	    if $col->{is_primary_key};
	_add_parent_model($attrs, $n, $1, $2)
	    if $type_decl =~ /^(.*)\.(.*)$/;

# 	# related model field type
# 	if ($cfg->[0] =~ /^(.*)\.(.*)$/) {
# 	    my($parent_model, $parent_field) = ($1, $2);
# 	    _add_parent_model($attrs, $n, $parent_model, $parent_field);
# 	    if ($attrs->{class} eq 'Bivio::Biz::Model::User') {
# 		__PACKAGE__->init_column($attrs, $cfg->[0], 'other', 1);
# 		$attrs->{column_aliases}->{$cfg->[0]} = $col;
# 	    }
# 	}
    }
    _register_with_parents($attrs);
    Bivio::Die->die($attrs->{table_name}, ': too many BLOBs')
		if $attrs->{has_blob} > 1;
    Bivio::Die->die($attrs->{table_name}, ': no primary keys')
		unless int(@{$attrs->{primary_key}});

    $attrs->{primary_key_names} = [map {$_->{name}} @{$attrs->{primary_key}}];
    return;
}

sub _init_statements {
    my($attrs) = @_;
    $attrs->{select_columns} = [map {
	$attrs->{columns}->{$_};
    } @{$attrs->{column_names}}];

    $attrs->{select} = 'select '.join (',', map {
	$attrs->{columns}->{$_}->{type}->from_sql_value($_);
    } @{$attrs->{column_names}})." from $attrs->{table_name} ";
    $attrs->{insert} = "insert into $attrs->{table_name} ("
	    .join(',', @{$attrs->{column_names}}).') values ('
	    .join(',', map {
		$attrs->{columns}->{$_}->{sql_pos_param_for_insert}
	    } @{$attrs->{column_names}})
	    .')';
    $attrs->{primary_where} = ' where ' . join(' and ',
	    map {
		$_.'='.$attrs->{columns}->{$_}->{sql_pos_param}
	    } @{$attrs->{primary_key_names}});
    $attrs->{delete} = "delete from $attrs->{table_name} "
	    .$attrs->{primary_where};
    $attrs->{update} = "update $attrs->{table_name} set ";
    $attrs->{update_lock} = "select ".$attrs->{primary_key_names}->[0]
	    ." from $attrs->{table_name} "
		    .$attrs->{primary_where}." for update";
    my($primary_id_name) = $attrs->{table_name};
    $primary_id_name =~ s/_t$/_id/;
    $attrs->{primary_id_name} = $primary_id_name
	if $attrs->{columns}->{$primary_id_name};
    return;
}

sub _prepare_select {
    my($self, $query, $params) = @_;
    # Returns select statement including where if there is a query.
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

sub _prepare_select_param {
    my($column, $value, $params) = @_;
    # Returns the string for the query.  If undef, adds "IS NULL" test. Pushes the
    # value on params, otherwise.  Handles ARRAY parameters as IN (?, ...).
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

sub _register_with_parents {
    my($attrs) = @_;
    return if grep(
	!$attrs->{class} || $_ eq $attrs->{class}->simple_package_name,
	@{$_CFG->{unused_classes}},
    );
    while (my($parent, $key_map) = each(%{$attrs->{parents}})) {
	Bivio::Biz::Model->get_instance($parent =~ /^(\S+)/)
	    ->register_child_model($attrs->{class}, $key_map);
    }
    return;
}

1;
