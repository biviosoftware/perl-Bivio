# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::CSIStockPrice;
use strict;
$Bivio::Biz::Model::CSIStockPrice::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::CSIStockPrice::VERSION;

=head1 NAME

Bivio::Biz::Model::CSIStockPrice - provide daily prices formats

=head1 SYNOPSIS

    use Bivio::Biz::Model::CSIStockPrice;
    Bivio::Biz::Model::CSIStockPrice->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::Model::CSIBase>

=cut

use Bivio::Biz::Model::CSIBase;
@Bivio::Biz::Model::CSIStockPrice::ISA = ('Bivio::Biz::Model::CSIBase');

=head1 DESCRIPTION

C<Bivio::Biz::Model::CSIStockPrice>

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
my($_DATES) = 'a8' x 265;
my($_AMOUNTS) = 'a6' x 265;
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
	table_name => 'csi_stock_price_t',
	columns => {
	    csi_id => ['Bivio::Data::CSI::Id', 'PRIMARY_KEY'],
            price_date => ['Date', 'PRIMARY_KEY'],
            open => ['Bivio::Data::CSI::Quote', 'NOT_NULL'],
	    high => ['Bivio::Data::CSI::Quote', 'NOT_NULL'],
            low => ['Bivio::Data::CSI::Quote', 'NOT_NULL'],
            close => ['Bivio::Data::CSI::Quote', 'NOT_NULL'],
            volume => ['Bivio::Data::CSI::Amount', 'NOT_NULL'],
        },
    };
}

=for html <a name="processRecord"></a>

=head2 processRecord(string date, Bivio::Data::CSI::RecordType type, array_ref fields)

CLQ,1199,1.875,2.25,1.875,2.25,1.8125,84
EBAY,31850,53,53.25,51.3125,53.1875,52.3125,35732

=cut

sub processRecord {
    my($self, $date, $record_type, $fields) = @_;
    my($csi_id) = Bivio::Data::CSI::Id->from_literal($fields->[1]);
    my($values) = {
        ticker_symbol => $fields->[0],
        csi_id => $csi_id,
        price_date => Bivio::Type::Date->from_literal($date),
        open => Bivio::Data::CSI::Quote->from_literal($fields->[2]),
        high => Bivio::Data::CSI::Quote->from_literal($fields->[3]),
        low => Bivio::Data::CSI::Quote->from_literal($fields->[4]),
        close => Bivio::Data::CSI::Quote->from_literal($fields->[5]),
        volume => 100 * Bivio::Data::CSI::Amount->from_literal($fields->[7]),
    };
    $self->create($values);

    my($req) = $self->get_request;
    my($instrument) = Bivio::Biz::Model::CSIInstrument->new($req);
    $instrument->load(csi_id => $csi_id);
    my($valuation) = Bivio::Biz::Model::InstrumentValuation->new($req);
    $valuation->create({
        instrument_id => $instrument->get('instrument_id'),
        closing_date => $values->{price_date},
        closing_price => $values->{close},
    });
    return;
}

#=PRIVATE METHODS

# _initialize()
#
# Register record types
#
sub _initialize {
    Bivio::Biz::Model::CSIBase->internal_register_handler($_PACKAGE,
            Bivio::Data::CSI::RecordType::STOCK_PRICE());
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
