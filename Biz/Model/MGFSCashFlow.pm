# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::MGFSCashFlow;
use strict;
$Bivio::Biz::Model::MGFSCashFlow::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::MGFSCashFlow - 

=head1 SYNOPSIS

    use Bivio::Biz::Model::MGFSCashFlow;
    Bivio::Biz::Model::MGFSCashFlow->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::Model::MGFSBase>

=cut

use Bivio::Biz::Model::MGFSBase;
@Bivio::Biz::Model::MGFSCashFlow::ISA = ('Bivio::Biz::Model::MGFSBase');

=head1 DESCRIPTION

C<Bivio::Biz::Model::MGFSCashFlow>

=cut

#=IMPORTS
use Bivio::Data::MGFS::Amount;
use Bivio::Data::MGFS::AnnualCode;
use Bivio::Data::MGFS::Id;
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
	    indb03 => [0, 0],
	    indb04 => [0, 0],
	    chgdb03 => [0, 1],
	    chgdb04 => [0, 1],
	},
	format => [
	    {
		# skips sign from id, always +
		mg_id => ['ID', 44, 8],
		dttm => ['CHAR', 66, 7],
		annual => ['CHAR', 0, 2],
		quarter => ['CHAR', 86, 1],
		inc => ['MILLIONS', 864, 10],
		dep_and_amortization => ['MILLIONS', 874, 10],
		deferred_inc_taxes => ['MILLIONS', 884, 10],
		operating_losses => ['MILLIONS', 894, 10],
		extraordinary_losses => ['MILLIONS', 904, 10],
		other_noncash_items => ['MILLIONS', 914, 10],
		decrease_receivables => ['MILLIONS', 924, 10],
		decrease_inventories => ['MILLIONS', 934, 10],
		decrease_other_current_assets => ['MILLIONS', 944, 10],
		increase_payables => ['MILLIONS', 954, 10],
		increase_other_current_liab => ['MILLIONS', 964, 10],
		cash_cont_op => ['MILLIONS', 974, 10],
		cash_discont_op => ['MILLIONS', 984, 10],
		cash_op_activities => ['MILLIONS', 994, 10],
		sale_ppe => ['MILLIONS', 1004, 10],
		sale_short_term_invest => ['MILLIONS', 1014, 10],
		purchase_ppe => ['MILLIONS', 1024, 10],
		purchase_short_term_invest => ['MILLIONS', 1034, 10],
		other_investing_changes => ['MILLIONS', 1044, 10],
		cash_from_investing_activities => ['MILLIONS', 1054, 10],
		issuance_debt => ['MILLIONS', 1064, 10],
		issuance_capital_stock => ['MILLIONS', 1074, 10],
		repayment_long_term_debt => ['MILLIONS', 1084, 10],
		repurchase_capital_stock => ['MILLIONS', 1094, 10],
		payment_cash_div => ['MILLIONS', 1104, 10],
		other_financing_charges => ['MILLIONS', 1114, 10],
		cash_financing_activities => ['MILLIONS', 1124, 10],
		effect_exchange_rate_changes => ['MILLIONS', 1134, 10],
		change_cash_and_equivalents => ['MILLIONS', 1144, 10],
		cash_beginning_period => ['MILLIONS', 1154, 10],
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
	table_name => 'mgfs_cash_flow_t',
	columns => {
	    mg_id => ['Bivio::Data::MGFS::Id',
		    Bivio::SQL::Constraint::PRIMARY_KEY()],
	    date_time => ['Bivio::Data::MGFS::MonthDate',
		    Bivio::SQL::Constraint::PRIMARY_KEY()],
	    annual => ['Bivio::Data::MGFS::AnnualCode',
		    Bivio::SQL::Constraint::PRIMARY_KEY()],
	    quarter => ['Bivio::Data::MGFS::Quarter',
		    Bivio::SQL::Constraint::PRIMARY_KEY()],
	    inc => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    dep_and_amortization => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    deferred_inc_taxes => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    operating_losses => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    extraordinary_losses => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    other_noncash_items => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    decrease_receivables => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    decrease_inventories => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    decrease_other_current_assets => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    increase_payables => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    increase_other_current_liab => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    cash_cont_op => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    cash_discont_op => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    cash_op_activities => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    sale_ppe => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    sale_short_term_invest => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    purchase_ppe => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    purchase_short_term_invest => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    other_investing_changes => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    cash_from_investing_activities => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    issuance_debt => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    issuance_capital_stock => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    repayment_long_term_debt => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    repurchase_capital_stock => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    payment_cash_div => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    other_financing_charges => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    cash_financing_activities => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    effect_exchange_rate_changes => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    change_cash_and_equivalents => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    cash_beginning_period => ['Bivio::Data::MGFS::Amount',
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
