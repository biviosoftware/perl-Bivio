
# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Form::f1065::y1999::XlatorSet;
use strict;
$Bivio::UI::PDF::Form::f1065::y1999::XlatorSet::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Form::f1065::y1999::XlatorSet - 

=head1 SYNOPSIS

    use Bivio::UI::PDF::Form::f1065::y1999::XlatorSet;
    Bivio::UI::PDF::Form::f1065::y1999::XlatorSet->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::Form::f1065::XlatorSet>

=cut

use Bivio::UI::PDF::Form::f1065::XlatorSet;
@Bivio::UI::PDF::Form::f1065::y1999::XlatorSet::ISA
	= ('Bivio::UI::PDF::Form::f1065::XlatorSet');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Form::f1065::y1999::XlatorSet>

=cut

#=IMPORTS
use Bivio::UI::PDF::Form::ButtonXlator;
use Bivio::UI::PDF::Form::IntXlator;
use Bivio::UI::PDF::Form::FracXlator;
use Bivio::UI::PDF::Form::RadioBtnXlator;
use Bivio::UI::PDF::Form::StringCatXlator;
use Bivio::UI::PDF::Form::StringXlator;
use Bivio::UI::PDF::Form::TaxId1Xlator;
use Bivio::UI::PDF::Form::TaxId2Xlator;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

my(@_XLATORS) = (
	Bivio::UI::PDF::Form::StringXlator->new('f1-4', 'display_name'),
	Bivio::UI::PDF::Form::StringCatXlator->new('f1-5', 'street1', ', ',
		'street2'),
 	Bivio::UI::PDF::Form::StringCatXlator->new('f1-6', 'city', ', ',
		'state', ' ', 'zip'),
	Bivio::UI::PDF::Form::StringXlator->new('f1-7', 'business_activity'),
	Bivio::UI::PDF::Form::StringXlator->new('f1-8', 'principal_service'),
	Bivio::UI::PDF::Form::StringXlator->new('f1-9', 'business_code'),
	Bivio::UI::PDF::Form::TaxId1Xlator->new('f1-10', 'tax_id'),
	Bivio::UI::PDF::Form::TaxId2Xlator->new('f1-11', 'tax_id'),
	Bivio::UI::PDF::Form::StringXlator->new('f1-12', 'business_start_date'),
	Bivio::UI::PDF::Form::RadioBtnXlator->new('return_type',
		'initial',
		Bivio::UI::PDF::Form::ButtonXlator->new('c1-1', undef),
		'final',
		Bivio::UI::PDF::Form::ButtonXlator->new('c1-2', undef),
		'address',
		Bivio::UI::PDF::Form::ButtonXlator->new('c1-3', undef),
		'amended',
		Bivio::UI::PDF::Form::ButtonXlator->new('c1-4', undef)),
	Bivio::UI::PDF::Form::RadioBtnXlator->new('accounting_method',
		'cash',
		Bivio::UI::PDF::Form::ButtonXlator->new('c1-5', undef),
		'accrual',
		Bivio::UI::PDF::Form::ButtonXlator->new('c1-6', undef),
		'other',
		Bivio::UI::PDF::Form::ButtonXlator->new('c1-7', undef)),
	Bivio::UI::PDF::Form::StringXlator->new('f1-16', 'number_of_k1s'),
	Bivio::UI::PDF::Form::RadioBtnXlator->new('partnership_type',
		'general',
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-10', undef),
		'limited',
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-11', undef),
		'liability',
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-12', undef)),
	Bivio::UI::PDF::Form::RadioBtnXlator->new('partner_is_partnership',
		'yes',
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-15', undef),
		'no',
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-16', undef)),
	Bivio::UI::PDF::Form::RadioBtnXlator->new('partnership_is_partner',
		'yes',
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-17', undef),
		'no',
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-18', undef)),
	Bivio::UI::PDF::Form::RadioBtnXlator->new('consolidated_audit',
		'yes',
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-19', undef),
		'no',
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-20', undef)),
	Bivio::UI::PDF::Form::RadioBtnXlator->new('three_requirements',
		'yes',
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-21', undef),
		'no',
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-22', undef)),
	Bivio::UI::PDF::Form::RadioBtnXlator->new('foreigh_partners',
		'yes',
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-23', undef),
		'no',
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-24', undef)),
	Bivio::UI::PDF::Form::RadioBtnXlator->new('publicly_traded',
		'yes',
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-25', undef),
		'no',
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-26', undef)),
	Bivio::UI::PDF::Form::RadioBtnXlator->new('tax_shelter',
		'yes',
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-27', undef),
		'no',
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-28', undef)),
	Bivio::UI::PDF::Form::RadioBtnXlator->new('foreign_account',
		'yes',
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-29', undef),
		'no',
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-30', undef)),
	Bivio::UI::PDF::Form::StringXlator->new('f2-19', 'foreign_account_country'),
	Bivio::UI::PDF::Form::RadioBtnXlator->new('foreign_trust',
		'yes',
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-31', undef),
		'no',
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-32', undef)),
	Bivio::UI::PDF::Form::RadioBtnXlator->new('withdrawal',
		'yes',
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-33', undef),
		'no',
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-34', undef)),
	Bivio::UI::PDF::Form::IntXlator->new('f3-11', 'interest_income', ','),
	Bivio::UI::PDF::Form::FracXlator->new('f3-12', 'interest_income', 2),
	Bivio::UI::PDF::Form::IntXlator->new('f3-13', 'dividend_income', ','),
	Bivio::UI::PDF::Form::FracXlator->new('f3-14', 'dividend_income', 2),
	Bivio::UI::PDF::Form::IntXlator->new('f3-17', 'net_stcg', ','),
	Bivio::UI::PDF::Form::FracXlator->new('f3-18', 'net_stcg', 2),
	Bivio::UI::PDF::Form::IntXlator->new('f3-20', 'net_ltcg', ','),
	Bivio::UI::PDF::Form::FracXlator->new('f3-21', 'net_ltcg', 2),
	Bivio::UI::PDF::Form::IntXlator->new('f3-22', 'other_portfolio_income', ','),
	Bivio::UI::PDF::Form::FracXlator->new('f3-23', 'other_portfolio_income', 2),
	Bivio::UI::PDF::Form::IntXlator->new('f3-34', 'portfolio_deductions', ','),
	Bivio::UI::PDF::Form::FracXlator->new('f3-35', 'portfolio_deductions', 2),
	Bivio::UI::PDF::Form::IntXlator->new('f3-56', 'investment_income', ','),
	Bivio::UI::PDF::Form::FracXlator->new('f3-57', 'investment_income', 2),
	Bivio::UI::PDF::Form::IntXlator->new('f3-58', 'investment_expenses', ','),
	Bivio::UI::PDF::Form::FracXlator->new('f3-59', 'investment_expenses', 2),
	Bivio::UI::PDF::Form::StringXlator->new('f3-78', 'foreign_income_type'),
	Bivio::UI::PDF::Form::IntXlator->new('f3-80', 'foreign_income', ','),
	Bivio::UI::PDF::Form::FracXlator->new('f3-81', 'foreign_income', 2),
	Bivio::UI::PDF::Form::RadioBtnXlator->new('foreign_tax_type',
		'paid',
		Bivio::UI::PDF::Form::ButtonXlator->new('c3-1', undef),
		'accrued',
		Bivio::UI::PDF::Form::ButtonXlator->new('c3-2', undef)),
	Bivio::UI::PDF::Form::IntXlator->new('f3-84', 'foreign_tax', ','),
	Bivio::UI::PDF::Form::FracXlator->new('f3-85', 'foreign_tax', 2),
	Bivio::UI::PDF::Form::IntXlator->new('f3-93', 'tex_exempt_interest', ','),
	Bivio::UI::PDF::Form::FracXlator->new('f3-94', 'tex_exempt_interest', 2),
	Bivio::UI::PDF::Form::IntXlator->new('f3-99', 'cash_distribution', ','),
	Bivio::UI::PDF::Form::FracXlator->new('f3-100', 'cash_distribution', 2),
	Bivio::UI::PDF::Form::IntXlator->new('f3-101', 'property_distribution', ','),
	Bivio::UI::PDF::Form::FracXlator->new('f3-102', 'property_distribution', 2),
	Bivio::UI::PDF::Form::IntXlator->new('f4-1', 'net_income'),
	Bivio::UI::PDF::Form::FracXlator->new('f4-2', 'net_income', 2),
	Bivio::UI::PDF::Form::StringXlator->new('f4-4', 'active_income'),
	Bivio::UI::PDF::Form::StringXlator->new('f4-5', 'passive_income')
);

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::Form::f1065::y1999::XlatorSet



=cut

sub new {
    my($self) = Bivio::UI::PDF::Form::f1065::XlatorSet::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_xlators_ref"></a>

=head2 get_xlators_ref() : 



=cut

sub get_xlators_ref {
    my($self) = @_;
    return(\@_XLATORS);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
