# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::CSIMutualFund;
use strict;
$Bivio::Biz::Model::CSIMutualFund::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::CSIMutualFund::VERSION;

=head1 NAME

Bivio::Biz::Model::CSIMutualFund - provide daily mutual funds data

=head1 SYNOPSIS

    use Bivio::Biz::Model::CSIMutualFund;
    Bivio::Biz::Model::CSIMutualFund->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::Model::CSIBase>

=cut

use Bivio::Biz::Model::CSIBase;
@Bivio::Biz::Model::CSIMutualFund::ISA = ('Bivio::Biz::Model::CSIBase');

=head1 DESCRIPTION

C<Bivio::Biz::Model::CSIMutualFund> provides daily mutual funds data

=cut

#=IMPORTS
use Bivio::Biz::Model::InstrumentValuation;
use Bivio::Data::CSI::Id;
use Bivio::Data::CSI::Quote;
use Bivio::Data::CSI::RecordType;

=head1 CONSTANTS

=cut

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
use vars qw($_TRACE);
Bivio::IO::Trace->register;
_initialize();

=head1 FACTORIES

=cut

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(hash_ref new_values) : Bivio::Biz::Model::CSIMutualFund

Create a new record.

=cut

sub create {
    my($self, $new_values) = @_;
    my($req) = $self->get_request;
    # Load instrument ID given a CSI ID
    my($instrument) = Bivio::Biz::Model::CSIInstrument->new($req);
    $instrument->load(csi_id => $new_values->{csi_id});
    # Create corresponding InstrumentValuation model record
    my($valuation) = Bivio::Biz::Model::InstrumentValuation->new($req);
    $valuation->create({
        instrument_id => $instrument->get('instrument_id'),
        closing_date => $new_values->{price_date},
        closing_price => $new_values->{net_asset_value},
    });
    return $self->SUPER::create($new_values);
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'csi_mutual_fund_t',
	columns => {
	    csi_id => ['Bivio::Data::CSI::Id', 'PRIMARY_KEY'],
	    price_date => ['Date', 'PRIMARY_KEY'],
	    net_asset_value => ['Bivio::Data::CSI::Quote', 'NOT_NULL'],
	    ask_price => ['Bivio::Data::CSI::Quote', 'NOT_NULL'],
        },
    };
}

=for html <a name="processRecord"></a>

=head2 processRecord(string date, Bivio::Data::CSI::RecordType type, array_ref fields)

=head2 processRecord(string date, array_ref type, array_ref fields)

INSEX,6069,8.8,9.2

=cut

sub processRecord {
    my($self, $date, $type, $fields) = @_;
    my($csi_id) = Bivio::Data::CSI::Id->from_literal($fields->[1]);
    my($values) = {
        csi_id => $csi_id,
        price_date => Bivio::Type::Date->from_literal($date),
        net_asset_value => Bivio::Data::CSI::Quote->from_literal($fields->[2]),
        ask_price => Bivio::Data::CSI::Quote->from_literal($fields->[3]),
    };
    $self->create_or_update($values, $type);
    return;
}

=for html <a name="update"></a>

=head2 update() : 



=cut

sub update {
    my($self, $new_values) = @_;
    my($req) = $self->get_request;
    # Load instrument ID given a CSI ID
    my($instrument) = Bivio::Biz::Model::CSIInstrument->new($req);
    $instrument->load(csi_id => $new_values->{csi_id});
    # Update corresponding InstrumentValuation model record
    my($valuation) = Bivio::Biz::Model::InstrumentValuation->new($req);
    $valuation->update({
        instrument_id => $instrument->get('instrument_id'),
        closing_date => $new_values->{price_date},
        closing_price => $new_values->{net_asset_value},
    });
    return $self->SUPER::update($new_values);
}

#=PRIVATE METHODS

# _initialize()
#
# Register record types to process
#
sub _initialize {
    Bivio::Biz::Model::CSIBase->internal_register_handler($_PACKAGE,
            Bivio::Data::CSI::RecordType::MUTUAL_FUND());
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
