# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::SQL::PropertySupport;
use strict;
$Bivio::SQL::PropertySupport::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::SQL::PropertySupport::VERSION;

=head1 NAME

Bivio::SQL::PropertySupport - sql support for PropertyModels

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
supported throught L<"find">, L<"create">, L<"delete">, and L<"update">.

Support uses the L<Bivio::SQL::Connection> for connections and
statement execution.

=head1 ATTRIBUTES

See also L<Bivio::SQL::Support|Bivio::SQL::Support> for more attributes.

=over 4

=item has_blob : boolean

Is true if the PropertModel has a BLOB data type.  Requires special
handling in L<Bivio::SQL::Connection|Bivio::SQL::Connection>.

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
       }
    }

This module takes ownership of I<decl>.

=cut

sub new {
    my($proto, $decl) = @_;
    my($attrs) = {};
    $proto->init_version($attrs, $decl);
    my($table_name) = $decl->{table_name};
    Carp::croak("$table_name: invalid table name, must end in _t")
		unless $table_name =~ m!^\w{1,28}_t$!;
    $attrs->{table_name} = $table_name;
    my($column_cfg) = $decl->{columns};
    my($columns) = $attrs->{columns} = {};
    # Sort the columns, so in a guaranteed order.  Makes for better
    # Oracle caching of prepared statements.
    my($column_names) = $attrs->{column_names} = [sort(keys(%$column_cfg))];
    my($primary_key_names) = $attrs->{primary_key_names} = [];
    my($primary_key) = $attrs->{primary_key} = [];
    $attrs->{column_aliases} = {};
    $attrs->{has_blob} = 0;
    # Go through columns and
    my($n);
    foreach $n (@$column_names) {
	my($cfg) = $column_cfg->{$n};
	my($col) = $attrs->{column_aliases}->{$n} = $columns->{$n} = {
	    # Bivio::SQL::Support attributes
	    name => $n,
	    constraint => Bivio::SQL::Constraint->from_any($cfg->[1]),
	    sql_name => $n,

	};
	Bivio::SQL::Support->init_type($col, $cfg->[0]);
	$col->{sql_pos_param} = $col->{type}->to_sql_value('?');
	$attrs->{has_blob} = 1
		if UNIVERSAL::isa($col->{type}, 'Bivio::Type::BLOB');
	$columns->{$n}->{is_primary_key}
		= $col->{constraint} eq Bivio::SQL::Constraint::PRIMARY_KEY();
	push(@$primary_key_names, $n), push(@$primary_key, $col)
		if $columns->{$n}->{is_primary_key};
    }
    Carp::croak("$table_name: too many BLOBs")
		if $attrs->{has_blob} > 1;
    Carp::croak("$table_name: no primary keys")
		unless int(@$primary_key_names);

    # Get auth_id and other columns
    my($col_count) = int(keys(%$columns));
    __PACKAGE__->init_column_classes($attrs, $decl, [qw(auth_id other)]);
    __PACKAGE__->init_model_primary_key_maps($attrs);
    Carp::croak('columns may not be added in "other" or "auth_id" category')
		unless $col_count == int(keys(%$columns));
    # auth_id must be at most one column.  Turn into that column or undef.
    Carp::croak('too many auth_id fields')
		if int(@{$attrs->{auth_id}}) > 1;
    $attrs->{auth_id} = $attrs->{auth_id}->[0];
    $attrs->{primary_key_types} = [map {$_->{type}} @{$attrs->{primary_key}}];

    # Cache as much of the statements as possible
    $attrs->{select_columns} = [map {
	$columns->{$_};
    } @$column_names];
    $attrs->{select} = 'select '.join (',', map {
	$columns->{$_}->{type}->from_sql_value($_);
    } @$column_names)." from $table_name ";
    $attrs->{insert} = "insert into $table_name ("
	    .join(',', @$column_names).') values ('
	    .join(',', map {$columns->{$_}->{sql_pos_param}} @$column_names)
	    .')';
    $attrs->{primary_where} = ' where ' . join(' and ',
	    map {$_.'='.$columns->{$_}->{sql_pos_param}}
	    @{$primary_key_names});
    $attrs->{delete} = "delete from $table_name ".$attrs->{primary_where};
    $attrs->{update} = "update $table_name set ";

    # Need to lock records for update if has blob.  Coupled with
    # Connection
    $attrs->{update_lock} = "select ".$primary_key_names->[0]
	    ." from $table_name ".$attrs->{primary_where}." for update";

    my($primary_id_name) = $attrs->{table_name};
    $primary_id_name =~ s/_t$/_id/;
    if ($columns->{$primary_id_name}) {
	$attrs->{primary_id_name} = $primary_id_name;
	$attrs->{next_primary_id} = 'select '
		. substr($attrs->{table_name}, 0, -2)
		. '_s.nextval from dual';
    }
    return &Bivio::SQL::Support::new($proto, $attrs);
}

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(hash new_values)

=head2 create(hash new_values, ref die)

Inserts a new record into to database and loads the model's properties.
Dies on errors.

If there is a I<primary_id_column>, the value will be retrieved from
the sequence I<table_name_s> (table_name sans '_t', that is) I<if it
not already set>.

I<die> must implement L<Bivio::Die::die|Bivio::Die/"die">.

=cut

sub create {
    my($self, $new_values, $die) = @_;
    my($attrs) = $self->internal_get;
    my($sql) = $attrs->{insert};

    # Allow the caller to overrid primary_id.  Probably should check
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
	    $new_values->{$pid} = _next_primary_id($self, $die);
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
    my($self, $values, $die, $load_args) = @_;
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

=for html <a name="iterate_start></a>

=head2 iterate_start(ref die, string order_by) : ref

Returns a handle which can be used to iterate the rows with
L<iterate_next|"iterate_next">.  L<iterate_end|"iterate_end">
should be called, too.

I<auth_id> must be the auth_id for the table.  It need not be set
iwc all rows will be returned.

I<order_by> is an SQL C<ORDER BY> clause without the keywords
C<ORDER BY>.

=cut

sub iterate_start {
    my($self, $die, $order_by, $query) = @_;
    my($attrs) = $self->internal_get;
    my(@params);
    my($sql) = _prepare_select($self, $query, \@params);
    $sql .= ' order by '.$order_by;
    my($iterator) = Bivio::SQL::Connection->execute($sql, \@params, $die,
	   $attrs->{has_blob});
    return $iterator;
}

=for html <a name="unsafe_load"></a>

=head2 unsafe_load(hash_ref query) : hash_ref

=head2 unsafe_load(hash_ref query, ref die) : hash_ref

Loads the specified properties with data using the parameterized where_clause
and substitution values. If successful, the values hash will returned.
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
	$statement->finish, die('too many rows returned') if $too_many;
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

# _equals(scalar v, scalar v2) : boolean
#
# Returns true if v is exactly the same as v2

sub _equals {
    my($v, $v2) = @_;
    # oracle treats '' and null the same
    $v = '' unless defined($v);
    $v2 = '' unless defined($v2);
#    return 0 if defined($v) != defined($v2);
#    return 1 unless defined($v);  # both undefined
    return $v eq $v2;
}

# _next_primary_id(Bivio::SQL::PropertySupport self, ref die) : string
#
# Returns the next primary key id for this table
sub _next_primary_id {
    my($self, $die) = @_;
    my($attrs) = $self->internal_get;
    return Bivio::SQL::Connection->execute($attrs->{next_primary_id},
	    $_EMPTY_ARRAY, $die)->fetchrow_array;
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
	    my($column) = $columns->{$_};
	    Bivio::Die->die('invalid field name: ', $_) unless $column;
	    push(@$params, $column->{type}->to_sql_param($query->{$_}));
	    $_.'='.$column->{sql_pos_param};
	    # Use a sort to force order which (may) help Oracle's cache.
	} sort keys(%$query));
    }
    return $sql;
}

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
