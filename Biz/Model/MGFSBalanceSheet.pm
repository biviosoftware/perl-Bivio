# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::MGFSBalanceSheet;
use strict;
$Bivio::Biz::Model::MGFSBalanceSheet::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::MGFSBalanceSheet - provide balance sheet format

=head1 SYNOPSIS

    use Bivio::Biz::Model::MGFSBalanceSheet;
    Bivio::Biz::Model::MGFSBalanceSheet->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::Model::MGFSBase>

=cut

use Bivio::Biz::Model::MGFSBase;
@Bivio::Biz::Model::MGFSBalanceSheet::ISA = ('Bivio::Biz::Model::MGFSBase');

=head1 DESCRIPTION

C<Bivio::Biz::Model::MGFSBalanceSheet>

=cut

#=IMPORTS
use Bivio::Data::MGFS::Amount;
use Bivio::Data::MGFS::AnnualCode;
use Bivio::Data::MGFS::Id;
use Bivio::Data::MGFS::InventoryValuationMethod;
use Bivio::Data::MGFS::MonthDate;
use Bivio::Data::MGFS::Quarter;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="internal_get_mgfs_import_format"></a>

=head2 internal_get_mgfs_import_format() : hash_ref

Returns the defintion of the models MGFS import format.

=cut

sub internal_get_mgfs_import_format {
    return {
	file => {
	    indb03 => [0, 1],
	    indb04 => [0, 1],
	    chgdb03 => [0, 1],
	    chgdb04 => [0, 1],
	},
	format => [
	    {
		# skips sign from id, always +
		mg_id => ['ID', 44, 8],
		date_time => ['CHAR', 66, 7],
		annual => ['CHAR', 0, 2],
		quarter => ['CHAR', 86, 1],
		cash_and_equivalents => ['MILLIONS', 495, 10],
		receivables => ['MILLIONS', 505, 10],
		inventories => ['MILLIONS', 515, 10],
		other_current_assets => ['MILLIONS', 525, 10],
		gross_fixed_assets => ['MILLIONS', 535, 10],
		current_assets => ['MILLIONS', 545, 10],
		accum_dep_and_depletion => ['MILLIONS', 555, 10],
		fixed_assets => ['MILLIONS', 565, 10],
		intangibles => ['MILLIONS', 575, 10],
		other_noncurrent_assets => ['MILLIONS', 585, 10],
		noncurrent_assets => ['MILLIONS', 595, 10],
		assets => ['MILLIONS', 605, 10],
		inventory_valuation_method => ['CHAR', 615, 2],
		accounts_payable => ['MILLIONS', 617, 10],
		short_term_debt => ['MILLIONS', 627, 10],
		other_current_liab => ['MILLIONS', 637, 10],
		current_liab => ['MILLIONS', 647, 10],
		long_term_debt => ['MILLIONS', 657, 10],
		deferred_inc_taxes => ['MILLIONS', 667, 10],
		other_noncurrent_assets => ['MILLIONS', 677, 10],
		int_minority => ['MILLIONS', 687, 10],
		noncurrent_liab => ['MILLIONS', 697, 10],
		liab => ['MILLIONS', 707, 10],
		preferred_stock_equity => ['MILLIONS', 717, 10],
		common_stock_equity => ['MILLIONS', 727, 10],
		retained_earnings => ['MILLIONS', 737, 10],
		equity => ['MILLIONS', 747, 10],
		liab_and_stock_equity => ['MILLIONS', 757, 10],
		cash_flow => ['MILLIONS', 767, 10],
		working_capital => ['MILLIONS', 777, 10],
		free_cash_flow => ['MILLIONS', 787, 10],
		free_cash_flow_per_share => ['DOLLARS', 797, 7],
		invested_capital => ['MILLIONS', 804, 10],
		common_shares_outstanding => ['MILLIONS', 814, 10],
		preferred_shares => ['MILLIONS', 824, 10],
		ordinary_shares => ['MILLIONS', 834, 10],
		shares_outstanding_cco => ['MILLIONS', 844, 10],
		treasury_shares => ['MILLIONS', 854, 10],
	    }
	],
    };
}

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
	    date_time => ['Bivio::Data::MGFS::MonthDate',
		    Bivio::SQL::Constraint::PRIMARY_KEY()],
	    annual => ['Bivio::Data::MGFS::AnnualCode',
		    Bivio::SQL::Constraint::PRIMARY_KEY()],
	    quarter => ['Bivio::Data::MGFS::Quarter',
		    Bivio::SQL::Constraint::PRIMARY_KEY()],
	    cash_and_equivalents => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    receivables => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    inventories => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    other_current_assets => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    gross_fixed_assets => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    current_assets => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    accum_dep_and_depletion => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    fixed_assets => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    intangibles => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    other_noncurrent_assets => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    noncurrent_assets => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    assets => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    inventory_valuation_method => [
		    'Bivio::Data::MGFS::InventoryValuationMethod',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    accounts_payable => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    short_term_debt => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    other_current_liab => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    current_liab => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    long_term_debt => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    deferred_inc_taxes => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    other_noncurrent_assets => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    int_minority => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    noncurrent_liab => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    liab => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    preferred_stock_equity => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    common_stock_equity => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    retained_earnings => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    equity => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    liab_and_stock_equity => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    cash_flow => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    working_capital => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    free_cash_flow => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    free_cash_flow_per_share => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    invested_capital => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    common_shares_outstanding => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    preferred_shares => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    ordinary_shares => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    shares_outstanding_cco => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    treasury_shares => ['Bivio::Data::MGFS::Amount',
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
