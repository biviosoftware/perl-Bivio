# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::SqlSupport;
use strict;
$Bivio::Biz::SqlSupport::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Biz::SqlSupport - sql support for Models

=head1 SYNOPSIS

    package MyModel;

    my($support) = Bivio::Biz::SqlSupport->new('user_', {
        id => 'id',
        name => 'name',
        password => 'password'
        });
    $support->create($self, $self->internal_get_fields(),
        {id => 100, foo => 'xxx'});

=cut

use Bivio::UNIVERSAL;
@Bivio::Biz::SqlSupport::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Biz::SqlSupport> is SQL transaction support for
L<Bivio::Biz::PropertyModel>s. PropertyModel life-cycle methods are
supported throught L<"find">, L<"create">, L<"delete">, and L<"update">.

SqlSupport uses the L<Bivio::Biz:SqlConnection> for connections and
statement execution.

=cut

=for html <a name="DATE_FORMAT"></a>

=head2 DATE_FORMAT : string

Returns the date format for sql statements. MM/DD/YYYY

=cut

sub DATE_FORMAT {
    return 'MM/DD/YYYY';
}

=for html <a name="SQL_DATE_TYPE"></a>

=head2 SQL_DATE_TYPE : int

Returns the internal oracle sql date id.

=cut

sub SQL_DATE_TYPE {
    return 9;
}

#=IMPORTS
use Bivio::Biz::SqlConnection;
use Bivio::IO::Trace;
use Bivio::Util;
use Carp();

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string table_name, hash field_map) : Bivio::Biz::SqlSupport

Creates a SQL support instance. field_map should be a model property to
sql column name mapping, format:
    {
        property-name => column-name(s),
        ...
    }

=cut

sub new {
    my($proto, $table_name, $field_map) = @_;
    my($self) = &Bivio::UNIVERSAL::new($proto);
    my(@columns) = values(%{$field_map});

    $self->{$_PACKAGE} = {
	table_name => $table_name,
	select => undef,
	delete => 'delete from '.$table_name.' ',
	insert => undef,
	field_map => $field_map,
	columns => \@columns,
	column_types => undef
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
    my($conn) = Bivio::Biz::SqlConnection->get_connection();
    my($sql) = $fields->{insert};

    my($field_map) = $fields->{field_map};
    my(@values);
    foreach (keys(%$field_map)) {
	push(@values, $new_values->{$_});
    }

    &_trace_sql($sql, @values) if $_TRACE;

    # not using prepare_cached
    my($statement) = $conn->prepare($sql);

    Bivio::Biz::SqlConnection->execute($statement, $model, @values);
    $statement->finish();

    if ($model->get_status()->is_OK()) {
	# update all the model properties, undefined fields as well
	foreach (keys(%$properties)) {
	    $properties->{$_} = $new_values->{$_};
	}
    }

    if ($_TRACE) {
	Bivio::Biz::SqlConnection->increment_db_time(
		Bivio::Util::time_delta_in_seconds($start_time));
    }
    return $model->get_status()->is_OK();
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
    my($conn) =  Bivio::Biz::SqlConnection->get_connection();
    my($sql) = $fields->{delete}.$where_clause;
    &_trace_sql($sql, @values) if $_TRACE;

    # not using prepare_cached
    my($statement) = $conn->prepare($sql);

    Bivio::Biz::SqlConnection->execute($statement, $model, @values);

    $statement->finish();

    if ($_TRACE) {
	Bivio::Biz::SqlConnection->increment_db_time(
		Bivio::Util::time_delta_in_seconds($start_time));
    }
    return $model->get_status()->is_OK();
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

    foreach (@$columns) {
	if ($types->{$_} == SQL_DATE_TYPE()) {
	    $select .= qq{TO_CHAR($_,'}.DATE_FORMAT().q{'),};
	    $insert .= q{TO_DATE(?,'}.DATE_FORMAT().q{'),};
	}
	else {
	    $select .= $_.',';
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
    my($conn) =  Bivio::Biz::SqlConnection->get_connection();
    my($sql) = $fields->{select}.$where_clause;
    &_trace_sql($sql, @values) if $_TRACE;
    my($statement) = $conn->prepare_cached($sql);

    Bivio::Biz::SqlConnection->execute($statement, $model, @values);

    my($row) = $statement->fetchrow_arrayref();

    if ($row) {
	my(@fields) = keys(%{$fields->{field_map}});

	for (my($i) = 0; $i < scalar(@fields); $i++) {
	    $properties->{$fields[$i]} = $row->[$i];
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
	Bivio::Biz::SqlConnection->increment_db_time(
		Bivio::Util::time_delta_in_seconds($start_time));
    }
    return $model->get_status()->is_OK();
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

    my($conn) =  Bivio::Biz::SqlConnection->get_connection();

    # not using prepare_cached
    my($statement) = $conn->prepare($sql);

    Bivio::Biz::SqlConnection->execute($statement, $model, @values);

    $statement->finish();

    if ($model->get_status()->is_OK()) {
	# update the model properties
	foreach (keys(%$new_values)) {
	    $properties->{$_} = $new_values->{$_};
	}
    }
    if ($_TRACE) {
	Bivio::Biz::SqlConnection->increment_db_time(
		Bivio::Util::time_delta_in_seconds($start_time));
    }
    return $model->get_status()->is_OK();
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
    my($field_map) = $fields->{field_map};
    my($column_types) = $fields->{column_types};

    # used for quote()
#    my($conn) =  Bivio::Biz::SqlConnection->get_connection();

    my($cols);
    my($name);
    foreach $name (keys(%$new_values)) {
	my($old) = $old_values->{$name};
	my($new) = $new_values->{$name};

	# lots of extra comparison to avoid undef warning

	if (defined($old) != defined($new) || ($old && $new && $old ne $new)) {
	    my($col_name) = $field_map->{$name};
	    my($type) = $column_types->{$col_name};
	    $cols .= $col_name.'=';

	    if ($type == SQL_DATE_TYPE()) {
		$cols .= qq{TO_DATE('$new','}.DATE_FORMAT().q{'),};
	    }
	    else {
#		$cols .= $conn->quote($new, $column_types->{$col_name}).',';

		# just quote everything - avoid numeric '' problem
		$cols .= qq{'$new',};
	    }
	}
    }

    # check if any changes required
    $cols || return '';

    # remove the extra ',' from cols
    chop($cols);
    return 'update '.$fields->{table_name}.' set '.$cols.' '.$where_clause;
}

# _get_column_types(string table_name, array fields) : hash
#
# Gets metadata for the columns and adds the type info to a hash. The
# result is keyed by column.

sub _get_column_types {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($conn) =  Bivio::Biz::SqlConnection->get_connection();
    my($sql) = 'select '.join(',', @{$fields->{columns}})
	    .' from '.$fields->{table_name};

    &_trace($sql) if $_TRACE;

    my($statement) = $conn->prepare($sql);

    my($names) = $statement->{NAME_lc};
    my($types) = $statement->{TYPE};

    my($column_types) = {};

    for (my($i) = 0; $i < scalar(@$names); $i++) {
	$column_types->{$names->[$i]} = $types->[$i];
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
    for (my($i) = 0; $i < scalar(@values); $i++) {
	$sql .= defined($values[$i]) ? $values[$i] : 'undef';
	$sql .= ',';
    }
    chop($sql);
    $sql .= ')';

    &_trace($sql);
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
