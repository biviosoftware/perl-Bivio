# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::PropertyModel::Instrument;
use strict;
$Bivio::Biz::PropertyModel::Instrument::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::PropertyModel::Instrument - a secuity, option, etc.

=head1 SYNOPSIS

    use Bivio::Biz::PropertyModel::Instrument;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::PropertyModel::Instrument::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::PropertyModel::Instrument> represents what gets traded in the
clubs portfolio. Dated valuations are
Bivio::Biz::PropertyModel::InstrumentValuation.

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Biz::FieldDescriptor;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : array_ref

=cut

sub internal_initialize {
    my($property_info) = {
	'instrument_id' => ['Internal ID',
		Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
	'club_id' => ['Internal Club ID',
		Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
	'name' => ['Name',
		Bivio::Biz::FieldDescriptor->lookup('STRING', 256)],
	'ticker_symbol' => ['Ticker Symbol',
		Bivio::Biz::FieldDescriptor->lookup('STRING', 32)],
	'account_number' => ['Broker Account Number',
		Bivio::Biz::FieldDescriptor->lookup('STRING', 64)],
	'instrument_type' => ['Instrument Type',
		Bivio::Biz::FieldDescriptor->lookup('NUMBER', 2)],
	'fed_tax_free' => ['Federal Tax Free',
		Bivio::Biz::FieldDescriptor->lookup('BOOLEAN')],
	'average_cost_method' => ['Uses Average Costing',
		Bivio::Biz::FieldDescriptor->lookup('BOOLEAN')],
	'drp_plan' => ['Directed Reinvstment Plan',
		Bivio::Biz::FieldDescriptor->lookup('BOOLEAN')],
	'remark' => ['Remark',
		Bivio::Biz::FieldDescriptor->lookup('STRING', 256)],
    };
    return [$property_info,
	    Bivio::SQL::Support->new('instrument_t', keys(%$property_info)),
	    ['instrument_id']];
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
