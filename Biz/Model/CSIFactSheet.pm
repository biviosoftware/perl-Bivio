# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::CSIFactSheet;
use strict;
$Bivio::Biz::Model::CSIFactSheet::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::CSIFactSheet::VERSION;

=head1 NAME

Bivio::Biz::Model::CSIFactSheet - keeps conversion factors and symbol changes

=head1 SYNOPSIS

    use Bivio::Biz::Model::CSIFactSheet;

=cut

=head1 EXTENDS

L<Bivio::Biz::Model::CSIBase>

=cut

use Bivio::Biz::Model::CSIBase;
@Bivio::Biz::Model::CSIFactSheet::ISA = ('Bivio::Biz::Model::CSIBase');

=head1 DESCRIPTION

C<Bivio::Biz::Model::CSIFactSheet>

=cut

#=IMPORTS
use Bivio::Biz::Model::CSIInstrument;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
use vars qw($_TRACE);
Bivio::IO::Trace->register;
_initialize();

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'csi_fact_sheet_t',
	columns => {
	    csi_id => ['Bivio::Data::CSI::Id', 'PRIMARY_KEY'],
            fact_date => ['Date', 'PRIMARY_KEY'],
            fact_op => ['Bivio::Data::CSI::FactSheetFunction', 'NOT_NULL'],
            ticker_symbol => ['Name', 'NOT_NULL'],
            name => ['Line', 'NOT_NULL'],
            conversion_factor => ['Bivio::Data::CSI::Amount', 'NOT_NULL'],
            exchange_name => ['Name', 'NOT_NULL'],
        },
    };
}

=for html <a name="processRecord"></a>

=head2 processRecord(string date, Bivio::Data::CSI::RecordType type, array_ref fields)

MSAMX,45945,A,MSDW STRAT ADV MOD PT A,MU,MUTUAL,+2,
MBRHX,24527,D,Merrill Lynch Asset Builder Quality B,MU,MUTUAL,+2,MBRHX
PYGNX,36205,M,Payden Gnma Fd,MU,MUTUAL,+2,PYGNX

=cut

sub processRecord {
    my($self, $date, $record_type, $fields) = @_;
    my($values) = {
        csi_id => Bivio::Data::CSI::Id->from_literal($fields->[1]),
        fact_date => Bivio::Type::Date->from_literal($date),
        fact_op => Bivio::Data::CSI::FactSheetFunction->from_any($fields->[2]),
        ticker_symbol => _otc_adjust($fields->[0], $fields->[5]),
        name => $fields->[3],
        exchange_name => $fields->[5],
        conversion_factor => $fields->[6],
        instrument_type => Bivio::Type::InstrumentType->from_csi($fields->[4]),
    };
    # Instrument name can be empty, use symbol instead
    $values->{name} = $values->{ticker_symbol}
            unless defined($values->{name}) && length($values->{name});
    _sync_instrument_models($self, $values);
    $self->create($values);
    return;
}

#=PRIVATE METHODS

# _initialize()
#
# Register record type
#
sub _initialize {
    Bivio::Biz::Model::CSIBase->internal_register_handler($_PACKAGE,
            Bivio::Data::CSI::RecordType::FACT_SHEET_MODIFICATION());
    return;
}

# _otc_adjust(string symbol, string exchange_name) : string
#
# Add extenstion .OB for OTC instruments
#
sub _otc_adjust {
    my($symbol, $exchange_name) = @_;
    return $symbol . ($exchange_name eq 'OTC' ? '.OB' : '');
}

# _sync_instrument_models(self, hash_ref values)
#
# Lookup an Instrument given a ticker symbol.
# Create a new instrument if necessary.
# Lookup a CSI Instrument given a CSI Id.
# Create a new instrument if necessary.
#
sub _sync_instrument_models {
    my($self, $values) = @_;
    my($req) = $self->get_request;
    my($inst) = Bivio::Biz::Model::Instrument->new($req);
    unless ($inst->unsafe_load(ticker_symbol => $values->{ticker_symbol})) {
        $inst->create({
            name => $values->{name},
            ticker_symbol => $values->{ticker_symbol},
            exchange_name => $values->{exchange_name},
            instrument_type => $values->{instrument_type},
            fed_tax_free => Bivio::Type::Boolean::FALSE(),
        });
    }
    my($csi_inst) = Bivio::Biz::Model::CSIInstrument->new($req);
    unless ($csi_inst->unsafe_load(csi_id => $values->{csi_id})) {
        $csi_inst->create({
            csi_id => $values->{csi_id},
            instrument_id => $inst->get('instrument_id'),
            instrument_type => $values->{instrument_type},
        });
    }
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
