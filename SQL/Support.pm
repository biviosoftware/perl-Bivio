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

    $self->{$_PACKAGE} = {
	'table_name' => $table_name,
	'select' => undef,
	'delete' => 'delete from '.$table_name.' ',
	'insert' => undef,
	'columns' => \@columns,
	'column_types' => undef,
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(Model model, hash properties, hash new_values) : boolean

Inserts a new record into to database and loads the model's properties. If
successful, the properties hash will contain the new values. Otherwise
the model's L<Bivio::Biz::Status> will contain error messages.

=cut

sub create {
    my($self, $model, $properties, $new_values) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{column_types} || Carp::croak("SqlSupport not initialized");

    my($start_time) = $_TRACE ? Bivio::Util::gettimeofday() : 0;
    my($conn) = Bivio::SQL::Connection->get_connection();
    my($sql) = $fields->{insert};

    my($columns) = $fields->{columns};
    my($types) = $fields->{column_types};
    my(@values);

    for (my($i) = 0; $i < int(@$columns); $i++) {
	my($col) = $columns->[$i];
	push(@values, $types->[$i] == SQL_DATE_TYPE()
		? $self->from_time($new_values->{$col}) : $new_values->{$col});
    }

    &_trace_sql($sql, @values) if $_TRACE;

    # not using prepare_cached
    my($statement) = $conn->prepare($sql);

    Bivio::SQL::Connection->execute($statement, $model, @values);
    $statement->finish();

    if ($model->get_status()->is_ok()) {
	# update all the model properties, undefined fields as well
	foreach (keys(%$properties)) {
	    $properties->{$_} = $new_values->{$_};
	}
    }

    if ($_TRACE) {
	Bivio::SQL::Connection->increment_db_time(
		Bivio::Util::time_delta_in_seconds($start_time));
    }
    return $model->get_status()->is_ok();
}

=for html <a name="delete"></a>

=head2 delete(Model m, string where_clause, string value, ...) : boolean

Removes the row with identified by the specified parameterized where_clause
and substitution values. If an error occurs during the delete, the
model's L<Bivio::Biz::Status> will contain the error messages.

=cut

sub delete {
    my($self, $model, $where_clause, @values) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{column_types} || Carp::croak("SqlSupport not initialized");

    my($start_time) = $_TRACE ? Bivio::Util::gettimeofday() : 0;
    my($conn) =  Bivio::SQL::Connection->get_connection();
    my($sql) = $fields->{delete}.$where_clause;
    &_trace_sql($sql, @values) if $_TRACE;

    # not using prepare_cached
    my($statement) = $conn->prepare($sql);

    Bivio::SQL::Connection->execute($statement, $model, @values);

    $statement->finish();

    if ($_TRACE) {
	Bivio::SQL::Connection->increment_db_time(
		Bivio::Util::time_delta_in_seconds($start_time));
    }
    return $model->get_status()->is_ok();
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

    for (my($i) = 0; $i < int(@$columns); $i++) {
	my($col) = $columns->[$i];

	if ($types->[$i] == SQL_DATE_TYPE()) {
	    $select .= qq{TO_CHAR($col,'}.DATE_FORMAT().q{'),};
	    $insert .= q{TO_DATE(?,'}.DATE_FORMAT().q{'),};
	}
	else {
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

=head2 find(PropertyModel model, hash properties, string where_clause, string value, ...) : boolean

Loads the specified properties with data using the parameterized where_clause
and substitution values. If successful, the properties hash will contain the
new values. Otherwise the model's L<Bivio::Biz::Status> will contain error
messages.

=cut

sub find {
    my($self, $model, $properties, $where_clause, @values) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{column_types} || Carp::croak("SqlSupport not initialized");

    my($start_time) = $_TRACE ? Bivio::Util::gettimeofday() : 0;
    my($conn) =  Bivio::SQL::Connection->get_connection();
    my($sql) = $fields->{select}.$where_clause;
    &_trace_sql($sql, @values) if $_TRACE;
    my($statement) = $conn->prepare_cached($sql);

    Bivio::SQL::Connection->execute($statement, $model, @values);

    my($row) = $statement->fetchrow_arrayref();

    if ($row) {
	my($columns) = $fields->{columns};
	my($types) = $fields->{column_types};

	for (my($i) = 0; $i < int(@$columns); $i++) {
	    my($col) = $columns->[$i];
	    $properties->{$col} = $types->[$i] == SQL_DATE_TYPE()
		    ? $self->to_time($row->[$i]) : $row->[$i];
	}

#TODO: die if > 1 row returned.
    }
    else {

#TODO: need a better error than this

	$model->get_status()->add_error(
		Bivio::Biz::Error->new("Not Found"));
    }
    $statement->finish();
    if ($_TRACE) {
	Bivio::SQL::Connection->increment_db_time(
		Bivio::Util::time_delta_in_seconds($start_time));
    }
    return $model->get_status()->is_ok();
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

=head2 update(Model model, hash properties, hash new_values, string where_clause, string value, ...) : boolean

Updates the database fields for the specified model. If successful, values
will be mapped into the specified properties hash. Otherwise the model's
L<Bivio::Biz::Statis> will contain any error messages.

=cut

sub update {
    my($self, $model, $properties, $new_values, $where_clause, @values) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{column_types} || Carp::croak("SqlSupport not initialized");

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

    $statement->finish();

    if ($model->get_status()->is_ok()) {
	# update the model properties
	foreach (keys(%$new_values)) {
	    $properties->{$_} = $new_values->{$_};
	}
    }
    if ($_TRACE) {
	Bivio::SQL::Connection->increment_db_time(
		Bivio::Util::time_delta_in_seconds($start_time));
    }
    return $model->get_status()->is_ok();
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

    $statement->finish();
    return $column_types;
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
