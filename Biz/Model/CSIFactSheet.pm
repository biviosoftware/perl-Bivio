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

=for html <a name="process_record"></a>

=head2 process_record(string date, Bivio::Data::CSI::RecordType type, array_ref fields)

MSAMX,45945,A,MSDW STRAT ADV MOD PT A,MU,MUTUAL,+2,
MBRHX,24527,D,Merrill Lynch Asset Builder Quality B,MU,MUTUAL,+2,MBRHX
PYGNX,36205,M,Payden Gnma Fd,MU,MUTUAL,+2,PYGNX

=cut

sub process_record {
    my($self, $date, $record_type, $fields) = @_;
    my($values) = {
        csi_id => Bivio::Data::CSI::Id->from_literal($fields->[1]),
        fact_date => Bivio::Type::Date->from_literal($date),
        fact_function => Bivio::Data::CSI::FactSheetFunction->from_any($fields->[2]),
        ticker_symbol => $fields->[0],
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

# _sync_instrument_models(self, hash_ref values, Bivio::Type::InstrumentType type)
#
# Given a CSI Id, try to load the instruments.
# Rename ticker symbol when the instrument is deleted (ie became obsolete).
#
sub _sync_instrument_models {
    my($self, $values, $type) = @_;
    my($req) = $self->get_request;

    my($inst) = Bivio::Biz::Model::Instrument->new($req);
    my($csi_inst) = Bivio::Biz::Model::CSIInstrument->new($req);

    if ($csi_inst->unsafe_load(csi_id => $values->{csi_id})) {
        $inst->load(instrument_id => $csi_inst->get('instrument_id'));
        # MODIFY OP: update instrument attributes
        $inst->update({
            name => $values->{name},
            ticker_symbol => $values->{ticker_symbol},
            exchange_name => $values->{exchange_name},
        }) if $values->{fact_function}
                == Bivio::Data::CSI::FactSheetFunction::MODIFY();
        # DELETE OP is handled below
    }
    else {
        # ADD OP: create new instrument
        # Could be a delete/modify op in case we've not seen the ADD
        $inst->create({
            name => $values->{name},
            ticker_symbol => $values->{ticker_symbol},
            exchange_name => $values->{exchange_name},
            instrument_type => $type,
            fed_tax_free => Bivio::Type::Boolean::FALSE(),
        });
        $csi_inst->create({
            csi_id => $values->{csi_id},
            instrument_id => $inst->get('instrument_id'),
            instrument_type => $type,
        });
    }
    # DELETE OP: rename ticker symbol so it can be re-used later
    $inst->update({
        ticker_symbol => $values->{ticker_symbol}.'-D'
        .Bivio::Type::Date->to_file_name($values->{fact_date}),
    }) if $values->{fact_function}
            == Bivio::Data::CSI::FactSheetFunction::DELETE();
    return;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
