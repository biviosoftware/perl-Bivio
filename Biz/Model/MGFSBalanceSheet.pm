# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::MGFSBalanceSheet;
use strict;
$Bivio::Biz::Model::MGFSBalanceSheet::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::MGFSBalanceSheet - 

=head1 SYNOPSIS

    use Bivio::Biz::Model::MGFSBalanceSheet;
    Bivio::Biz::Model::MGFSBalanceSheet->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::MGFSBalanceSheet::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::MGFSBalanceSheet>

=cut

#=IMPORTS
use Bivio::Data::MGFS::Id;
use Bivio::Data::MGFS::InventoryValuationMethod;
use Bivio::Data::MGFS::MonthDate;
use Bivio::Data::MGFS::Quarter;
use Bivio::Type::Amount;
use Bivio::Type::Boolean;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'mgfs_balance_sheet_t',
	columns => {
	    mg_id => ['Bivio::Data::MGFS::Id',
		    Bivio::SQL::Constraint::PRIMARY_KEY()],
	    dttm => ['Bivio::Data::MGFS::MonthDate',
		    Bivio::SQL::Constraint::PRIMARY_KEY()],
	    annual => ['Bivio::Type::Boolean',
		    Bivio::SQL::Constraint::PRIMARY_KEY()],
	    quarter => ['Bivio::Data::MGFS::Quarter',
		    Bivio::SQL::Constraint::PRIMARY_KEY()],
	    cash_and_equivalents => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    receivables => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    inventories => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    other_current_assets => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    gross_fixed_assets => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    current_assets => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    accum_dep_and_depletion => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    fixed_assets => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    intangibles => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    other_noncurrent_assets => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    noncurrent_assets => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    assets => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    inventory_valuation_method => [
		    'Bivio::Data::MGFS::InventoryValuationMethod',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    accounts_payable => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    short_term_debt => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    other_current_liab => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    current_liab => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    long_term_debt => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    deferred_inc_taxes => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    other_noncurrent_assets => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    int_minority => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    noncurrent_liab => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    liab => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    preferred_stock_equity => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    common_stock_equity => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    retained_earnings => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    equity => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    liab_and_stock_equity => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    cash_flow => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    working_capital => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    free_cash_flow => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    free_cash_flow_per_share => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    invested_capital => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    common_shares_outstanding => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    preferred_shares => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    ordinary_shares => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    treasury_shares => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
        },
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
