# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::CSIMutualFund;
use strict;
$Bivio::Biz::Model::CSIMutualFund::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::CSIMutualFund::VERSION;

=head1 NAME

Bivio::Biz::Model::CSIMutualFund - provide daily quotes formats

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

C<Bivio::Biz::Model::CSIMutualFund>

=cut

#=IMPORTS
use Bivio::Biz::Model::InstrumentValuation;
use Bivio::Data::CSI::Id;
use Bivio::Data::CSI::Quote;
use Bivio::Data::CSI::RecordType;
use Bivio::IO::Trace;

=head1 CONSTANTS

=cut

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
_initialize();

=head1 FACTORIES

=cut

=head1 METHODS

=cut

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

INSEX,6069,8.8,9.2

=cut

sub processRecord {
    my($self, $date, $record_type, $fields) = @_;
    my($csi_id) = Bivio::Data::CSI::Id->from_literal($fields->[1]);
    my($values) = {
        csi_id => $csi_id,
        price_date => Bivio::Type::Date->from_literal($date),
        net_asset_value => Bivio::Data::CSI::Quote->from_literal($fields->[2]),
        ask_price => Bivio::Data::CSI::Quote->from_literal($fields->[3]),
    };
    $self->create($values);

    my($req) = $self->get_request;
    my($instrument) = Bivio::Biz::Model::CSIInstrument->new($req);
    $instrument->load(csi_id => $csi_id);
    my($valuation) = Bivio::Biz::Model::InstrumentValuation->new($req);
    $valuation->create({
        instrument_id => $instrument->get('instrument_id'),
        closing_date => $values->{price_date},
        closing_price => $values->{net_asset_value},
    });
    return;
}

#=PRIVATE METHODS

# _initialize()
#
#
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
