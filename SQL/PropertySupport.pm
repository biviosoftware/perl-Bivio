# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::SQL::PropertySupport;
use strict;
$Bivio::SQL::PropertySupport::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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
my($_EMPTY_ARRAY) = [];

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
    my($proto, $attrs) = @_;
    $proto->init_version($attrs, $attrs);
    my($table_name) = $attrs->{table_name};
    Carp::croak("$table_name: invalid table name, must end in _t")
		unless $table_name =~ m!^\w{1,28}_t$!;
    my($column_cfg) = $attrs->{columns};
    my($columns) = $attrs->{columns} = {};
    # Sort the columns, so in a guaranteed order.  Makes for better
    # Oracle caching of prepared statements.
    my($column_names) = $attrs->{column_names} = [sort(keys(%$column_cfg))];
    my($primary_key_names) = $attrs->{primary_key_names} = [];
    $attrs->{column_aliases} = {};
    # Go through columns and
    my($n);
    foreach $n (@$column_names) {
	my($cfg) = $column_cfg->{$n};
	$attrs->{column_aliases}->{$n} = $columns->{$n} = {
	    # Bivio::SQL::Support attributes
	    name => $n,
	    type => $cfg->[0],
	    constraint => $cfg->[1],

	    # Other attributes
	    sql_pos_param => $cfg->[0]->to_sql_value('?'),
	};
	push(@$primary_key_names, $n)
		if $columns->{$n}->{is_primary_key}
			= $cfg->[1] eq Bivio::SQL::Constraint::PRIMARY_KEY();
    }
    Carp::croak("$table_name: no primary keys")
		unless int(@$primary_key_names);

    # Convert auth_id to a column if it exists
    if ($attrs->{auth_id}) {
	Carp::croak($attrs->{auth_id}, ': auth_id not set')
		    unless $columns->{$attrs->{auth_id}};
	$attrs->{auth_id} = $columns->{$attrs->{auth_id}};
    }

    # Cache as much of the statements as possible
    $attrs->{select} = 'select '.join (',', map {
	$columns->{$_}->{type}->from_sql_value($_)
    } @$column_names)." from $table_name where ";
    $attrs->{insert} = "insert into $table_name ("
	    .join(',', @$column_names).') values ('
	    .join(',', map {$columns->{$_}->{sql_pos_param}} @$column_names)
	    .')';
    $attrs->{primary_where} = ' where ' . join(' and ',
	    map {$_.'='.$columns->{$_}->{sql_pos_param}}
	    @{$primary_key_names});
    $attrs->{delete} = "delete from $table_name ".$attrs->{primary_where};
    $attrs->{update} = "update $table_name set ";
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
the sequence I<table_name_s> (table_name sans '_t', that is).

I<die> must implement L<Bivio::Die::die|Bivio::Die/"die">.

=cut

sub create {
    my($self, $new_values, $die) = @_;
    my($attrs) = $self->internal_get;
    my($sql) = $attrs->{insert};
    my($columns) = $attrs->{columns};
    $new_values->{$attrs->{primary_id_name}}
	    = _next_primary_id($self, $die)
		    if $attrs->{primary_id_name};
    # map is faster than foreach in this case
    my(@params) = map {
	$columns->{$_}->{type}->to_sql_param($new_values->{$_});
    } @{$attrs->{column_names}};
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
    my($attrs) = $self->internal_get;
    my(@params) = map {
	$old_values->{$_};
    } @{$attrs->{primary_key_names}};
    Bivio::SQL::Connection->execute($attrs->{delete}, \@params, $die);
    return;
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
    # Create the where clause and values array
    my($attrs) = $self->internal_get;
    my($columns) = $attrs->{columns};
    my(@params);
    my($sql) = $attrs->{select}.join(' and ', map {
	my($column) = $columns->{$_};
	Carp::croak("invalid field name: $_") unless $column;
	push(@params, $column->{type}->to_sql_param($query->{$_}));
	$_.'='.$column->{sql_pos_param};
	# Use a sort to force order which (may) help Oracle's cache.
    } sort keys(%$query));
    my($statement) = Bivio::SQL::Connection->execute($sql, \@params, $die);
    my($start_time) = Bivio::Util::gettimeofday();
    my($row) = $statement->fetchrow_arrayref();
    my($too_many) = $statement->fetchrow_array ? 1 : 0 if $row;
    Bivio::SQL::Connection->increment_db_time($start_time);
    my($values);
    if ($row) {
	die('too many rows returned') if $too_many;
	my($columns) = $attrs->{columns};
	my($i) = 0;
	$values = {map {
	    ($_, $columns->{$_}->{type}->from_sql_column($row->[$i++]));
	} @{$attrs->{column_names}}};
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
    foreach $n (@{$attrs->{primary_key_names}}) {
	push(@params, $columns->{$n}->{type}->to_sql_param($old_values->{$n}));
    }
    Bivio::SQL::Connection->execute(
	    $attrs->{update}.$set.$attrs->{primary_where}, \@params, $die);
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

# _next_primary_id(Bivio::SQL::PropertySupport self, ref die) : string
#
# Returns the next primary key id for this table
sub _next_primary_id {
    my($self, $die) = @_;
    my($attrs) = $self->internal_get;
    return Bivio::SQL::Connection->execute($attrs->{next_primary_id},
	    $_EMPTY_ARRAY, $die)->fetchrow_array;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
