# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::SQL::ListSupport;
use strict;
$Bivio::SQL::ListSupport::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::SQL::ListSupport - sql support for ListModels

=head1 SYNOPSIS

    package MyListModel;

    use Bivio::SQL::ListSupport;
    my($support) = Bivio::SQL::ListSupport->new('mail_message',
	['id,subject', 'from_name,from_email,subject', 'dttm']);

    support->load($self, $self->internal_get_rows()
        $fields->{index}, 15, 'where club=?'.$self->get_order_by($fp),
	$fp->get('club'));

=cut

use Bivio::UNIVERSAL;
@Bivio::SQL::ListSupport::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::SQL::ListSupport> provides SQL database access for
L<Bivio::Biz::ListModel>s.

ListSupport uses the L<Bivio::SQL::Connection> for connections and
statement execution.

=cut

# For now has to be here, because want to checkin intermediate with
# new SQL::Support and old ListSupport
sub UNIX_EPOCH_IN_JULIAN_DAYS {
    return 2440588;
}
sub SECONDS_IN_DAY {
    return 86400;
}

sub SQL_DATE_TYPE {
    return 9;
}
sub DATE_FORMAT {
    return 'J SSSSS';
}


#=IMPORTS
use Bivio::SQL::Connection;
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

=head2 static new(string table_name, array col_map) : Bivio::SQL::ListSupport

Creates a SQL list support instance. col_map should be an array of sql
column names for loading data.

=cut

sub new {
    my($proto, $table_name, $col_map) = @_;
    my($self) = &Bivio::UNIVERSAL::new($proto);

    # number of fields per column entry
    my($col_field_count) = [];
    my($n);
    foreach (@$col_map) {
	push(@$col_field_count, &_count_occurances($n, ',') + 1);
    }

    $self->{$_PACKAGE} = {
	'select' => undef,
	'count' => 'select count(*) from '.$table_name.' ',
	'col_field_count' => $col_field_count,
	'col_map' => $col_map,
	'table_name' => $table_name
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="find"></a>

=head2 load(ListModel model, array rows, int index, int max, string where_clause, string value, ...) : boolean

Loads the specified rows with data using the parameterized where_clause
and substitution values. At most the specified max rows will be loaded.
Data will be loaded starting at the specified index into the result set.

=cut

sub load {
    my($self, $model, $rows, $index, $max, $where_clause, @values) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{select} || Carp::croak("SqlListSupport not initialized");

    my($col_field_count) = $fields->{col_field_count};

    # clear the result set
    my(@a) = @$rows;
    $#a = 0;

    my($sql) = $fields->{select}.$where_clause;
    &_trace($sql, ' (', join(',', @values), ')') if $_TRACE;
    my($statement) = Bivio::SQL::Connection->execute($sql, \@values, $model);
    my($start_time) = $_TRACE ? Bivio::Util::gettimeofday() : 0;

    my($row);
    my($i) = 0;
    my($count) = 0;
    my($types) = $fields->{types};
    while ($row = $statement->fetchrow_arrayref()) {

	# advance to the start index
	if ($count++ < $index) {
	    next;
	}

	my($col) = 0;
	for (my($j) = 0; $j < int(@$col_field_count); $j++) {
	    my($val);
	    if ($col_field_count->[$j] == 1 ) {
		$val = &_convert_value($types, $col, $row->[$col]);
		$col++;
	    }
	    else {
		$val = [];
		for (my($k) = 0; $k < $col_field_count->[$j]; $k++) {
		    push(@$val, &_convert_value($types, $col, $row->[$col]));
		    $col++;
		}
	    }
	    $rows->[$i]->[$j] = $val;
	}

	# check if page is loaded
	if (++$i >= $max) {
	    last;
	}
    }
    # Do we need to finish here?
    $statement->finish();

    if ($_TRACE) {
	Bivio::SQL::Connection->increment_db_time($start_time);
    }
    return;
}

=for html <a name="get_result_set_size"></a>

=head2 get_result_set_size(Model model, string where_clause, string value, ...) : int

Returns the number of records in the result set for the specified where
clause and value substitution. If an error occurs during the query, an
error will be added to the model's status.

=cut

sub get_result_set_size {
    my($self, $model, $where_clause, @values) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{select} || Carp::croak("SqlListSupport not initialized");

    my($sql) = $fields->{count}.$where_clause;
    &_trace($sql, ' (', join(',', @values), ')') if $_TRACE;
    my($statement) = Bivio::SQL::Connection->execute($sql, \@values, $model);

    my($start_time) = $_TRACE ? Bivio::Util::gettimeofday() : 0;
    my($result) = $statement->fetchrow_arrayref()->[0];
    $statement->finish();

    if ($_TRACE) {
	Bivio::SQL::Connection->increment_db_time($start_time);
    }
    return $result;
}

=for html <a name="initialize"></a>

=head2 initialize()

Gets type information from the database. Executed only once per instance.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    # check if already initialized
    return if $fields->{select};

    my($conn) =  Bivio::SQL::Connection->get_connection();
    my($sql) = 'select '.join(',', @{$fields->{col_map}})
	    .' from '.$fields->{table_name};

    &_trace($sql) if $_TRACE;

    my($statement) = $conn->prepare($sql);
    my($names) = $statement->{NAME_lc};
    my($types) = $statement->{TYPE};
    $fields->{types} = $types;

    my($select) = 'select ';
    for(my($i) = 0; $i < int(@$names); $i++) {
	if ($types->[$i] == SQL_DATE_TYPE()) {
	    $select .= 'TO_CHAR('.$names->[$i].",'"
		    .DATE_FORMAT()."'),";
	}
	else {
	    $select .= $names->[$i].',';
	}
    }

    $statement->finish();

    # remove extra ','
    chop($select);

    $select .= ' from '.$fields->{table_name}.' ';
    $fields->{select} = $select;
    return;
}

#=PRIVATE METHODS

sub _convert_value {
    my($types, $index, $value) = @_;
    return $types->[$index] == SQL_DATE_TYPE()
	    ? _to_time($value) : $value;
}

sub _to_time {
    my(undef, $sql_date) = @_;
    defined($sql_date) || return undef;
    # BTW, I tried "eval '111+5555'" here and it was MUCH slower.
    my($j, $s) = split(/ /, $sql_date);
    return ($j - &UNIX_EPOCH_IN_JULIAN_DAYS) * &SECONDS_IN_DAY + $s;
}

# _count_occurances(string str, string search) : int
#
# Returns the number of occurances of the specified value within a string.
#
sub _count_occurances {
    my($str, $search) = @_;

    my($count) = 0;
    my($pos) = -1;
    while (($pos = index($str, $search, $pos)) > -1) {
	$count++;
	$pos++;
    }
    return $count;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
