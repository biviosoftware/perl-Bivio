# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::F1065K1Form;
use strict;
$Bivio::Biz::Model::F1065K1Form::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::F1065K1Form - IRS 1065 K-1 fields

=head1 SYNOPSIS

    use Bivio::Biz::Model::F1065K1Form;
    Bivio::Biz::Model::F1065K1Form->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::F1065K1Form::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::F1065K1Form> IRS 1065 K-1 fields

=cut

#=IMPORTS
use Bivio::Biz::Accounting::ClubOwnership;
use Bivio::Biz::Accounting::Tax;
use Bivio::Biz::Model::F1065Form;
use Bivio::Biz::Model::RealmOwner;
use Bivio::Biz::Model::Tax1065;
use Bivio::Biz::Model::TaxK1;
use Bivio::Collection::Attributes;
use Bivio::SQL::Connection;
use Bivio::Type::Amount;
use Bivio::Type::Date;
use Bivio::Type::DateTime;
use Bivio::Type::EntryClass;
use Bivio::Type::EntryType;
use Bivio::Type::F1065ForeignTax;
use Bivio::Type::F1065Return;
use Bivio::Type::F1065Partner;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_SQL_DATE_VALUE) = Bivio::Type::DateTime->to_sql_value('?');

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Loads the form values.

  1065 schedule K-1

  Partner
  id      User.TaxId.tax_id
  name    User.RealmOwner.display_name
  address User.Address.street1
          User.Address.street2
          User.Address.city
          User.Address.state
          User.Address.zip

  Partnership
  id      Club.TaxId.tax_id
  name    Club.RealmOwner.display_name
  address Club.Address.street1
          Club.Address.street2
          Club.Address.city
          Club.Address.state
          Club.Address.zip

  A       F1065K1Form.partner_type
  B       F1065K1Form.entity_type
  C       F1065K1Form.foreign
  D(i)    F1065K1Form.percentage_start
  D(ii)   F1065K1Form.percentage_end
  E       F1065K1Form.irs_center
  I       F1065K1Form.return_type

   4a     F1065K1Form.interest_income
   4b     F1065K1Form.dividend_income
   4d     F1065K1Form.net_stcg
   4e(2)  F1065K1Form.net_ltcg
   4f     F1065K1Form.other_portfolio_income
  10      F1065K1Form.portfolio_deductions
  14b(1)  F1065K1Form.investment_income
  14b(2)  F1065K1Form.investment_expenses
  17a     F1065K1Form.foreign_income_type
  17b     F1065K1Form.foreign_income_country
  17c     F1065K1Form.foreign_income
  17e     F1065K1Form.foreign_tax_type
  17e     F1065K1Form.foreign_tax
  19      F1065K1Form.tax_exempt_interest
  22      F1065K1Form.cash_distribution
  23      F1065K1Form.property_distribution

=cut

sub execute_empty {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE} = {};
    my($req) = $self->get_request;
    my($properties) = $self->internal_get;

    my($date) = $req->get('report_date');
    my($tax) = 'Bivio::Type::TaxCategory';

    # Get the target user
#    my($user) = $req->get('target_realm_owner');
    my($realm_user) = $req->get('Bivio::Biz::Model::RealmUser');
    my($user) = Bivio::Biz::Model::RealmOwner->new($req);
    $user->unauth_load_or_die(realm_id => $realm_user->get('user_id'));

    my($taxk1) = Bivio::Biz::Model::TaxK1->new($req);
    unless ($taxk1->unsafe_load(fiscal_end_date => $date,
	   user_id => $user->get('realm_id'))) {
	my($user_id) = $user->get('realm_id');
	my($address) = Bivio::Biz::Model::Address->new($req);
	$address->unauth_load_or_die(realm_id => $user_id,
		location => Bivio::Type::Location::HOME());
	$taxk1->create_default($user_id, $date);
    }

    my($allocations) = _get_user_allocations($self, $user, $date);

    $properties->{partner_type} = $taxk1->get('partner_type');
    $properties->{entity_type} = $taxk1->get('entity_type');
    $properties->{foreign} = $taxk1->get('foreign_partner');
    $properties->{percentage_start} = _get_percentage($self, $user, $date, 1);
    $properties->{percentage_end} = _get_percentage($self, $user, $date, 0);
    $properties->{irs_center} = _get_irs_center($self, $taxk1);
    $properties->{return_type} = _get_return_type($self, $user, $date);

    $properties->{interest_income} = $allocations->get_or_default(
	$tax->INTEREST->get_short_desc, 0);
    $properties->{dividend_income} = $allocations->get_or_default(
	$tax->DIVIDEND->get_short_desc, 0);
    $properties->{net_stcg} = $allocations->get_or_default(
	$tax->SHORT_TERM_CAPITAL_GAIN->get_short_desc, 0);
    $properties->{net_ltcg} = $allocations->get_or_default(
	$tax->LONG_TERM_CAPITAL_GAIN->get_short_desc, 0);
    $properties->{other_portfolio_income} = $allocations->get_or_default(
	$tax->MISC_INCOME->get_short_desc, 0);
    $properties->{portfolio_deductions} = _negative(
	    $allocations->get_or_default($tax->MISC_EXPENSE->get_short_desc,
		    0));

    $properties->{investment_income} = Bivio::Biz::Model::F1065Form
	    ->get_investment_income($properties);
    $properties->{investment_expenses} = $properties->{portfolio_deductions};

    $properties->{foreign_tax} = _negative(
	    $allocations->get_or_default($tax->FOREIGN_TAX->get_short_desc,
		    0));
    $properties->{foreign_income} = _get_foreign_income($self,
	    $properties->{foreign_tax}, $date);
    $properties->{foreign_income_country} = '';
    $properties->{foreign_income_type} = $properties->{foreign_tax} == 0
	    ? '' : 'Passive';
    $properties->{foreign_tax_type} = $properties->{foreign_tax} == 0
	    ? Bivio::Type::F1065ForeignTax->UNKNOWN
	    : Bivio::Type::F1065ForeignTax->PAID;
    $properties->{tax_exempt_interest} = $allocations->get_or_default(
	    $tax->FEDERAL_TAX_FREE_INTEREST->get_short_desc, 0);
    $properties->{cash_distribution} =
	    _get_cash_withdrawal_amount($self, $user, $date);
    $properties->{property_distribution} =
	    _get_stock_withdrawal_amount($self, $user, $date);

    _round_all($self, $properties);
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	hidden => [
	    {
		name => 'partner_type',
		type => 'F1065Partner',
		constraint => 'NONE',
	    },
	    {
		name => 'entity_type',
		type => 'Bivio::Type::F1065Entity',
		constraint => 'NONE',
	    },
	    {
		name => 'foreign',
		type => 'Boolean',
		constraint => 'NONE',
	    },
	    {
		name => 'percentage_start',
		type => 'Amount',
		constraint => 'NONE',
	    },
	    {
		name => 'percentage_end',
		type => 'Amount',
		constraint => 'NONE',
	    },
	    {
		name => 'irs_center',
		type => 'F1065IRSCenter',
		constraint => 'NONE',
	    },
	    {
		name => 'return_type',
		type => 'F1065Return',
		constraint => 'NONE',
	    },
	    {
		name => 'interest_income',
		type => 'Amount',
		constraint => 'NONE',
	    },
	    {
		name => 'dividend_income',
		type => 'Amount',
		constraint => 'NONE',
	    },
	    {
		name => 'net_stcg',
		type => 'Amount',
		constraint => 'NONE',
	    },
	    {
		name => 'net_ltcg',
		type => 'Amount',
		constraint => 'NONE',
	    },
	    {
		name => 'other_portfolio_income',
		type => 'Amount',
		constraint => 'NONE',
	    },
	    {
		name => 'portfolio_deductions',
		type => 'Amount',
		constraint => 'NONE',
	    },
	    {
		name => 'investment_income',
		type => 'Amount',
		constraint => 'NONE',
	    },
	    {
		name => 'investment_expenses',
		type => 'Amount',
		constraint => 'NONE',
	    },
	    {
		name => 'foreign_income_type',
		type => 'Line',
		constraint => 'NONE',
	    },
	    {
		name => 'foreign_income_country',
		type => 'Line',
		constraint => 'NONE',
	    },
	    {
		name => 'foreign_income',
		type => 'Amount',
		constraint => 'NONE',
	    },
	    {
		name => 'foreign_tax_type',
		type => 'F1065ForeignTax',
		constraint => 'NONE',
	    },
	    {
		name => 'foreign_tax',
		type => 'Amount',
		constraint => 'NONE',
	    },
	    {
		name => 'tax_exempt_interest',
		type => 'Amount',
		constraint => 'NONE',
	    },
	    {
		name => 'cash_distribution',
		type => 'Amount',
		constraint => 'NONE',
	    },
	    {
		name => 'property_distribution',
		type => 'Amount',
		constraint => 'NONE',
	    },
	],
    };
}

#=PRIVATE METHODS

# _get_cash_withdrawal_amount(Bivio::Biz::Model::RealmOwner user, string date) : string
#
# Returns the total cash amount withdrawn by the specified user.
#
sub _get_cash_withdrawal_amount {
    my($self, $user, $date) = @_;

    # get tax year start
    my($start_date) = Bivio::Biz::Accounting::Tax->get_start_of_fiscal_year(
	    $date);
    my($entry_type) = 'Bivio::Type::EntryType';
    my($sth) = Bivio::SQL::Connection->execute("
            SELECT -SUM(entry_t.amount)
            FROM entry_t
            WHERE entry_t.class=?
            AND entry_t.realm_id=?
            AND entry_t.realm_transaction_id IN (
                SELECT DISTINCT realm_transaction_t.realm_transaction_id
                FROM realm_transaction_t, entry_t, member_entry_t
                WHERE realm_transaction_t.realm_transaction_id
                    =entry_t.realm_transaction_id
                AND entry_t.entry_id=member_entry_t.entry_id
                AND member_entry_t.user_id=?
                AND entry_t.entry_type in (?, ?, ?, ?)
                AND realm_transaction_t.date_time BETWEEN
                    $_SQL_DATE_VALUE AND $_SQL_DATE_VALUE
                AND realm_transaction_t.realm_id=?)",
	    [Bivio::Type::EntryClass->CASH->as_int,
		    $self->get_request->get('auth_id'),

		    $user->get('realm_id'),
		    $entry_type->MEMBER_WITHDRAWAL_FULL_CASH->as_int,
		    $entry_type->MEMBER_WITHDRAWAL_PARTIAL_CASH->as_int,
		    $entry_type->MEMBER_WITHDRAWAL_FULL_STOCK->as_int,
		    $entry_type->MEMBER_WITHDRAWAL_PARTIAL_STOCK->as_int,
		    $start_date, $date,
		    $self->get_request->get('auth_id')]);

    my($amount) = 0;
    while (my $row = $sth->fetchrow_arrayref) {
	$amount = $row->[0] || 0;
    }
    return $amount;
}

# _get_foreign_income(string foreign_tax, string date) : string
#
# Returns the amount of foreign income allocated to the user.
#
sub _get_foreign_income {
    my($self, $foreign_tax, $date) = @_;
    my($req) = $self->get_request;

    return 0 if $foreign_tax == 0;

    my($total_foreign_income) = Bivio::Biz::Model::F1065Form
	    ->get_foreign_income($self->get_request, $date);

    my($income) = $req->get('Bivio::Biz::Model::IncomeAndExpenseList');
    $income->reset_cursor;
    $income->next_row || die("couldn't load income/expense list");

    my($tax) = 'Bivio::Type::TaxCategory';
    my($total_foreign_tax) = $income->get($tax->FOREIGN_TAX->get_short_desc);

    # return the percentage of the total foreign income
    # in proportion to the foreign_tax percentage
    return Bivio::Type::Amount->mul($total_foreign_income,
	    Bivio::Type::Amount->div($foreign_tax, $total_foreign_tax));
}

# _get_irs_center(Bivio::Biz::Model::TaxK1 taxk1) : Bivio::Type::F1065IRSCenter
#
# Returns the IRS center of the partnership.
#
sub _get_irs_center {
    my($self, $taxk1) = @_;
    my($date) = $taxk1->get('fiscal_end_date');
    my($tax1065) = Bivio::Biz::Model::Tax1065->new($self->get_request);
    unless ($tax1065->unsafe_load(fiscal_end_date => $date)) {
	$tax1065->create_default($date);
    }
    return $tax1065->get('irs_center');
}

# _get_percentage(Bivio::Biz::Model::RealmOwner user, string date, boolean start) : string
#
# Returns the member's percentage ownership at the start or end of the
# tax year.
#
sub _get_percentage {
    my($self, $user, $date, $start) = @_;

    if ($start) {
	$date = Bivio::Biz::Accounting::Tax->get_start_of_fiscal_year($date);
    }
    my($ownership) = Bivio::Biz::Accounting::ClubOwnership->new(
	    $self->get_request->get('auth_realm')->get('owner'), $date);
    my($date_own) = $ownership->get_ownership($date);
    return 0 unless exists($date_own->{$user->get('realm_id')});

    return Bivio::Type::Amount->mul(
	    $date_own->{$user->get('realm_id')}->[0], 100);
}

# _get_return_type(Bivio::Biz::Model::RealmOwner user, string date) : Bivio::Type::F1065Return
#
# Determines the user's type of return. Final for total withdrawals.
#
sub _get_return_type {
    my($self, $user, $date) = @_;

    my($start_date) = Bivio::Biz::Accounting::Tax->get_start_of_fiscal_year(
	    $date);

    my($entry_type) = 'Bivio::Type::EntryType';
    my($sth) = Bivio::SQL::Connection->execute("
            SELECT COUNT(*)
            FROM realm_transaction_t, entry_t, member_entry_t
            WHERE realm_transaction_t.realm_transaction_id
                =entry_t.realm_transaction_id
            AND entry_t.entry_id=member_entry_t.entry_id
            AND member_entry_t.user_id=?
            AND entry_t.entry_type in (?, ?)
            AND realm_transaction_t.date_time BETWEEN
                $_SQL_DATE_VALUE AND $_SQL_DATE_VALUE
            AND realm_transaction_t.realm_id=?",
	    [$user->get('realm_id'),
		    $entry_type->MEMBER_WITHDRAWAL_FULL_CASH->as_int,
		    $entry_type->MEMBER_WITHDRAWAL_FULL_STOCK->as_int,
		    $start_date, $date,
		    $self->get_request->get('auth_id')]);

    my($count) = 0;
    while (my $row = $sth->fetchrow_arrayref) {
	$count = $row->[0] || 0;
    }

    return $count > 0 ? Bivio::Type::F1065Return->FINAL_RETURN
	    : Bivio::Type::F1065Return->UNKNOWN;
}

# _get_stock_withdrawal_amount(Bivio::Biz::Model::RealmOwner user, string date, boolean start) : string
#
# Returns the total stock amount withdrawn by the specified user.
#
sub _get_stock_withdrawal_amount {
    my($self, $user, $date) = @_;
    # get tax year start
    my($start_date) = Bivio::Biz::Accounting::Tax->get_start_of_fiscal_year(
	    $date);
    my($entry_type) = 'Bivio::Type::EntryType';
    my($sth) = Bivio::SQL::Connection->execute("
            SELECT -SUM(entry_t.amount)
            FROM entry_t
            WHERE entry_t.class=?
            AND entry_t.entry_type=?
            AND entry_t.realm_id=?
            AND entry_t.realm_transaction_id IN (
                SELECT DISTINCT realm_transaction_t.realm_transaction_id
                FROM realm_transaction_t, entry_t, member_entry_t
                WHERE realm_transaction_t.realm_transaction_id
                    =entry_t.realm_transaction_id
                AND entry_t.entry_id=member_entry_t.entry_id
                AND member_entry_t.user_id=?
                AND entry_t.entry_type in (?,?)
                AND realm_transaction_t.date_time BETWEEN
                    $_SQL_DATE_VALUE AND $_SQL_DATE_VALUE
                AND realm_transaction_t.realm_id=?)",
	    [Bivio::Type::EntryClass->INSTRUMENT->as_int,
		    $entry_type->INSTRUMENT_TRANSFER->as_int,
		    $self->get_request->get('auth_id'),

		    $user->get('realm_id'),
		    $entry_type->MEMBER_WITHDRAWAL_FULL_STOCK->as_int,
		    $entry_type->MEMBER_WITHDRAWAL_PARTIAL_STOCK->as_int,
		    $start_date, $date,
		    $self->get_request->get('auth_id')]);

    my($amount) = 0;
    while (my $row = $sth->fetchrow_arrayref) {
	$amount = $row->[0] || 0;
    }
    return $amount;
}

# _get_user_allocations(Bivio::Biz::Model::RealmOwner user) : Bivio::Collection::Attributes
#
# Returns a allocation attribute set for the specified user.
#
sub _get_user_allocations {
    my($self, $user, $date) = @_;
    my($req) = $self->get_request;

    my($allocations) = $req->get('Bivio::Biz::Model::MemberAllocationList');
    $allocations->reset_cursor;
    while ($allocations->next_row) {
	if ($allocations->get('user_id') eq $user->get('realm_id')) {
	    return $allocations;
	}
    }
    # return an empty set on failure
    return Bivio::Collection::Attributes->new({});
}

# _negative(string amount) : string
#
# Returns the negative value for the specified amount.
#
sub _negative {
    my($amount) = @_;
    unless (Bivio::Type::Amount->compare($amount, 0) == 0) {
	$amount = Bivio::Type::Amount->neg($amount);
    }
    return $amount;
}

# _round_all(hash_ref properties)
#
# Rounds all the Amount values to 2 decimal places.
#
sub _round_all {
    my($self, $properties) = @_;
    foreach my $field (keys(%$properties)) {
	my($type) = $self->get_field_type($field);
	if (UNIVERSAL::isa($type, 'Bivio::Type::Amount')) {
	    $properties->{$field} = Bivio::Type::Amount->round(
		    $properties->{$field}, 2);
	}
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
