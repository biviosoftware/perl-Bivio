# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::F1065Form;
use strict;
$Bivio::Biz::Model::F1065Form::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::F1065Form - IRS 1065 fields

=head1 SYNOPSIS

    use Bivio::Biz::Model::F1065Form;
    Bivio::Biz::Model::F1065Form->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::F1065Form::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::F1065Form> IRS 1065 fields

=cut

#=IMPORTS
use Bivio::Biz::Accounting::Tax;
use Bivio::SQL::Connection;
use Bivio::Type::Date;
use Bivio::Type::EntryClass;
use Bivio::Type::F1065AccountingMethod;
use Bivio::Type::F1065Partnership;
use Bivio::Type::F1065Return;
use Bivio::Type::F1065ForeignTax;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_SQL_DATE_VALUE) = Bivio::Type::DateTime->to_sql_value('?');

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Loads the form values.

  1065 page 1

  name    Club.RealmOwner.display_name
  address Club.Address.street1
          Club.Address.street2
          Club.Address.city
          Club.Address.state
          Club.Address.zip
  A       F1065Form.business_activity
  B       F1065Form.principal_service
  C       F1065Form.business_code
  D       Club.TaxId.tax_id
  E       F1065Form.business_start_date
  G       F1065Form.return_type
  H       F1065Form.accounting_method
  I       F1065Form.number_of_k1s

  1065 page 2 Schedule B

   1a     F1065Form.partnership_type
   2      F1065Form.partner_is_partnership
   3      F1065Form.partnership_is_partner
   4      F1065Form.consolidated_audit
   5      F1065Form.three_requirements
   6      F1065Form.foreign_partners
   7      F1065Form.publicly_traded
   8      F1065Form.tax_shelter
   9      F1065Form.foreign_account
   9      F1065Form.foreign_account_country
  10      F1065Form.foreign_trust
  11      F1065Form.transfer_of_interest
  bottom
  id      User.TaxId.tax_id
  name    User.RealmOwner.display_name
  address User.Address.street1
          User.Address.street2
          User.Address.city
          User.Address.state
          User.Address.zip

  1065 page 3 Schedule K

   4a     F1065Form.interest_income
   4b     F1065Form.dividend_income
   4d     F1065Form.net_stcg
   4e     F1065Form.net_ltcg
   4f     F1065Form.other_portfolio_income
  10      F1065Form.portfolio_deductions
  14b(1)  F1065Form.investment_income
  14b(2)  F1065Form.investment_expenses
  17a     F1065Form.foreign_income_type
  17b     F1065Form.foreign_income_country
  17c     F1065Form.foreign_income
  17e     F1065Form.foreign_tax_type
  17e     F1065Form.foreign_tax
  19      F1065Form.tax_exempt_interest
  22      F1065Form.cash_distribution
  23      F1065Form.property_distribution

  1065 page 4 Analysis of Net Income

  1       F1065Form.net_income
  2a(ii)  F1065Form.active_income
  2a(iii) F1065Form.passive_income

=cut

sub execute_empty {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE} = {};
    my($req) = $self->get_request;
    my($properties) = $self->internal_get;

    my($date) = $req->get('report_date');
    $date = Bivio::Type::Date->to_local_date($date);
    my($tax) = 'Bivio::Type::TaxCategory';

    my($income) = $req->get('Bivio::Biz::Model::IncomeAndExpenseList');
    $income->reset_cursor;
    $income->next_row || die("couldn't load income/expense list");
    $income->adjust_for_allocations;

    my($schedule_d) = $req->get('Bivio::Biz::Model::ScheduleDForm');

    $properties->{business_activity} = 'Finance';
    $properties->{principal_service} = 'Investment Club';
    $properties->{business_code} = '525990';
    $properties->{business_start_date} = undef;
    $properties->{return_type} = Bivio::Type::F1065Return->UNKNOWN;
    $properties->{accounting_method} =
	    Bivio::Type::F1065AccountingMethod->CASH;
    $properties->{number_of_k1s} = _get_member_count($self, $date);
    $properties->{partnership_type} =
	    Bivio::Type::F1065Partnership->GENERAL;
    $properties->{partner_is_partnership} = 0;
    $properties->{partnership_is_partner} = 0;
    $properties->{consolidated_audit} = 1;
    $properties->{three_requirements} = 1;
    $properties->{foreign_partners} = 0;
    $properties->{publicly_traded} = 0;
    $properties->{tax_shelter} = 0;
    $properties->{foreign_account} = 0;
    $properties->{foreign_account_country} = '';
    $properties->{foreign_trust} = 0;
    $properties->{transfer_of_interest} = _has_transfer_of_interest($self,
	    $date);

    $properties->{interest_income} = $income->get(
	    $tax->INTEREST->get_short_desc);
    $properties->{dividend_income} = $income->get(
	    $tax->DIVIDEND->get_short_desc);
    $properties->{net_stcg} = $schedule_d->get('net_stcg');
    $properties->{net_ltcg} = $schedule_d->get('net_ltcg');
    $properties->{other_portfolio_income} = $income->get(
	    $tax->MISC_INCOME->get_short_desc);
    $properties->{portfolio_deductions} = Bivio::Type::Amount->neg(
	    $income->get($tax->MISC_EXPENSE->get_short_desc));
    $properties->{investment_income} = $self->get_investment_income(
	    $properties);
    $properties->{investment_expenses} = $properties->{portfolio_deductions};
    $properties->{foreign_income} = $self->get_foreign_income(
	    $self->get_request, $date);
    $properties->{foreign_tax} = Bivio::Type::Amount->neg($income->get(
	    $tax->FOREIGN_TAX->get_short_desc));
    $properties->{foreign_income_country} = '';
    $properties->{foreign_income_type} = $properties->{foreign_tax} == 0
	    ? '' : 'Passive';
    $properties->{foreign_tax_type} = $properties->{foreign_tax} == 0
	    ? Bivio::Type::F1065ForeignTax->UNKNOWN
	    : Bivio::Type::F1065ForeignTax->PAID;
    $properties->{tax_exempt_interest} = $income->get(
	    $tax->FEDERAL_TAX_FREE_INTEREST->get_short_desc);
    $properties->{cash_distribution} =
	    _get_cash_withdrawal_amount($self, $date);
    $properties->{property_distribution} =
	    _get_stock_withdraw_amount($self, $date);

    _calculate_income($self, $properties);
    return;
}

=for html <a name="get_foreign_income"></a>

=head2 static get_foreign_income(Bivio::Agent::Request req, string date) : string

Returns the amount of foreign income for the specified year.

=cut

sub get_foreign_income {
    my(undef, $req, $date) = @_;

    # get tax year start
    my($start_date) = Bivio::Biz::Accounting::Tax->get_start_of_fiscal_year(
	    $date);

    my($total_amount) = 0;
    # get the foreign tax entires within the year
    my($date_param) = Bivio::Type::DateTime->from_sql_value(
	    'realm_transaction_t.date_time');
    my($sth) = Bivio::SQL::Connection->execute("
            SELECT $date_param,
                entry_t.amount,
                realm_instrument_entry_t.realm_instrument_id
            FROM realm_transaction_t, entry_t, realm_instrument_entry_t,
                realm_instrument_t
            WHERE realm_transaction_t.realm_transaction_id
                =entry_t.realm_transaction_id
            AND entry_t.entry_id=realm_instrument_entry_t.entry_id
            AND realm_instrument_entry_t.realm_instrument_id
                =realm_instrument_t.realm_instrument_id
            AND entry_t.tax_category=?
            AND realm_transaction_t.date_time BETWEEN
                $_SQL_DATE_VALUE AND $_SQL_DATE_VALUE
            AND realm_transaction_t.realm_id=?",
	    [Bivio::Type::TaxCategory::FOREIGN_TAX->as_int,
		    $start_date, $date,
		    $req->get('auth_id')]);
    while (my $row = $sth->fetchrow_arrayref) {
	my($date, $amount, $inst_id) = @$row;

	$amount = Bivio::Type::Amount->neg($amount);
	$total_amount = Bivio::Type::Amount->add($total_amount, $amount);

	my($div_amount) = 0;
	# get the corresponding dividend
	my($sth2) = Bivio::SQL::Connection->execute("
                SELECT entry_t.amount
                FROM realm_transaction_t, entry_t, realm_instrument_entry_t
                WHERE realm_transaction_t.realm_transaction_id
                    =entry_t.realm_transaction_id
                AND entry_t.entry_id=realm_instrument_entry_t.entry_id
                AND realm_instrument_entry_t.realm_instrument_id=?
                AND entry_t.tax_category=?
                AND realm_transaction_t.date_time = $_SQL_DATE_VALUE
                AND realm_transaction_t.realm_id=?",
		[$inst_id, Bivio::Type::TaxCategory::DIVIDEND->as_int,
			$date, $req->get('auth_id')]);
	while (my $row2 = $sth2->fetchrow_arrayref) {
	    $div_amount = $row2->[0];
	}
	$total_amount = Bivio::Type::Amount->add($total_amount, $div_amount);
    }
    return $total_amount;
}

=for html <a name="get_investment_income"></a>

=head2 static get_investment_income(hash_ref properties) : string

Returns the investment_income amount calculated from existing properties.

=cut

sub get_investment_income {
    my(undef, $properties) = @_;
    return _add($properties,
	    qw(interest_income dividend_income other_portfolio_income));
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
		name => 'business_activity',
		type => 'Name',
		constraint => 'NONE',
	    },
	    {
		name => 'principal_service',
		type => 'Name',
		constraint => 'NONE',
	    },
	    {
		name => 'business_code',
		type => 'Name',
		constraint => 'NONE',
	    },
	    {
		name => 'business_start_date',
		type => 'Date',
		constraint => 'NONE',
	    },
	    {
		name => 'return_type',
		type => 'F1065Return',
		constraint => 'NONE',
	    },
	    {
		name => 'accounting_method',
		type => 'F1065AccountingMethod',
		constraint => 'NONE',
	    },
	    {
		name => 'number_of_k1s',
		type => 'Amount',
		constraint => 'NONE',
	    },
	    {
		name => 'partnership_type',
		type => 'F1065Partnership',
		constraint => 'NONE',
	    },
	    {
		name => 'partner_is_partnership',
		type => 'Boolean',
		constraint => 'NONE',
	    },
	    {
		name => 'partnership_is_partner',
		type => 'Boolean',
		constraint => 'NONE',
	    },
	    {
		name => 'consolidated_audit',
		type => 'Boolean',
		constraint => 'NONE',
	    },
	    {
		name => 'three_requirements',
		type => 'Boolean',
		constraint => 'NONE',
	    },
	    {
		name => 'foreign_partners',
		type => 'Boolean',
		constraint => 'NONE',
	    },
	    {
		name => 'publicly_traded',
		type => 'Boolean',
		constraint => 'NONE',
	    },
	    {
		name => 'tax_shelter',
		type => 'Boolean',
		constraint => 'NONE',
	    },
	    {
		name => 'foreign_account',
		type => 'Boolean',
		constraint => 'NONE',
	    },
	    {
		name => 'foreign_account_country',
		type => 'Line',
		constraint => 'NONE',
	    },
	    {
		name => 'foreign_trust',
		type => 'Boolean',
		constraint => 'NONE',
	    },
	    {
		name => 'transfer_of_interest',
		type => 'Boolean',
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
	    {
		name => 'net_income',
		type => 'Amount',
		constraint => 'NONE',
	    },
	    {
		name => 'active_income',
		type => 'Amount',
		constraint => 'NONE',
	    },
	    {
		name => 'passive_income',
		type => 'Amount',
		constraint => 'NONE',
	    },
	],
    };
}

#=PRIVATE METHODS

# _add(hash_ref properties, array fields) : string
#
# Adds the specified fields from properties.
#
sub _add {
    my($properties, @fields) = @_;
    my($sum) = 0;
    foreach my $field (@fields) {
	$sum = Bivio::Type::Amount->add($sum, $properties->{$field});
    }
    return $sum;
}

# _calculate_income(hash_ref properties)
#
# Calculates net_income, active_income, and passive_income based
# on the current values.
#
sub _calculate_income {
    my($self, $properties) = @_;

    # net_income
    $properties->{net_income} = _add($properties,
	    qw(interest_income dividend_income net_stcg	net_ltcg
               other_portfolio_income));
    $properties->{net_income} = Bivio::Type::Amount->sub(
	    $properties->{net_income}, $properties->{portfolio_deductions});
    $properties->{net_income} = Bivio::Type::Amount->sub(
	    $properties->{net_income}, $properties->{foreign_tax});

    # passive_income
    $properties->{passive_income} = $properties->{foreign_income};

    # active_income
    $properties->{active_income} = Bivio::Type::Amount->sub(
	    $properties->{net_income}, $properties->{passive_income});
    return;
}

# _get_cash_withdrawal_amount(string date) : string
#
# Returns the total cash_withdrawal amount for the specified year.
#
sub _get_cash_withdrawal_amount {
    my($self, $date) = @_;
    my($fields) = $self->{$_PACKAGE};

    unless (exists($fields->{cash_withdrawal})) {
	my($entry_type) = 'Bivio::Type::EntryType';
	$fields->{cash_withdrawal} = _get_withdrawal_amount($self, $date,
		Bivio::Type::EntryClass->CASH,
		[
		    $entry_type->MEMBER_WITHDRAWAL_FULL_CASH->as_int,
		    $entry_type->MEMBER_WITHDRAWAL_PARTIAL_CASH->as_int,
		    $entry_type->MEMBER_WITHDRAWAL_FULL_STOCK->as_int,
		    $entry_type->MEMBER_WITHDRAWAL_PARTIAL_STOCK->as_int,
		]);
    };
    return $fields->{cash_withdrawal};
}

# _get_member_count(string date) : int
#
# Returns the number of members who were active in the club for the
# specified year.
#
sub _get_member_count {
    my($self, $date) = @_;

    # get tax year start
    my($start_date) = Bivio::Biz::Accounting::Tax->get_start_of_fiscal_year(
	    $date);

    my($sth) = Bivio::SQL::Connection->execute("
            SELECT COUNT(DISTINCT member_entry_t.user_id)
            FROM realm_transaction_t, entry_t, member_entry_t
            WHERE entry_t.realm_transaction_id
                =realm_transaction_t.realm_transaction_id
            AND member_entry_t.entry_id=entry_t.entry_id
            AND realm_transaction_t.date_time BETWEEN
                $_SQL_DATE_VALUE AND $_SQL_DATE_VALUE
            AND realm_transaction_t.realm_id=?",
	    [$start_date, $date, $self->get_request->get('auth_id')]);
    my($count) = 0;
    while (my $row = $sth->fetchrow_arrayref) {
	$count = $row->[0] || 0;
    }
    return $count;
}

# _get_stock_withdraw_amount(string date) : string
#
# Returns the total stock withdrawal amount for the specified year.
#
sub _get_stock_withdraw_amount {
    my($self, $date) = @_;
    my($fields) = $self->{$_PACKAGE};

    unless (exists($fields->{stock_withdrawal})) {
	my($entry_type) = 'Bivio::Type::EntryType';
	$fields->{stock_withdrawal} = _get_withdrawal_amount($self, $date,
		Bivio::Type::EntryClass->INSTRUMENT,
		[$entry_type->INSTRUMENT_TRANSFER->as_int]);
    }
    return $fields->{stock_withdrawal};
}

# _get_withdrawal_amount(string date, Bivio::Type::EntryClass class, array_ref type) : string
#
# Returns the total withdrawal amount for the specified type and date.
#
sub _get_withdrawal_amount {
    my($self, $date, $class, $type) = @_;

    my($param);
    if (int(@$type) == 1) {
	$param = '=?';
    }
    else {
	$param = ' in (';
	for (1 .. int(@$type)) {
	    $param .= '?,';
	}
	chop($param);
	$param .= ')';
    }

    # get tax year start
    my($start_date) = Bivio::Biz::Accounting::Tax->get_start_of_fiscal_year(
	    $date);
    my($sth) = Bivio::SQL::Connection->execute("
            SELECT -SUM(entry_t.amount)
            FROM realm_transaction_t, entry_t
            WHERE realm_transaction_t.realm_transaction_id
                =entry_t.realm_transaction_id
            AND entry_t.class=?
            AND entry_t.entry_type $param
            AND realm_transaction_t.date_time BETWEEN
                $_SQL_DATE_VALUE AND $_SQL_DATE_VALUE
            AND realm_transaction_t.realm_id=?",
	    [$class->as_int, @$type, $start_date, $date,
		    $self->get_request->get('auth_id')]);

    my($amount) = 0;
    while (my $row = $sth->fetchrow_arrayref) {
	$amount = $row->[0] || 0;
    }
    return $amount;
}

# _has_transfer_of_interest(string date) : boolean
#
# Returns 1 if a partner withdrew in stock within the specified tax year.
#
sub _has_transfer_of_interest {
    my($self, $date) = @_;

    if (_get_stock_withdraw_amount($self, $date)) {
	return 1;
    }
    return 0;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
