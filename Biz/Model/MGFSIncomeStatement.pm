# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::MGFSIncomeStatement;
use strict;
$Bivio::Biz::Model::MGFSIncomeStatement::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::MGFSIncomeStatement - provide income statement format

=head1 SYNOPSIS

    use Bivio::Biz::Model::MGFSIncomeStatement;
    Bivio::Biz::Model::MGFSIncomeStatement->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::Model::MGFSBase>

=cut

use Bivio::Biz::Model::MGFSBase;
@Bivio::Biz::Model::MGFSIncomeStatement::ISA = ('Bivio::Biz::Model::MGFSBase');

=head1 DESCRIPTION

C<Bivio::Biz::Model::MGFSIncomeStatement>

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
	    indb03 => [0, Bivio::Biz::Model::MGFSBase::CREATE_ONLY()],
	    indb04 => [0, Bivio::Biz::Model::MGFSBase::CREATE_ONLY()],
	    chgdb03 => [0, Bivio::Biz::Model::MGFSBase::CREATE_OR_UPDATE()],
	    chgdb04 => [0, Bivio::Biz::Model::MGFSBase::CREATE_OR_UPDATE()],
	},
	format => [
	    {
		# skips sign from id, always +
		mg_id => ['ID', 44, 8],
		date_time => ['CHAR', 66, 7],
		annual => ['CHAR', 0, 2],
		quarter => ['CHAR', 86, 1],
		using_basic_eps => ['CHAR', 87, 1],
		op_revenue => ['MILLIONS', 89, 10],
		cost_sales => ['MILLIONS', 99, 10],
		gross_op_profit => ['MILLIONS', 109, 10],
		general_expense => ['MILLIONS', 119, 10],
		other_taxes => ['MILLIONS', 129, 10],
		op_profit_pre_dep => ['MILLIONS', 139, 10],
		dep => ['MILLIONS', 149, 10],
		op_profit_post_dep => ['MILLIONS', 159, 10],
		inc_other => ['MILLIONS', 169, 10],
		inc_for_int => ['MILLIONS', 179, 10],
		int_expense => ['MILLIONS', 189, 10],
		int_minority => ['MILLIONS', 199, 10],
		inc_pre_tax => ['MILLIONS', 209, 10],
		inc_taxes => ['MILLIONS', 219, 10],
		inc_cont_op => ['MILLIONS', 229, 10],
		inc_discont_op => ['MILLIONS', 239, 10],
		inc_op => ['MILLIONS', 249, 10],
		inc_special => ['MILLIONS', 259, 10],
		inc_normalized => ['MILLIONS', 269, 10],
		inc_extra => ['MILLIONS', 279, 10],
		inc_accounting_change => ['MILLIONS', 289, 10],
		inc_tax_carry => ['MILLIONS', 299, 10],
		other_gains => ['MILLIONS', 309, 10],
		inc => ['MILLIONS', 319, 10],
		div_preferred => ['MILLIONS', 329, 10],
		inc_available_common => ['MILLIONS', 339, 10],

		eps_cont_op => ['DOLLARS', 349, 6],
		eps_discont_op => ['DOLLARS', 355, 6],
		eps_op => ['DOLLARS', 361, 6],
		eps_extra => ['DOLLARS', 367, 6],
		eps_accounting_change => ['DOLLARS', 373, 6],
		eps_tax_carry => ['DOLLARS', 379, 6],
		eps_other_gains => ['DOLLARS', 385, 6],
		eps => ['DOLLARS', 391, 6],
		eps_normalized => ['DOLLARS', 397, 6],

		deps_cont_op => ['DOLLARS', 403, 6],
		deps_dicont_op => ['DOLLARS', 409, 6],
		deps_op => ['DOLLARS', 415, 6],
		deps_extra => ['DOLLARS', 421, 6],
		deps_accounting_change => ['DOLLARS', 427, 6],
		deps_tax_carry => ['DOLLARS', 433, 6],
		deps_other_gains => ['DOLLARS', 439, 6],
		deps => ['DOLLARS', 445, 6],
		deps_normalized => ['DOLLARS', 451, 6],

		div_per_share => ['DOLLARS', 457, 6],

		# Year-to-Date
		revenue_ytd => ['MILLIONS', 463, 10],
		inc_ytd => ['MILLIONS', 473, 10],
		eps_ytd => ['DOLLARS', 483, 6],
		div_ytd => ['DOLLARS', 489, 6],
	    },
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
	table_name => 'mgfs_income_statement_t',
	columns => {
	    mg_id => ['Bivio::Data::MGFS::Id', 'PRIMARY_KEY'],
	    date_time => ['Bivio::Data::MGFS::MonthDate', 'PRIMARY_KEY'],
	    quarter => ['Bivio::Data::MGFS::Quarter', 'PRIMARY_KEY'],
	    annual => ['Bivio::Data::MGFS::AnnualCode', 'PRIMARY_KEY'],
	    using_basic_eps => ['Bivio::Data::MGFS::Boolean', 'NOT_NULL'],
	    op_revenue => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    cost_sales => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    gross_op_profit => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    general_expense => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    other_taxes => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    op_profit_pre_dep => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    dep => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    op_profit_post_dep => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    inc_other => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    inc_for_int => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    int_expense => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    int_minority => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    inc_pre_tax => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    inc_taxes => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    inc_cont_op => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    inc_discont_op => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    inc_op => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    inc_special => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    inc_normalized => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    inc_extra => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    inc_accounting_change => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    inc_tax_carry => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    other_gains => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    inc => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    div_preferred => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    inc_available_common => ['Bivio::Data::MGFS::Amount', 'NONE'],

	    eps_cont_op => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    eps_discont_op => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    eps_op => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    eps_extra => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    eps_accounting_change => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    eps_tax_carry => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    eps_other_gains => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    eps => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    eps_normalized => ['Bivio::Data::MGFS::Amount', 'NONE'],

	    deps_cont_op => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    deps_dicont_op => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    deps_op => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    deps_extra => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    deps_accounting_change => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    deps_tax_carry => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    deps_other_gains => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    deps => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    deps_normalized => ['Bivio::Data::MGFS::Amount', 'NONE'],

	    div_per_share => ['Bivio::Data::MGFS::Amount', 'NONE'],

	    # Year-to-Date
	    revenue_ytd => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    inc_ytd => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    eps_ytd => ['Bivio::Data::MGFS::Amount', 'NONE'],
	    div_ytd => ['Bivio::Data::MGFS::Amount', 'NONE'],
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
