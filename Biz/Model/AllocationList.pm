# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::AllocationList;
use strict;
$Bivio::Biz::Model::AllocationList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::AllocationList - allocation list base class

=head1 SYNOPSIS

    use Bivio::Biz::Model::AllocationList;
    Bivio::Biz::Model::AllocationList->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::Model::AllocationList::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::AllocationList> allocation list base class

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="internal_calculate_net_profit"></a>

=head2 internal_calculate_net_profit(array_ref rows)

Calculates the net profit field for each row.

=cut

sub internal_calculate_net_profit {
    my($self, $rows) = @_;

    foreach my $row (@$rows) {
	my($net_profit) = 0;
	for (my($i) = 0; $i < Bivio::Type::TaxCategory->get_count; $i++) {
	    my($tax) = Bivio::Type::TaxCategory->from_int($i);
	    next if $tax == Bivio::Type::TaxCategory::NOT_TAXABLE();
	    $net_profit = Bivio::Type::Amount->add($net_profit,
		    $row->{$tax->get_short_desc});
	}
	$row->{net_profit} = $net_profit;
    }
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize()

All local fields.

=cut

sub internal_initialize {

    my($tax) = 'Bivio::Type::TaxCategory';
    return {
	version => 1,
	other => [
	    {
		name => 'user_id',
		type => 'PrimaryId',
		constraint => 'NONE',
	    },
	    {
		name => 'name',
		type => 'Line',
		constraint => 'NONE',
	    },
	    {
	        name => $tax->DIVIDEND->get_short_desc,
   	        type => 'Amount',
	        constraint => 'NONE',
	    },
	    {
	        name => $tax->INTEREST->get_short_desc,
   	        type => 'Amount',
	        constraint => 'NONE',
	    },
	    {
	        name => $tax->FEDERAL_TAX_FREE_INTEREST->get_short_desc,
   	        type => 'Amount',
	        constraint => 'NONE',
	    },
	    {
	        name => $tax->SHORT_TERM_CAPITAL_GAIN->get_short_desc,
   	        type => 'Amount',
	        constraint => 'NONE',
	    },
	    {
	        name => $tax->MEDIUM_TERM_CAPITAL_GAIN->get_short_desc,
   	        type => 'Amount',
	        constraint => 'NONE',
	    },
	    {
	        name => $tax->LONG_TERM_CAPITAL_GAIN->get_short_desc,
   	        type => 'Amount',
	        constraint => 'NONE',
	    },
	    {
	        name => $tax->FOREIGN_TAX->get_short_desc,
   	        type => 'Amount',
	        constraint => 'NONE',
	    },
	    {
	        name => $tax->MISC_INCOME->get_short_desc,
   	        type => 'Amount',
	        constraint => 'NONE',
	    },
	    {
	        name => $tax->MISC_EXPENSE->get_short_desc,
   	        type => 'Amount',
	        constraint => 'NONE',
	    },
	    {
	        name => 'net_profit',
   	        type => 'Amount',
	        constraint => 'NONE',
	    },
	    {
	        name => 'units',
   	        type => 'Amount',
	        constraint => 'NONE',
	    },
       ],
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
