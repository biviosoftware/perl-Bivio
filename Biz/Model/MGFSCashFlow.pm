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

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::MGFSCashFlow::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::MGFSCashFlow>

=cut

#=IMPORTS
use Bivio::Data::MGFS::Id;
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
	table_name => 'mgfs_cash_flow_t',
	columns => {
	    mg_id => ['Bivio::Data::MGFS::Id',
		    Bivio::SQL::Constraint::PRIMARY_KEY()],
	    dttm => ['Bivio::Data::MGFS::MonthDate',
		    Bivio::SQL::Constraint::PRIMARY_KEY()],
	    annual => ['Bivio::Type::Boolean',
		    Bivio::SQL::Constraint::PRIMARY_KEY()],
	    quarter => ['Bivio::Data::MGFS::Quarter',
		    Bivio::SQL::Constraint::PRIMARY_KEY()],
	    inc => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    dep_and_amortization => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    deferred_inc_taxes => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    operating_losses => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    extraordinary_losses => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    other_noncash_items => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    decrease_receivables => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    decrease_inventories => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    decrease_other_current_assets => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    increase_payables => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    increase_other_current_liab => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    cash_cont_op => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    cash_discont_op => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    cash_op_activities => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    sale_ppe => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    sale_short_term_invest => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    purchase_ppe => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    purchase_short_term_invest => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    other_investing_changes => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    cash_from_investing_activities => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    issuance_debt => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    issuance_capital_stock => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    repayment_long_term_debt => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    repurchase_capital_stock => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    payment_cash_div => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    other_financing_charges => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    cash_financing_activities => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    effect_exchange_rate_changes => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    change_cash_and_equivalents => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    cash_beginning_period => ['Bivio::Type::Amount',
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
