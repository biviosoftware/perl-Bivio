# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::CSIDistribution;
use strict;
$Bivio::Biz::Model::CSIDistribution::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::CSIDistribution - keep dividend and capital gains

=head1 SYNOPSIS

    use Bivio::Biz::Model::CSIDistribution;
    Bivio::Biz::Model::CSIDistribution->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::Model::CSIBase>

=cut

use Bivio::Biz::Model::CSIBase;
@Bivio::Biz::Model::CSIDistribution::ISA = ('Bivio::Biz::Model::CSIBase');

=head1 DESCRIPTION

C<Bivio::Biz::Model::CSIDistribution> keeps dividend and capital gains

=cut

#=IMPORTS
use Bivio::Data::CSI::DistributionType;
use Bivio::Data::CSI::Id;
use Bivio::Data::CSI::Quote;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
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
	table_name => 'csi_distribution_t',
	columns => {
	    csi_id => ['Bivio::Data::CSI::Id', 'PRIMARY_KEY'],
	    distribution_date => ['Date', 'PRIMARY_KEY'],
	    amount_type => ['Bivio::Data::CSI::DistributionType', 'PRIMARY_KEY'],
	    amount => ['Bivio::Data::CSI::Quote', 'NOT_NULL'],
	},
    };
}

=for html <a name="process_record"></a>

=head2 process_record(string date, Bivio::Data::CSI::RecordType type, array_ref fields)

=head2 process_record(string date, array_ref type, array_ref fields)

Sample records:

ARQIX,35494,20001121,.089,1.458
ACMOX,35495,20001121,.000,.005
ACMOX,35495,20001130,.030,.000
ABEIX,35537,20001121,.021,.000
BRMBX,35547,20001113,.000,10.076

Create a separate entry for dividends and capital gains.
The capital gains field can be missing.

=cut

sub process_record {
    my($self, $date, $type, $fields) = @_;
    my($dividend) = Bivio::Data::CSI::Quote->from_literal($fields->[3]);
    my($values) = {
        csi_id => Bivio::Data::CSI::Id->from_literal($fields->[1]),
        distribution_date => Bivio::Type::Date->from_literal($date),
        amount_type => Bivio::Data::CSI::DistributionType::DIVIDEND(),
        amount => $dividend,
    };
    $self->create_or_update($values, $type) if $dividend > 0.0;
    my($cap_gain) = Bivio::Data::CSI::Quote->from_literal($fields->[4]);
    if (defined($cap_gain) && $cap_gain > 0.0) {
        $values->{amount_type}
                = Bivio::Data::CSI::DistributionType::CAPITAL_GAINS();
        $values->{amount} = $cap_gain;
        $self->create_or_update($values, $type);
    }
    return;
}

#=PRIVATE METHODS

# _initialize()
#
# Register record type
#
sub _initialize {
    Bivio::Biz::Model::CSIBase->internal_register_handler($_PACKAGE,
            Bivio::Data::CSI::RecordType::DIVIDEND_CAPITAL_GAIN());
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
