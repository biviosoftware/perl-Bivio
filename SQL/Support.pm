# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::SQL::Support;
use strict;
$Bivio::SQL::Support::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::SQL::Support - sql support for Models

=head1 SYNOPSIS

    package MyModel;

    my($support) = Bivio::SQL::Support->new('user_',
        ('id', 'name', 'password'));

    $support->create($self, $self->internal_get_fields(),
        {'id' => 100, 'name' => 'foo'});

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

=for html <a name="DATE_FORMAT"></a>

=head2 DATE_FORMAT : string

Returns the date format for sql statements.  See the functions
L<to_time|"to_time"> and L<from_time|"from_time"> to convert
to/from unix time (seconds since epoch).

=cut

sub DATE_FORMAT {
    return 'J SSSSS';
}

=for html <a name="SECONDS_IN_DAY"></a>

=head2 SECONDS_IN_DAY : int

Returns the number of seconds in a day

=cut

sub SECONDS_IN_DAY {
    return 86400;
}

=for html <a name="SQL_DATE_TYPE"></a>

=head2 SQL_DATE_TYPE : int

Returns the internal oracle sql date id.

=cut

sub SQL_DATE_TYPE {
    return 9;
}

=for html <a name="SQL_NUMERIC_TYPE"></a>

=head2 SQL_NUMERIC_TYPE : int

Returns the internal oracle sql numeric id.

=cut

sub SQL_NUMERIC_TYPE {
    return 3;
}

=for html <a name="UNIX_EPOCH_IN_JULIAN_DAYS"></a>

=head2 UNIX_EPOCH_IN_JULIAN_DAYS : int

Number of days between the unix and julian epoch

=cut

sub UNIX_EPOCH_IN_JULIAN_DAYS {
    return 2440588;
}

#=IMPORTS
use Bivio::SQL::Connection;
use Bivio::IO::Trace;
use Bivio::Util;
use Carp ();

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string table_name, string column, ...) : Bivio::SQL::Support

Creates a SQL support instance. columns should be a list of sql column
names which correspond to the same named model property.

=cut

sub new {
    my($proto, $table_name, @columns) = @_;
    my($self) = &Bivio::UNIVERSAL::new($proto);
    $table_name =~ /_t$/i
	    || Carp::croak("$table_name: invalid table name, must end in _t");
    $self->{$_PACKAGE} = {
	'table_name' => $table_name,
	'select' => undef,
	'delete' => 'delete from '.$table_name.' ',
	'insert' => undef,
	'columns' => \@columns,
	'column_types' => undef,
	'primary_id_column' => -1,
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(Model model, hash properties, hash new_values)

Inserts a new record into to database and loads the model's properties. If
successful, the properties hash will contain the new values. Otherwise,
it dies with the error.

If there is a I<primary_id_column>, the value will be retrieved from
the sequence I<table_name_s> (table_name sans '_t', that is).

=cut

sub create {
    my($self, $model, $properties, $new_values) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{column_types} || Carp::croak("not initialized");

    my($start_time) = $_TRACE ? Bivio::Util::gettimeofday() : 0;
    my($conn) = Bivio::SQL::Connection->get_connection();
    my($sql) = $fields->{insert};

    my($columns) = $fields->{columns};
    my($types) = $fields->{column_types};
    my($primary_id_column) = $fields->{primary_id_column};
    my(@values);

    for (my($i) = 0; $i < int(@$columns); $i++) {
	my($col) = $columns->[$i];
	push(@values, $types->[$i] == SQL_DATE_TYPE()
		? $self->from_time($new_values->{$col})
                : $primary_id_column eq $i
		? ($new_values->{$col} = _next_primary_id($self, $model, $conn))
		: $new_values->{$col});
    }

    &_trace_sql($sql, @values) if $_TRACE;

    # not using prepare_cached
    my($statement) = $conn->prepare($sql);

    Bivio::SQL::Connection->execute($statement, $model, @values);
    # update all the model properties, undefined fields as well
    foreach (keys(%$properties)) {
	$properties->{$_} = $new_values->{$_};
    }
    if ($_TRACE) {
	Bivio::SQL::Connection->increment_db_time(
		Bivio::Util::time_delta_in_seconds($start_time));
    }
    return;
}

=for html <a name="delete"></a>

=head2 delete(Model m, string where_clause, string value, ...)

Removes the row with identified by the specified parameterized where_clause
and substitution values. If an error occurs during the delete, calls die.

=cut

sub delete {
    my($self, $model, $where_clause, @values) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{column_types} || Carp::croak("not initialized");

    my($start_time) = $_TRACE ? Bivio::Util::gettimeofday() : 0;
    my($conn) =  Bivio::SQL::Connection->get_connection();
    my($sql) = $fields->{delete}.$where_clause;
    &_trace_sql($sql, @values) if $_TRACE;

    # not using prepare_cached
    my($statement) = $conn->prepare($sql);

    Bivio::SQL::Connection->execute($statement, $model, @values);

    if ($_TRACE) {
	Bivio::SQL::Connection->increment_db_time(
		Bivio::Util::time_delta_in_seconds($start_time));
    }
    return;
}

=for html <a name="from_time"></a>

=head2 static from_time(int time) : string

Returns an SQL TO_DATE in L<DATE_FORMAT|"DATE_FORMAT"> from a unix
time (seconds since epoch).

Handles C<undef> properly.

=cut

sub from_time {
    my(undef, $time) = @_;
    defined($time) || return 'NULL';
    my($s) = $time % &SECONDS_IN_DAY;
    my($j) = int($time / &SECONDS_IN_DAY) + &UNIX_EPOCH_IN_JULIAN_DAYS;
    return $j . ' ' . $s;
}

=for html <a name="get_primary_id_field"></a>

=head2 get_primary_id_field() : string

Returns the primary id (key) field.  The primary id field is
a field which is named after the table, but instead of ending
in '_t', it ends in '_id'.  Primary ids are always integers
and are never 0.

=cut

sub get_primary_id_field {
    my($self) = @_;
    return $self->{primary_id_column} >= 0 ?
	    $self->{columns}->{$self->{primary_id_column}} : undef;
}

=for html <a name="initialize"></a>

=head2 initialize()

Gets type information from the database. Executed only once per instance.
This method must be called after the constructor, before any other method
is invoked.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    # check if already initialized
    return if $fields->{column_types};

    $fields->{column_types} = &_get_column_types($self);

    my($columns) = $fields->{columns};
    my($types) = $fields->{column_types};

    # create the select and insert statements
    my($select) = 'select ';
    my($insert) = 'insert into '.$fields->{table_name}
	    .' ('.join(',', @$columns).') values (';
    $fields->{primary_id_column} = -1;
    my($id_name) = $fields->{table_name};
    $id_name =~ s/_t$/_id/;
    for (my($i) = 0; $i < int(@$columns); $i++) {
	my($col) = $columns->[$i];
	if ($types->[$i] == SQL_DATE_TYPE()) {
	    $select .= qq{TO_CHAR($col,'}.DATE_FORMAT().q{'),};
	    $insert .= q{TO_DATE(?,'}.DATE_FORMAT().q{'),};
	}
	else {
	    if ($col eq $id_name) {
		$fields->{primary_id_column} = $i;
		($fields->{next_primary_id} = 'select '
			# Trim _t which is required (see create)
			. substr($fields->{table_name}, 0, -2)
			. '_s.nextval from dual');
	    }
	    $select .= $col.',';
	    $insert .= '?,';
	}
    }
    # remove extra ','
    chop($select);
    chop($insert);

    $select .= ' from '.$fields->{table_name}.' ';
    $fields->{select} = $select;
    $insert .= ')';
    $fields->{insert} = $insert;
    return;
}

=for html <a name="find"></a>

=head2 unsafe_load(PropertyModel model, hash properties, string where_clause, string value, ...) : boolean

Loads the specified properties with data using the parameterized where_clause
and substitution values. If successful, the properties hash will contain the
new values.  Returns false if no rows were returned.

=cut

sub unsafe_load {
    my($self, $model, $properties, $where_clause, @values) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{column_types} || Carp::croak("not initialized");

    my($start_time) = $_TRACE ? Bivio::Util::gettimeofday() : 0;
    my($conn) =  Bivio::SQL::Connection->get_connection();
    my($sql) = $fields->{select}.$where_clause;
    &_trace_sql($sql, @values) if $_TRACE;

    my($statement) = $conn->prepare_cached($sql);
    Bivio::SQL::Connection->execute($statement, $model, @values);
    my($row) = $statement->fetchrow_arrayref();
    my($too_many) = $statement->fetchrow_array ? 1 : 0 if $row;
    # Must call finish here, because statement is cached
    $statement->finish;

    if ($row) {
	die('too many rows returned') if $too_many;
	my($columns) = $fields->{columns};
	my($types) = $fields->{column_types};

	for (my($i) = 0; $i < int(@$columns); $i++) {
	    my($col) = $columns->[$i];
	    $properties->{$col} = $types->[$i] == SQL_DATE_TYPE()
		    ? $self->to_time($row->[$i]) : $row->[$i];
	}
    }
    if ($_TRACE) {
	Bivio::SQL::Connection->increment_db_time(
		Bivio::Util::time_delta_in_seconds($start_time));
    }
    return $row ? 1 : 0;
}

=for html <a name="to_time"></a>

=head2 static to_time(string sql_date) : int

Converts an sql date in L<DATE_FORMAT|"DATE_FORMAT"> to unix time
(seconds since epoch).

Handles C<undef> properly.

=cut

sub to_time {
    my(undef, $sql_date) = @_;
    defined($sql_date) || return undef;
    # BTW, I tried "eval '111+5555'" here and it was MUCH slower.
    my($j, $s) = split(/ /, $sql_date);
    return ($j - &UNIX_EPOCH_IN_JULIAN_DAYS) * &SECONDS_IN_DAY + $s;
}

=for html <a name="update"></a>

=head2 update(Model model, hash properties, hash new_values, string where_clause, string value, ...)

Updates the database fields for the specified model. If successful, values
will be mapped into the specified properties hash. Otherwise, calls die.

=cut

sub update {
    my($self, $model, $properties, $new_values, $where_clause, @values) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{column_types} || Carp::croak("not initialized");

    my($start_time) = $_TRACE ? Bivio::Util::gettimeofday() : 0;
    my($sql) = &_create_update_statement($self, $properties, $new_values,
	    $where_clause);

    if (!$sql) {
	&_trace('no update required') if $_TRACE;
	return;
    }
    &_trace_sql($sql, @values) if $_TRACE;

    my($conn) =  Bivio::SQL::Connection->get_connection();

    # not using prepare_cached
    my($statement) = $conn->prepare($sql);

    Bivio::SQL::Connection->execute($statement, $model, @values);
    # update the model properties
    foreach (keys(%$new_values)) {
	$properties->{$_} = $new_values->{$_};
    }
    if ($_TRACE) {
	Bivio::SQL::Connection->increment_db_time(
		Bivio::Util::time_delta_in_seconds($start_time));
    }
    return;
}

#=PRIVATE METHODS

# _create_update_statement(hash old_values, hash new_values, string where_clause, string value, ...) : string
#
# Creates a minimal update string. If no changes need to be made then an
# empty string is returned.
#
sub _create_update_statement {
    my($self, $old_values, $new_values, $where_clause) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($columns) = $fields->{columns};
    my($column_types) = $fields->{column_types};

    # used for quote()
    my($conn) =  Bivio::SQL::Connection->get_connection();

    my($set);

#TODO: Should understand primary keys
    for (my($i) = 0; $i < int(@$columns); $i++) {
	my($col) = $columns->[$i];
	my($old) = $old_values->{$col};
	my($new) = $new_values->{$col};

	if (! &_equals($old, $new)) {
	    $set .= $col.'=';
	    my($type) = $column_types->[$i];

	    if (! defined($new)) {
		$set .= 'NULL,';
	    }
	    elsif ($type == SQL_DATE_TYPE()) {
		$set .=  "TO_DATE('" . $self->from_time($new)
			. "','" . DATE_FORMAT() . "'),";
	    }
	    elsif ($type == SQL_NUMERIC_TYPE()) {
#TODO: need a policy for validating numerics

		# hack - replaces an unsafe bogus value with a safe bogus value
		$new =~ s/'/x/;
		$set .= qq{'$new',};
	    }
	    else {
		$set .= $conn->quote($new, $column_types->[$i]).',';
	    }
	}
    }

    # check if any changes required
    $set || return '';

    # remove the extra ',' from set
    chop($set);
    return 'update '.$fields->{table_name}.' set '.$set.' '.$where_clause;
}

# _equals(scalar v, scalar v2) : boolean
#
# Returns true if v is exactly the same as v2

sub _equals {
    my($v, $v2) = @_;

    return 0 if (defined($v) != defined($v2));
    return 1 if ! defined($v);  # both undefined

    return $v eq $v2;
}

# _get_column_types(string table_name, array fields) : array
#
# Gets metadata for the columns and adds the type info to an array.

sub _get_column_types {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($conn) =  Bivio::SQL::Connection->get_connection();
    my($sql) = 'select '.join(',', @{$fields->{columns}})
	    .' from '.$fields->{table_name};

    &_trace($sql) if $_TRACE;

    my($statement) = $conn->prepare($sql);
    my($types) = $statement->{TYPE};
    my($column_types) = [];

    for (my($i) = 0; $i < int(@$types); $i++) {
	$column_types->[$i] = $types->[$i];
    }

    return $column_types;
}

# _next_primary_id(Bivio::SQL::Support self, Bivio::Biz::Model model, Bivio::SQL::Connection conn) : int
#
# Returns the next primary key id for this table
sub _next_primary_id {
    my($self, $model, $conn) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($statement) = $conn->prepare($fields->{next_primary_id});
    &_trace($fields->{next_primary_id}) if $_TRACE;
    Bivio::SQL::Connection->execute($statement, $model);
    my($id) = $statement->fetchrow_array();
    return $id;
}

# _trace_sql(string sql, array values)
#
# Traces the specified sql statement with substitution values.

sub _trace_sql {
    my($sql, @values) = @_;

    $sql .= ' (';
    for (my($i) = 0; $i < int(@values); $i++) {
	$sql .= defined($values[$i]) ? $values[$i] : 'undef';
	$sql .= ',';
    }
    chop($sql);
    $sql .= ')';

    &_trace($sql);
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
