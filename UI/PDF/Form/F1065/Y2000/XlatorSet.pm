
# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Form::F1065::Y2000::XlatorSet;
use strict;
$Bivio::UI::PDF::Form::F1065::Y2000::XlatorSet::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Form::F1065::Y2000::XlatorSet - the XlatorSet for
F1065::Y2000.

=head1 SYNOPSIS

    use Bivio::UI::PDF::Form::F1065::Y2000::XlatorSet;
    Bivio::UI::PDF::Form::F1065::Y2000::XlatorSet->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::Form::F1065::XlatorSet>

=cut

use Bivio::UI::PDF::Form::F1065::XlatorSet;
@Bivio::UI::PDF::Form::F1065::Y2000::XlatorSet::ISA
	= ('Bivio::UI::PDF::Form::F1065::XlatorSet');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Form::F1065::Y2000::XlatorSet>

=cut

#=IMPORTS
use Bivio::Type::Boolean;
use Bivio::Type::F1065AccountingMethod;
use Bivio::Type::F1065ForeignTax;
use Bivio::Type::F1065Partnership;
use Bivio::Type::F1065Return;
use Bivio::UI::PDF::Form::ButtonXlator;
use Bivio::UI::PDF::Form::DateXlator;
use Bivio::UI::PDF::Form::IntXlator;
use Bivio::UI::PDF::Form::FracXlator;
use Bivio::UI::PDF::Form::MoneyXlator;
use Bivio::UI::PDF::Form::RadioBtnXlator;
use Bivio::UI::PDF::Form::StringCatXlator;
use Bivio::UI::PDF::Form::StringXlator;
use Bivio::UI::PDF::Form::TaxId1Xlator;
use Bivio::UI::PDF::Form::TaxId2Xlator;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

my(@_XLATORS) = (
 	Bivio::UI::PDF::Form::StringXlator->new(
		'f1-4',
		[
		    'auth_realm',
		    'owner',
		    'display_name'
		]
	       ),
  	Bivio::UI::PDF::Form::StringCatXlator->new(
		'f1-5',
		[
		    'Club.Address',
		    'street1'
		],
		', ',
		[
		    'Club.Address',
		    'street2'
		],
	       ),
  	Bivio::UI::PDF::Form::StringCatXlator->new(
		'f1-6',
		[
		    'Club.Address',
		    'city'
		],
		', ',
		[
		    'Club.Address',
		    'state'
		],
		' ',
		[
		    'Club.Address',
		    'zip'
		],
	       ),
 	Bivio::UI::PDF::Form::StringXlator->new(
		'f1-7',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'business_activity'
		]
	       ),
   	Bivio::UI::PDF::Form::StringXlator->new(
		'f1-8',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'principal_service'
		]
	       ),
   	Bivio::UI::PDF::Form::StringXlator->new(
		'f1-9',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'business_code'
		]
	       ),
  	Bivio::UI::PDF::Form::TaxId1Xlator->new(
 		'f1-10',
 		[
 		    'Club.TaxId',
 		    'tax_id'
 		]
 	       ),
 	Bivio::UI::PDF::Form::TaxId2Xlator->new(
		'f1-11',
		[
		    'Club.TaxId',
		    'tax_id'
		]
	       ),
  	Bivio::UI::PDF::Form::DateXlator->new(
		'f1-12',
		[
		    'Club',
		    'start_date'
		]
	       ),
	Bivio::UI::PDF::Form::RadioBtnXlator->new(
		[
		    'Bivio::Biz::Model::F1065Form',
		    'return_type'
		],
		Bivio::Type::F1065Return::INITIAL_RETURN(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c1-1', 'Yes'),
		Bivio::Type::F1065Return::FINAL_RETURN(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c1-2', 'Yes'),
		Bivio::Type::F1065Return::CHANGE_IN_ADDRESS(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c1-3', 'Yes'),
		Bivio::Type::F1065Return::AMENDED_RETURN(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c1-4', 'Yes')
	       ),
	Bivio::UI::PDF::Form::RadioBtnXlator->new(
		[
		    'Bivio::Biz::Model::F1065Form',
		    'accounting_method'
		],
		Bivio::Type::F1065AccountingMethod::CASH(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c1-5', 'Yes'),
		Bivio::Type::F1065AccountingMethod::ACCRUAL(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c1-6', 'Yes'),
		Bivio::Type::F1065AccountingMethod::OTHER(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c1-7', 'Yes')
	       ),
  	Bivio::UI::PDF::Form::StringXlator->new(
		'f1-16',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'number_of_k1s'
		]
	       ),
	Bivio::UI::PDF::Form::RadioBtnXlator->new(
		[
		    'Bivio::Biz::Model::F1065Form',
		    'partnership_type'
		],
		Bivio::Type::F1065Partnership::GENERAL(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-10', 'Yes'),
		Bivio::Type::F1065Partnership::LIMITED(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-11', 'Yes'),
		Bivio::Type::F1065Partnership::LIMITED_LIABILITY_COMPANY(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-12', 'Yes'),
		Bivio::Type::F1065Partnership::LIMITED_LIABILITY(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-14', 'Yes'),
	       ),
	Bivio::UI::PDF::Form::RadioBtnXlator->new(
		[
		    'Bivio::Biz::Model::F1065Form',
		    'partner_is_partnership'
		],
		Bivio::Type::Boolean::TRUE(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-15', 'Yes'),
		Bivio::Type::Boolean::FALSE(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-16', 'Yes')
	       ),
	Bivio::UI::PDF::Form::RadioBtnXlator->new(
		[
		    'Bivio::Biz::Model::F1065Form',
		    'partnership_is_partner'
		],
		Bivio::Type::Boolean::TRUE(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-17', 'Yes'),
		Bivio::Type::Boolean::FALSE(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-18', 'Yes')
	       ),
	Bivio::UI::PDF::Form::RadioBtnXlator->new(
		[
		    'Bivio::Biz::Model::F1065Form',
		    'consolidated_audit'
		],
		Bivio::Type::Boolean::TRUE(),
		[
		    Bivio::UI::PDF::Form::ButtonXlator->new('c2-19', 'Yes'),
		    # We only print the Designation of Tax Matters Partner
		    # information when the consolidated_edit checkbox is true.
		    Bivio::UI::PDF::Form::StringXlator->new(
			    'f2-20',
			    [
				'User.RealmOwner',
				'display_name'
			    ]
			   ),
		    Bivio::UI::PDF::Form::StringXlator->new(
			    'f2-21',
			    [
				'User.TaxId',
				'tax_id'
			    ]
			   ),
		    Bivio::UI::PDF::Form::StringCatXlator->new(
			    'f2-22',
			    [
				'User.Address',
				'street1'
			    ],
			    ', ',
			    [
				'User.Address',
				'street2'
			    ],
			   ),
		    Bivio::UI::PDF::Form::StringCatXlator->new(
			    'f2-23',
			    [
				'User.Address',
				'city'
			    ],
			    ', ',
			    [
				'User.Address',
				'state'
			    ],
			    ' ',
			    [
				'User.Address',
				'zip'
			    ],
			   ),
		],
		Bivio::Type::Boolean::FALSE(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-20', 'Yes')
	       ),
	Bivio::UI::PDF::Form::RadioBtnXlator->new(
		[
		    'Bivio::Biz::Model::F1065Form',
		    'three_requirements'
		],
		Bivio::Type::Boolean::TRUE(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-21', 'Yes'),
		Bivio::Type::Boolean::FALSE(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-22', 'Yes')
	       ),
	Bivio::UI::PDF::Form::RadioBtnXlator->new(
		[
		    'Bivio::Biz::Model::F1065Form',
		    'foreign_partners'
		],
		Bivio::Type::Boolean::TRUE(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-23', 'Yes'),
		Bivio::Type::Boolean::FALSE(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-24', 'Yes')
	       ),
	Bivio::UI::PDF::Form::RadioBtnXlator->new(
		[
		    'Bivio::Biz::Model::F1065Form',
		    'publicly_traded'
		],
		Bivio::Type::Boolean::TRUE(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-25', 'Yes'),
		Bivio::Type::Boolean::FALSE(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-26', 'Yes')
	       ),
	Bivio::UI::PDF::Form::RadioBtnXlator->new(
		[
		    'Bivio::Biz::Model::F1065Form',
		    'tax_shelter'
		],
		Bivio::Type::Boolean::TRUE(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-27', 'Yes'),
		Bivio::Type::Boolean::FALSE(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-28', 'Yes')
	       ),
	Bivio::UI::PDF::Form::RadioBtnXlator->new(
		[
		    'Bivio::Biz::Model::F1065Form',
		    'foreign_account'
		],
		Bivio::Type::Boolean::TRUE(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-29', 'Yes'),
		Bivio::Type::Boolean::FALSE(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-30', 'Yes')
	       ),
	Bivio::UI::PDF::Form::StringXlator->new(
		'f2-19',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'foreign_account_country'
		]
	       ),
	Bivio::UI::PDF::Form::RadioBtnXlator->new(
		[
		    'Bivio::Biz::Model::F1065Form',
		    'foreign_trust'
		],
		Bivio::Type::Boolean::TRUE(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-29a', 'Yes'),
		Bivio::Type::Boolean::FALSE(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-30a', 'Yes')
	       ),
	Bivio::UI::PDF::Form::RadioBtnXlator->new(
		[
		    'Bivio::Biz::Model::F1065Form',
		    'transfer_of_interest'
		],
		Bivio::Type::Boolean::TRUE(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-31', 'Yes'),
		Bivio::Type::Boolean::FALSE(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-32', 'Yes')
	       ),
  	Bivio::UI::PDF::Form::StringXlator->new(
		'f2-19a',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'number_of_8865_forms'
		]
	       ),
 	Bivio::UI::PDF::Form::IntXlator->new(
		'f3-11',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'interest_income'
		],
		','),
 	Bivio::UI::PDF::Form::FracXlator->new(
		'f3-12',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'interest_income'
		],
		2
	       ),
	Bivio::UI::PDF::Form::IntXlator->new(
		'f3-13',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'dividend_income'
		],
		','
	       ),
	Bivio::UI::PDF::Form::FracXlator->new(
		'f3-14',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'dividend_income'
		],
		2
	       ),
	Bivio::UI::PDF::Form::IntXlator->new(
		'f3-17',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'net_stcg'
		],
		','
	       ),
	Bivio::UI::PDF::Form::FracXlator->new(
		'f3-18',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'net_stcg'
		],
		2
	       ),
	Bivio::UI::PDF::Form::IntXlator->new(
		'f3-20',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'net_ltcg'
		],
		','
	       ),
	Bivio::UI::PDF::Form::FracXlator->new(
		'f3-21',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'net_ltcg'
		],
		2
	       ),
	Bivio::UI::PDF::Form::IntXlator->new(
		'f3-22',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'other_portfolio_income'
		],
		','
	       ),
	Bivio::UI::PDF::Form::FracXlator->new(
		'f3-23',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'other_portfolio_income'
		],
		2
	       ),
	Bivio::UI::PDF::Form::IntXlator->new(
		'f3-34',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'portfolio_deductions'
		],
		','
	       ),
	Bivio::UI::PDF::Form::FracXlator->new(
		'f3-35',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'portfolio_deductions'
		],
		2
	       ),
	Bivio::UI::PDF::Form::IntXlator->new(
		'f3-54',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'margin_interest',
		],
		','
	       ),
	Bivio::UI::PDF::Form::FracXlator->new(
		'f3-55',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'margin_interest'
		],
		2
	       ),
	Bivio::UI::PDF::Form::IntXlator->new(
		'f3-56',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'investment_income'
		],
		','
	       ),
	Bivio::UI::PDF::Form::FracXlator->new(
		'f3-57',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'investment_income'
		],
		2
	       ),
	Bivio::UI::PDF::Form::IntXlator->new(
		'f3-58',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'investment_expenses'
		],
		','
	       ),
	Bivio::UI::PDF::Form::FracXlator->new(
		'f3-59',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'investment_expenses'
		],
		2
	       ),
 	Bivio::UI::PDF::Form::StringXlator->new(
		'f3-78',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'foreign_income_country'
		]
	       ),
	Bivio::UI::PDF::Form::MoneyXlator->new(
		'f3-79',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'foreign_income'
		]
	       ),
	Bivio::UI::PDF::Form::RadioBtnXlator->new(
		[
		    'Bivio::Biz::Model::F1065Form',
		    'foreign_tax_type'
		],
		Bivio::Type::F1065ForeignTax::PAID(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c3-1', 'Yes'),
		Bivio::Type::F1065ForeignTax::ACCRUED(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c3-2', 'Yes')
	       ),
	Bivio::UI::PDF::Form::IntXlator->new(
		'f3-88',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'foreign_tax'
		],
		','
	       ),
	Bivio::UI::PDF::Form::FracXlator->new(
		'f3-89',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'foreign_tax'
		],
		2
	       ),
	Bivio::UI::PDF::Form::IntXlator->new(
		'f3-95',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'tax_exempt_interest'
		],
		','
	       ),
	Bivio::UI::PDF::Form::FracXlator->new(
		'f3-96',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'tax_exempt_interest'
		],
		2
	       ),
	Bivio::UI::PDF::Form::IntXlator->new(
		'f3-99',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'nondeductible_expenses',
		],
		','
	       ),
	Bivio::UI::PDF::Form::FracXlator->new(
		'f3-100',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'nondeductible_expenses'
		],
		2
	       ),
	Bivio::UI::PDF::Form::IntXlator->new(
		'f3-101',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'cash_distribution'
		],
		','
	       ),
	Bivio::UI::PDF::Form::FracXlator->new(
		'f3-102',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'cash_distribution'
		],
		2
	       ),
	Bivio::UI::PDF::Form::IntXlator->new(
		'f3-103',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'property_distribution'
		],
		','
	       ),
	Bivio::UI::PDF::Form::FracXlator->new(
		'f3-104',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'property_distribution'
		],
		2
	       ),
	Bivio::UI::PDF::Form::IntXlator->new(
		'f4-1',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'net_income'
		],
		','
	       ),
	Bivio::UI::PDF::Form::FracXlator->new(
		'f4-2',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'net_income'
		],
		2
	       ),
	Bivio::UI::PDF::Form::MoneyXlator->new(
		'f4-4',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'active_income'
		],
		',',
		2
	       ),
	Bivio::UI::PDF::Form::MoneyXlator->new(
		'f4-5',
		[
		    'Bivio::Biz::Model::F1065Form',
		    'passive_income'
		],
		',',
		2
	       ),
);

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::Form::F1065::Y2000::XlatorSet



=cut

sub new {
    my($self) = Bivio::UI::PDF::Form::F1065::XlatorSet::new(@_);
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

=for html <a name="set_up"></a>

=head2 set_up() : 



=cut

sub set_up {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    # Load the club's address onto the request.
    my($club_address) = Bivio::Biz::Model::Address->new($req);
    $club_address->load(location => Bivio::Type::Location::HOME());
    $req->put('Club.Address' => $club_address);

    # Load the club's tax id onto the request.
    my($club_tax_id) = Bivio::Biz::Model::TaxId->new($req);
    $club_tax_id->load();
    $req->put('Club.TaxId' => $club_tax_id);

    # Load the club itself.
    my($club) = Bivio::Biz::Model::Club->new($req);
    $club->load();
    $req->put('Club' => $club);

    # Load the user's realm id onto the request.
    my($user_realm) = $req->get('auth_user');
    $user_realm->unauth_load_or_die(realm_id => $user_realm->get('realm_id'));
    $req->put('User.RealmOwner' => $user_realm);

    # Load the user's address onto the request.
    my($user_address) = Bivio::Biz::Model::Address->new($req);
    $user_address->unauth_load_or_die(
	    realm_id => $user_realm->get('realm_id'),
	    location => Bivio::Type::Location::HOME());
    $req->put('User.Address' => $user_address);

    # Load the user's tax_id onto the request.
    my($user_tax_id) = Bivio::Biz::Model::TaxId->new($req);
    $user_tax_id->unauth_load_or_die(realm_id => $user_realm->get('realm_id'));
    $req->put('User.TaxId' => $user_tax_id);

    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
