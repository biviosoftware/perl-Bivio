# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::SqlSupport;
use strict;
$Bivio::Biz::SqlSupport::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Biz::SqlSupport - sql support for Models

=head1 SYNOPSIS

    use Bivio::Biz::SqlSupport;
    Bivio::Biz::SqlSupport->new();

=cut

use Bivio::UNIVERSAL;
@Bivio::Biz::SqlSupport::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Biz::SqlSupport>

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Ext::DBI;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Biz::SqlSupport

Creates a SQL support instance. To be useful, the set_model_config() should
be invoked before using other methods.

=cut

sub new {
    my($self) = &Bivio::UNIVERSAL::new(@_);
    $self->{$_PACKAGE} = {
	cfg => undef
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="query"></a>

=head2 query(Model model, hash properties, string where_clause, string value, ...)

Loads the specified properties with data using the parameterized where_clause
and substitution values.

=cut

sub query {
    my($self, $model, $properties, $where_clause, @values) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($cfg) = $fields->{cfg};
    $cfg || die("sql support not configured");

    #TODO: connection cacheing

    my($conn) = Bivio::Ext::DBI->connect();
    my($sql) = $fields->{select}.$where_clause;
    print($sql."\n");
    my($statement) = $conn->prepare($sql);

    #TODO: trap Oracle errors and set model's state

    $statement->execute(@values);
    my($row) = $statement->fetchrow_arrayref();

    if ($row) {
	my(@fields) = keys(%{$cfg->{sql_field_map}});

	for (my($i) = 0; $i < scalar(@fields); $i++) {
	    $properties->{$fields[$i]} = $row->[$i];
	}
    }
    else {

	#TODO: need a better error than this

	$model->get_status()->add_error(
		Bivio::Biz::Error->new("Not Found"));
    }
    $statement->finish();
    $conn->disconnect();
}

=for html <a name="set_model_config"></a>

=head2 set_model_config(hash model_cfg)

Initializes the support for the specified model. Configuration should be
of the form:

=over 4

=item table_name : string

The database table name(s).

=item sql_field_map : hash

The property name to sql column mapping. Format:
    {
        property-name => column-name,
        ...
    }

=cut

sub set_model_config {
    my($self, $model_cfg) = @_;
    my($fields) = $self->{$_PACKAGE};
    my(@sql_fields) = values(%{$model_cfg->{sql_field_map}});
    $fields->{select} = 'select '.join(',', @sql_fields).' from '
	    .$model_cfg->{table_name}.' ';
    $fields->{cfg} = $model_cfg;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
