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

=for html <a name="create"></a>

=head2 create(hash_ref new_values, Bivio::Type::InstrumentType type) : Bivio::Biz::Model::CSIFactSheet

Create a new model. Needs an instrument I<type> to
create the Instrument and CSIInstrument models if necessary.

=cut

sub create {
    my($self, $new_values, $type) = @_;
    _sync_instrument_models($self, $new_values, $type);
    return $self->SUPER::create($new_values);
}

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
            fact_function => ['Bivio::Data::CSI::FactSheetFunction', 'NOT_NULL'],
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
        fact_function => Bivio::Data::CSI::FactSheetFunction->from_any($fields->[2]),
        ticker_symbol => _otc_adjust($fields->[0], $fields->[5]),
        exchange_name => $fields->[5],
        conversion_factor => $fields->[6],
    };
    # Instrument name can be empty, use symbol instead
    my($name) = $fields->[3];
    $values->{name} = defined($name) && length($name)
            ? $name : $values->{ticker_symbol};
    $self->create($values, Bivio::Type::InstrumentType->from_csi($fields->[4]));
    return;
}

=for html <a name="update"></a>

=head2 update(hash_ref new_values) : Bivio::Biz::Model::CSIFactSheet

Catch calls and die.

=cut

sub update {
    my($self) = @_;
    Bivio::Die->die('can only be updated via modification records');
    # DOES NOT RETURN
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

# _sync_instrument_models(self, hash_ref values, Bivio::Type::InstrumentType type)
#
# Lookup an Instrument given a ticker symbol,
# create a new instrument if necessary.
# Lookup a CSI Instrument given a CSI Id,
# create a new CSI instrument if necessary.
#
sub _sync_instrument_models {
    my($self, $values, $type) = @_;
    my($req) = $self->get_request;
    my($inst) = Bivio::Biz::Model::Instrument->new($req);
    unless ($inst->unsafe_load(ticker_symbol => $values->{ticker_symbol})) {
        $inst->create({
            name => $values->{name},
            ticker_symbol => $values->{ticker_symbol},
            exchange_name => $values->{exchange_name},
            instrument_type => $type,
            fed_tax_free => Bivio::Type::Boolean::FALSE(),
        });
    }
    my($csi_inst) = Bivio::Biz::Model::CSIInstrument->new($req);
    unless ($csi_inst->unsafe_load(csi_id => $values->{csi_id})) {
        $csi_inst->create({
            csi_id => $values->{csi_id},
            instrument_id => $inst->get('instrument_id'),
            instrument_type => $type,
        });
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
