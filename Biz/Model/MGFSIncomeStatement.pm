# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::MGFSIncomeStatement;
use strict;
$Bivio::Biz::Model::MGFSIncomeStatement::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::MGFSIncomeStatement - 

=head1 SYNOPSIS

    use Bivio::Biz::Model::MGFSIncomeStatement;
    Bivio::Biz::Model::MGFSIncomeStatement->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::MGFSIncomeStatement::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::MGFSIncomeStatement>

=cut

#=IMPORTS
use Bivio::Data::MGFS::Id;
use Bivio::Data::MGFS::MonthDate;
use Bivio::Data::MGFS::Quarter;
use Bivio::Type::Amount;
use Bivio::Type::Integer;

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
	table_name => 'mgfs_income_statement_t',
	columns => {
	    mg_id => ['Bivio::Data::MGFS::Id',
		    Bivio::SQL::Constraint::PRIMARY_KEY()],
	    dttm => ['Bivio::Data::MGFS::MonthDate',
		    Bivio::SQL::Constraint::PRIMARY_KEY()],
	    quarter => ['Bivio::Data::MGFS::Quarter',
		    Bivio::SQL::Constraint::PRIMARY_KEY()],
	    annual => ['Bivio::Type::Boolean',
		    Bivio::SQL::Constraint::PRIMARY_KEY()],
	    using_basic_eps => ['Bivio::Data::MGFS::Boolean',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    op_revenue => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    cost_sales => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    gross_op_profit => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    general_expense => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    other_taxes => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    op_profit_pre_dep => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    dep => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    op_profit_post_dep => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    inc_other => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    inc_for_int => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    int_expense => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    int_minority => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    inc_pre_tax => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    inc_taxes => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    inc_cont_op => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    inc_discont_op => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    inc_op => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    inc_special => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    inc_normalized => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    inc_extra => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    inc_accounting_change => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    inc_tax_carry => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    other_gains => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    inc => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    div_preferred => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    inc_available_common => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],

	    eps_cont_op => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    eps_discont_op => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    eps_op => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    eps_extra => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    eps_accounting_change => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    eps_tax_carry => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    eps_other_gains => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    eps => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    eps_normalized => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],

	    deps_cont_op => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    deps_dicont_op => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    deps_op => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    deps_extra => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    deps_accounting_change => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    deps_tax_carry => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    deps_other_gains => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    deps => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    deps_normalized => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],

	    div_per_share => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],

	    # Year-to-Date
	    revenue_ytd => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    inc_ytd => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    eps_ytd => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    div_ytd => ['Bivio::Type::Amount',
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
