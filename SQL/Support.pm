# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::SQL::Support;
use strict;
$Bivio::SQL::Support::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::SQL::Support - sql support for Models

=head1 SYNOPSIS

    package MyModel;

    my($support) = Bivio::SQL::Support->new('user_t',
        {user_id => ['Bivio::Type::PrimaryId',
                     Bivio::SQL::Constraint::PRIMARY_KEY()],
         first_name => ['Bivio::Type::Name',
                     Bivio::SQL::Constraint::NONE],
        });

    $support->create($self, $self->internal_get_fields(),
        'id' => 100, 'name' => 'foo');

=cut

use Bivio::UNIVERSAL;
@Bivio::SQL::Support::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::SQL::Support> is SQL transaction support for
L<Bivio::Biz::PropertyModel>s. PropertyModel life-cycle methods are
supported throught L<"find">, L<"create">, L<"delete">, and L<"update">.

Support uses the L<Bivio::SQL::Connection> for connections and
statement execution.

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::SQL::Connection;
use Bivio::IO::Trace;
use Bivio::Util;
use Carp ();

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_EMPTY_ARRAY) = [];

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string table_name, hash_ref column_cfg) : Bivio::SQL::Support

Creates a SQL support instance. I<columns> is defined as follows:

    {
        column_name => [Bivio::Type, Bivio::SQL::Constraint]
    }

This module takes ownership of I<columns>.

=cut

sub new {
    my($proto, $table_name, $column_cfg) = @_;
    my($self) = &Bivio::UNIVERSAL::new($proto);
    Carp::croak("$table_name: invalid table name, must end in _t")
		unless $table_name =~ m!^\w{1,28}_t$!;
    my($fields) = $self->{$_PACKAGE} = {
	'table_name' => $table_name,
    };
    my($columns) = $fields->{columns} = {};
    # Sort the columns, so in a guaranteed order.  Makes for better
    # Oracle caching of prepared statements.
    my($column_names) = $fields->{column_names} = [sort keys %$column_cfg];
    my($primary_key_names) = $fields->{primary_key_names} = [];
    # Go through columns and
    my($n);
    foreach $n (@$column_names) {
	my($cfg) = $column_cfg->{$n};
	$columns->{$n} = {
	    name => $n,
	    type => $cfg->[0],
	    constraint => $cfg->[1],
	    sql_pos_param => $cfg->[0]->to_sql_value('?'),
	};
	push(@$primary_key_names, $n)
		if $columns->{$n}->{is_primary_key}
			= $cfg->[1] eq Bivio::SQL::Constraint::PRIMARY_KEY();
    }
    Carp::croak("$table_name: no primary keys")
		unless int(@$primary_key_names);
    # Cache as much of the statements as possible
    $fields->{select} = 'select '.join (',', map {
	$columns->{$_}->{type}->from_sql_value($_)
    } @$column_names)." from $table_name where ";
    $fields->{insert} = "insert into $table_name ("
	    .join(',', @$column_names).') values ('
	    .join(',', map {$columns->{$_}->{sql_pos_param}} @$column_names)
	    .')';
    $fields->{primary_where} = ' where ' . join(' and ',
	    map {$_.'='.$columns->{$_}->{sql_pos_param}}
	    @{$primary_key_names});
    $fields->{delete} = "delete from $table_name ".$fields->{primary_where};
    $fields->{update} = "update $table_name set ";
    my($primary_id_name) = $fields->{table_name};
    $primary_id_name =~ s/_t$/_id/;
    if ($columns->{$primary_id_name}) {
	$fields->{primary_id_name} = $primary_id_name;
	$fields->{next_primary_id} = 'select '
		. substr($fields->{table_name}, 0, -2)
		. '_s.nextval from dual';
    }
    return $self;
}

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(hash new_values)

=head2 create(hash new_values, ref die)

Inserts a new record into to database and loads the model's properties.
Dies on errors.

If there is a I<primary_id_column>, the value will be retrieved from
the sequence I<table_name_s> (table_name sans '_t', that is).

I<die> must implement L<Bivio::Die::die|Bivio::Die/"die">.

=cut

sub create {
    my($self, $new_values, $die) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($sql) = $fields->{insert};
    my($columns) = $fields->{columns};
    $new_values->{$fields->{primary_id_name}}
	    = _next_primary_id($self, $die)
		    if $fields->{primary_id_name};
    # map is faster than foreach in this case
    my(@params) = map {
	$columns->{$_}->{type}->to_sql_param($new_values->{$_});
    } @{$fields->{column_names}};
    Bivio::SQL::Connection->execute($sql, \@params, $die);
    return;
}

=for html <a name="delete"></a>

=head2 delete(hash_ref old_values)

=head2 delete(hash_ref old_values, ref die)

Removes the row with identified by the specified parameterized where_clause
and substitution values. If an error occurs during the delete, calls die.

I<die> must implement L<Bivio::Die::die|Bivio::Die/"die">.

=cut

sub delete {
    my($self, $old_values, $die) = @_;
    my($fields) = $self->{$_PACKAGE};
    my(@params) = map {
	$old_values->{$_};
    } @{$fields->{primary_key_names}};
    Bivio::SQL::Connection->execute($fields->{delete}, \@params, $die);
    return;
}

=for html <a name="get_column_names"></a>

=head2 get_column_names() : array_ref

Returns the list of the columns by reference.  Don't modify.

=cut

sub get_column_names {
    return shift->{$_PACKAGE}->{column_names};
}

=for html <a name="get_column_type"></a>

=head2 get_column_type(string name) : Bivio::Type

Returns the type of the column.

=cut

sub get_column_type {
    my($columns) = shift->{$_PACKAGE}->{columns};
    my($name) = shift;
    my($col) = $columns->{$name};
    Carp::croak("$name: no such column") unless $col;
    return $col->{type};
}

=for html <a name="get_primary_key_names"></a>

=head2 get_primary_key_names() : array_ref

Returns the list of the primary keys by reference.  Don't modify.

=cut

sub get_primary_key_names {
    return shift->{$_PACKAGE}->{primary_key_names};
}

=for html <a name="has_columns"></a>

=head2 has_columns(string column_name, ...) : boolean

Does the table have the specified columns

=cut

sub has_columns {
    my($columns) = shift->{$_PACKAGE}->{columns};
    my($n);
    foreach $n (@_) {
	return 0 unless exists($columns->{$n});
    }
    return 1;
}

=for html <a name="find"></a>

=head2 unsafe_load(hash_ref query) : hash_ref

=head2 unsafe_load(hash_ref query, ref die) : hash_ref

Loads the specified properties with data using the parameterized where_clause
and substitution values. If successful, the values hash will returned.
Returns undef if no rows were returned.

I<die> must implement L<Bivio::Die::die|Bivio::Die/"die">.

=cut

sub unsafe_load {
    my($self, $query, $die) = @_;
    # Create the where clause and values array
    my($fields) = $self->{$_PACKAGE};
    my($columns) = $fields->{columns};
    my(@params);
    my($sql) = $fields->{select}.join(' and ', map {
	my($column) = $columns->{$_};
	Carp::croak('invalid field name') unless $column;
	push(@params, $query->{$_});
	$_.'='.$column->{sql_pos_param};
	# Use a sort to force order which (may) help Oracle's cache.
    } sort keys(%$query));
    my($statement) = Bivio::SQL::Connection->execute($sql, \@params, $die);
    my($start_time) = $_TRACE ? Bivio::Util::gettimeofday() : 0;
    my($row) = $statement->fetchrow_arrayref();
    my($too_many) = $statement->fetchrow_array ? 1 : 0 if $row;
    Bivio::SQL::Connection->increment_db_time($start_time) if $_TRACE;
    my($values);
    if ($row) {
	die('too many rows returned') if $too_many;
	my($columns) = $fields->{columns};
	my($i) = 0;
	$values = {map {
	    ($_, $columns->{$_}->{type}->from_sql_column($row->[$i++]));
	} @{$fields->{column_names}}};
    }
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
    my($fields) = $self->{$_PACKAGE};
    my($columns) = $fields->{columns};
    my($set);
    my(@params);
    my($n);
    foreach $n (@{$fields->{column_names}}) {
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
	next if _equals($old, $new);
	$set .= $n.'='.$column->{sql_pos_param}.',';
	push(@params, $column->{type}->to_sql_param($new));
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
    foreach $n (@{$fields->{primary_key_names}}) {
	push(@params, $columns->{$n}->{type}->to_sql_param($old_values->{$n}));
    }
    Bivio::SQL::Connection->execute(
	    $fields->{update}.$set.$fields->{primary_where}, \@params, $die);
    return;
}

#=PRIVATE METHODS

# _equals(scalar v, scalar v2) : boolean
#
# Returns true if v is exactly the same as v2

sub _equals {
    my($v, $v2) = @_;
    return 0 if defined($v) != defined($v2);
    return 1 unless defined($v);  # both undefined
    return $v eq $v2;
}

# _next_primary_id(Bivio::SQL::Support self, ref die) : string
#
# Returns the next primary key id for this table
sub _next_primary_id {
    my($self, $die) = @_;
    my($fields) = $self->{$_PACKAGE};
    return Bivio::SQL::Connection->execute($fields->{next_primary_id},
	    $_EMPTY_ARRAY, $die)->fetchrow_array;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
