# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Form::Request;
use strict;
$Bivio::UI::PDF::Form::Request::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Form::Request - 

=head1 SYNOPSIS

    use Bivio::UI::PDF::Form::Request;
    Bivio::UI::PDF::Form::Request->new();

=cut

use Bivio::UNIVERSAL;
@Bivio::UI::PDF::Form::Request::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Form::Request>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::Form::Request



=cut

sub new {
    my($self) = Bivio::UNIVERSAL::new(@_);
    $self->{$_PACKAGE} = {
	'display_name' => 'Fly-By-Night Investments',
	'street1' => 'Suite 200',
	'street2' => '364 Main Street',
	'city' => 'Boston',
	'state' => 'MA',
	'zip' => '02145',
	'business_activity' => 'Shady Investments',
	'principal_service' => 'Profits',
	'business_code' => '1234',
	'tax_id' => '46-4968432',
	'business_start_date' => 'Feb. 11, 1945',
	'return_type' => 'final',
	'accounting_method' => 'cash',
	'number_of_k1s' => '6',
	'partnership_type' => 'general',
	'partner_is_partnership' => 'yes',
	'partnership_is_partner' => 'no',
	'consolidated_audit' => 'no',
	'three_requirements' => 'yes',
	'foreigh_partners' => 'no',
	'publicly_traded' => 'no',
	'tax_shelter' => 'no',
	'foreign_account' => 'no',
	'foreign_account_country' => 'Mexico',
	'foreign_trust' => 'no',
	'withdrawal' => 'no',
	'interest_income' => '243.56',
	'dividend_income' => '54.68',
	'net_stcg' => '4555.39',
	'net_ltcg' => '3998.45',
	'other_portfolio_income' => '45.59',
	'portfolio_deductions' => '45.78',
	'investment_income' => '300.45',
	'investment_income' => '356.90',
	'investment_expenses' => '432.21',
	'foreign_income_type' => 'Kick backs',
	'foreign_income' => '5443.34',
	'foreign_tax_type' => 'accrued',
	'foreign_tax' => '452.34',
	'tex_exempt_interest' => '433.56',
	'cash_distribution' => '469.45',
	'property_distribution' => '364.98',
	'net_income' => '465.90',
	'active_income' => '3456.78',
	'passive_income' => '469.31'
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_input"></a>

=head2 get_input() : 



=cut

sub get_input {
    my($self, $name) = @_;
    my($fields) = $self->{$_PACKAGE};
    return($fields->{$name});
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
