# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::SqlListSupport;
use strict;
$Bivio::Biz::SqlListSupport::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Biz::SqlListSupport - sql support for ListModels

=head1 SYNOPSIS

    use Bivio::Biz::SqlListSupport;
    Bivio::Biz::SqlListSupport->new();

=cut

use Bivio::UNIVERSAL;
@Bivio::Biz::SqlListSupport::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Biz::SqlListSupport>

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Biz::SqlConnection;
use Bivio::Biz::SqlSupport;
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

=head2 static new(string table_name, array col_map) : Bivio::Biz::SqlListSupport

Creates a SQL list support instance. col_map should be an array or sql
column names for loading data.

=cut

sub new {
    my($proto, $table_name, $col_map) = @_;
    my($self) = &Bivio::UNIVERSAL::new($proto);

    # number of fields per column entry
    my($col_field_count) = [];
    foreach (@$col_map) {
	push(@$col_field_count, &_count_occurances($_, ',') + 1);
    }

    $self->{$_PACKAGE} = {
	select => undef,
	count => 'select count(*) from '.$table_name.' ',
	col_field_count => $col_field_count,
	col_map => $col_map,
	table_name => $table_name
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="find"></a>

=head2 find(ListModel model, array rows, int index, int max, string where_clause, string value, ...) : boolean

Loads the specified rows with data using the parameterized where_clause
and substitution values. At most the specified max rows will be loaded.
Data will be loaded starting at the specified index into the result set.

=cut

sub find {
    my($self, $model, $rows, $index, $max, $where_clause, @values) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{select} || Carp::croak("SqlListSupport not initialized");

    my($start_time) = $_TRACE ? Bivio::Util::gettimeofday() : 0;
    my($col_field_count) = $fields->{col_field_count};

    # clear the result set
#    $#{@$rows} = 0; 	# doesn't work
#    0 while (pop(@$rows)); #works
    my(@a) = @$rows;
    $#a = 0;

    my($conn) = Bivio::Biz::SqlConnection->get_connection();
    my($sql) = $fields->{select}.$where_clause;
    &_trace($sql, ' (', join(',', @values), ')') if $_TRACE;
    my($statement) = $conn->prepare_cached($sql);

    Bivio::Biz::SqlConnection->execute($statement, $model, @values);

    my($row);
    my($i) = 0;
    my($count) = 0;
    while ($row = $statement->fetchrow_arrayref()) {

	if ($count++ < $index) {
	    next;
	}

	my($col) = 0;
	for (my($j) = 0; $j < scalar(@$col_field_count); $j++) {
	    my($val);
	    if ($col_field_count->[$j] == 1 ) {
		$val = $row->[$col++];
	    }
	    else {
		$val = [];
		for (my($k) = 0; $k < $col_field_count->[$j]; $k++) {
		    push(@$val, $row->[$col++]);
		}
	    }
	    $rows->[$i]->[$j] = $val;
	}

	if (++$i >= $max) {
	    last;
	}
    }
    $statement->finish();

    if ($_TRACE) {
	Bivio::Biz::SqlConnection->increment_db_time(
		Bivio::Util::time_delta_in_seconds($start_time));
    }
    return $model->get_status()->is_OK();
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

    my($start_time) = $_TRACE ? Bivio::Util::gettimeofday() : 0;
    my($conn) = Bivio::Biz::SqlConnection->get_connection();
    my($sql) = $fields->{count}.$where_clause;
    &_trace($sql, ' (', join(',', @values), ')') if $_TRACE;
    my($statement) = $conn->prepare_cached($sql);

    Bivio::Biz::SqlConnection->execute($statement, $model, @values);

    my($result) = $statement->fetchrow_arrayref()->[0];
    $statement->finish();

    if ($_TRACE) {
	Bivio::Biz::SqlConnection->increment_db_time(
		Bivio::Util::time_delta_in_seconds($start_time));
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

    my($conn) =  Bivio::Biz::SqlConnection->get_connection();
    my($sql) = 'select '.join(',', @{$fields->{col_map}})
	    .' from '.$fields->{table_name};

    &_trace($sql) if $_TRACE;

    my($statement) = $conn->prepare($sql);
    my($names) = $statement->{NAME_lc};
    my($types) = $statement->{TYPE};

    my($select) = 'select ';
    for(my($i) = 0; $i < scalar(@$names); $i++) {
	if ($types->[$i] == Bivio::Biz::SqlSupport::SQL_DATE_TYPE()) {
	    $select .= 'TO_CHAR('.$names->[$i].",'"
		    .Bivio::Biz::SqlSupport::DATE_FORMAT()."'),";
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
}

#=PRIVATE METHODS

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
