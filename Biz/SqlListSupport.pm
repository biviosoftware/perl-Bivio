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
use Bivio::IO::Trace;

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

    $self->{$_PACKAGE} = {
	table_name => $table_name,
	select => 'select '.join(',', @$col_map).' from '.$table_name.' ',
	col_map => $col_map
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="find"></a>

=head2 find(ListModel model, array rows, int max, string where_clause, string value, ...) : boolean

Loads the specified rows with data using the parameterized where_clause
and substitution values. At most the specified max rows will be loaded.

=cut

sub find {
    my($self, $model, $rows, $max, $where_clause, @values) = @_;
    my($fields) = $self->{$_PACKAGE};

    # clear the result set
    $#{@$rows} = 0;
    my($conn) = Bivio::Biz::SqlConnection->get_connection();
    my($sql) = $fields->{select}.$where_clause;
    &_trace($sql, ' (', join(',', @values), ')') if $_TRACE;
    my($statement) = $conn->prepare_cached($sql);

    #TODO: trap Oracle errors and set model's state

    $statement->execute(@values);

    my($row);
    my($i) = 0;

    #TODO: obviously this is not the fastest way
    while ($row = $statement->fetchrow_arrayref()) {

	#TODO: need to handle compound fields
	for (my($j) = 0; $j < scalar(@$row); $j++) {
	    $rows->[$i]->[$j] = $row->[$j];
	}
	if( ++$i >= $max) {
	    last;
	}
    }

    $statement->finish();
    return $model->get_status()->is_OK();
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
