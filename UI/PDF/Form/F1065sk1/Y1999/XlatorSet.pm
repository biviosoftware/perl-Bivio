
# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Form::F1065sk1::Y1999::XlatorSet;
use strict;
$Bivio::UI::PDF::Form::F1065sk1::Y1999::XlatorSet::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Form::F1065sk1::Y1999::XlatorSet - the XlatorSet for
F1065sk1::Y1999.

=head1 SYNOPSIS

    use Bivio::UI::PDF::Form::F1065sk1::Y1999::XlatorSet;
    Bivio::UI::PDF::Form::F1065sk1::Y1999::XlatorSet->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::Form::F1065sk1::XlatorSet>

=cut

use Bivio::UI::PDF::Form::F1065sk1::XlatorSet;
@Bivio::UI::PDF::Form::F1065sk1::Y1999::XlatorSet::ISA
	= ('Bivio::UI::PDF::Form::F1065sk1::XlatorSet');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Form::F1065sk1::Y1999::XlatorSet>

=cut

#=IMPORTS
use Bivio::Type::Boolean;
use Bivio::Type::F1065ForeignTax;
use Bivio::Type::F1065IRSCenter;
use Bivio::Type::F1065Partner;
use Bivio::Type::F1065Return;
use Bivio::UI::PDF::Form::ButtonXlator;
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

# NOTE: The button fields in this form need the value 'On' instead of the more
# standard 'Yes' to turn them on.

my(@_XLATORS) = (
 	Bivio::UI::PDF::Form::StringXlator->new(
		'f1-4',
		[
		    'User.TaxId',
		    'tax_id'
		]
	       ),
 	Bivio::UI::PDF::Form::StringCatXlator->new(
		'f1-5',
		[
		    'User',
		    'display_name'
		],
		"\n",
		[
		    'User.Address',
		    'street1'
		],
		"\n",
		[
		    'User.Address',
		    'street2'
		],
		"\n",
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
 	Bivio::UI::PDF::Form::TaxId1Xlator->new(
		'f1-6',
		[
		    'Club.TaxId',
		    'tax_id'
		]
	       ),
 	Bivio::UI::PDF::Form::TaxId2Xlator->new(
		'f1-7',
		[
		    'Club.TaxId',
		    'tax_id'
		]
	       ),
 	Bivio::UI::PDF::Form::StringCatXlator->new(
		'f1-8',
		[
		    'auth_realm',
		    'owner',
		    'display_name'
		],
		"\n",
		[
		    'Club.Address',
		    'street1'
		],
		"\n",
		[
		    'Club.Address',
		    'street2'
		],
		"\n",
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
	Bivio::UI::PDF::Form::RadioBtnXlator->new(
		[
		    'Bivio::Biz::Model::F1065K1Form',
		    'partner_type'
		],
		Bivio::Type::F1065Partner::GENERAL(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c1-1', 'On'),
		Bivio::Type::F1065Partner::LIMITED(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c1-2', 'On'),
		Bivio::Type::F1065Partner::LIMITED_LIABILITY_COMPANY_MEMBER(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c1-3', 'On')
	       ),
  	Bivio::UI::PDF::Form::StringXlator->new(
		'f1-9',
		[
		    'Bivio::Biz::Model::F1065K1Form',
		    'entity_type',
		    '->get_short_desc'
		],
	       ),
 	Bivio::UI::PDF::Form::RadioBtnXlator->new(
		[
		    'Bivio::Biz::Model::F1065K1Form',
		    'foreign'
		],
		Bivio::Type::Boolean::FALSE(),
 		Bivio::UI::PDF::Form::ButtonXlator->new('c1-4', 'On'),
		Bivio::Type::Boolean::TRUE(),
 		Bivio::UI::PDF::Form::ButtonXlator->new('c1-5', 'On')),
 	Bivio::UI::PDF::Form::FloatXlator->new(
		'f1-10',
		[
		    'Bivio::Biz::Model::F1065K1Form',
		    'percentage_start'
		],
		',', 2
	       ),
 	Bivio::UI::PDF::Form::FloatXlator->new(
		'f1-11',
		[
		    'Bivio::Biz::Model::F1065K1Form',
		    'percentage_end'
		],
		',', 2
	       ),
 	Bivio::UI::PDF::Form::FloatXlator->new(
		'f1-12',
		[
		    'Bivio::Biz::Model::F1065K1Form',
		    'percentage_start'
		],
		',', 2
	       ),
 	Bivio::UI::PDF::Form::FloatXlator->new(
		'f1-13',
		[
		    'Bivio::Biz::Model::F1065K1Form',
		    'percentage_end'
		],
		',', 2
	       ),
 	Bivio::UI::PDF::Form::FloatXlator->new(
		'f1-14',
		[
		    'Bivio::Biz::Model::F1065K1Form',
		    'percentage_start'
		],
		',', 2
	       ),
 	Bivio::UI::PDF::Form::FloatXlator->new(
		'f1-15',
		[
		    'Bivio::Biz::Model::F1065K1Form',
		    'percentage_end'
		],
		',', 2
	       ),
 	Bivio::UI::PDF::Form::StringXlator->new(
		'f1-15a',
		[
		    'Bivio::Biz::Model::F1065K1Form',
		    'irs_center',
		    '->get_long_desc'
		]
	       ),
 	Bivio::UI::PDF::Form::RadioBtnXlator->new(
		[
		    'Bivio::Biz::Model::F1065K1Form',
		    'return_type'
		],
		Bivio::Type::F1065Return::FINAL_RETURN(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c1-7', 'On'),
		Bivio::Type::F1065Return::AMENDED_RETURN(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c1-8', 'On')
	       ),
 	Bivio::UI::PDF::Form::MoneyXlator->new(
		'f1-28',
		[
		    'Bivio::Biz::Model::F1065K1Form',
		    'interest_income'
		]
	       ),
 	Bivio::UI::PDF::Form::MoneyXlator->new(
		'f1-29',
		[
		    'Bivio::Biz::Model::F1065K1Form',
		    'dividend_income'
		]
	       ),
 	Bivio::UI::PDF::Form::MoneyXlator->new(
		'f1-31',
		[
		    'Bivio::Biz::Model::F1065K1Form',
		    'net_stcg'
		]
	       ),
 	Bivio::UI::PDF::Form::MoneyXlator->new(
		'f1-33',
		[
		    'Bivio::Biz::Model::F1065K1Form',
		    'net_ltcg'
		]
	       ),
 	Bivio::UI::PDF::Form::MoneyXlator->new(
		'f1-34',
		[
		    'Bivio::Biz::Model::F1065K1Form',
		    'other_portfolio_income'
		]
	       ),
 	Bivio::UI::PDF::Form::MoneyXlator->new(
		'f1-40',
		[
		    'Bivio::Biz::Model::F1065K1Form',
		    'portfolio_deductions'
		]
	       ),
 	Bivio::UI::PDF::Form::MoneyXlator->new(
		'f2-2',
		[
		    'Bivio::Biz::Model::F1065K1Form',
		    'investment_income'
		]
	       ),
 	Bivio::UI::PDF::Form::MoneyXlator->new(
		'f2-3',
		[
		    'Bivio::Biz::Model::F1065K1Form',
		    'investment_expenses'
		]
	       ),
 	Bivio::UI::PDF::Form::StringXlator->new(
		'f2-13',
		[
		    'Bivio::Biz::Model::F1065K1Form',
		    'foreign_income_type'
		]
	       ),
 	Bivio::UI::PDF::Form::StringXlator->new(
		'f2-14',
		[
		    'Bivio::Biz::Model::F1065K1Form',
		    'foreign_income_country'
		]
	       ),
 	Bivio::UI::PDF::Form::MoneyXlator->new(
		'f2-15',
		[
		    'Bivio::Biz::Model::F1065K1Form',
		    'foreign_income'
		]
	       ),
 	Bivio::UI::PDF::Form::RadioBtnXlator->new(
		[
		    'Bivio::Biz::Model::F1065K1Form',
		    'foreign_tax_type'
		],
		Bivio::Type::F1065ForeignTax::PAID(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-1', 'On'),
		Bivio::Type::F1065ForeignTax::ACCRUED(),
		Bivio::UI::PDF::Form::ButtonXlator->new('c2-2', 'On')
	       ),
 	Bivio::UI::PDF::Form::MoneyXlator->new(
		'f2-17',
		[
		    'Bivio::Biz::Model::F1065K1Form',
		    'foreign_tax'
		]
	       ),
 	Bivio::UI::PDF::Form::MoneyXlator->new(
		'f2-22',
		[
		    'Bivio::Biz::Model::F1065K1Form',
		    'tax_exempt_interest'
		]
	       ),
 	Bivio::UI::PDF::Form::MoneyXlator->new(
		'f2-25',
		[
		    'Bivio::Biz::Model::F1065K1Form',
		    'cash_distribution'
		]
	       ),
 	Bivio::UI::PDF::Form::MoneyXlator->new(
		'f2-26',
		[
		    'Bivio::Biz::Model::F1065K1Form',
		    'property_distribution'
		]
	       ),
);

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::Form::F1065sk1::Y1999::XlatorSet



=cut

sub new {
    my($self) = Bivio::UI::PDF::Form::F1065sk1::XlatorSet::new(@_);
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

    # Load the user's name on the request.
    my($realm_user) = $req->get('Bivio::Biz::Model::RealmUser');
    my($user_realm) = Bivio::Biz::Model::RealmOwner->new($req);
    $user_realm->unauth_load_or_die(realm_id => $realm_user->get('user_id'));
    $req->put('User' => $user_realm);

    # Load the user's address onto the request.
    my($user_address) = Bivio::Biz::Model::Address->new($req);
    $user_address->unauth_load_or_die(realm_id => $user_realm->get('realm_id'));
    $req->put('User.Address' => $user_address);

    # Load the user's tax id onto the request.
    my($user_tax_id) = Bivio::Biz::Model::TaxId->new($req);
    $user_tax_id->unauth_load_or_die(realm_id => $user_realm->get('realm_id'));
    $req->put('User.TaxId' => $user_tax_id);

    # Load the club's address onto the request.
    my($club_address) = Bivio::Biz::Model::Address->new($req);
    $club_address->load(location => Bivio::Type::Location::HOME());
    $req->put('Club.Address' => $club_address);

    # Load the club's tax id onto the request.
    my($club_tax_id) = Bivio::Biz::Model::TaxId->new($req);
    $club_tax_id->load();
    $req->put('Club.TaxId' => $club_tax_id);

    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
