# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::F1065Form;
use strict;
$Bivio::Biz::Model::F1065Form::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::F1065Form::VERSION;

=head1 NAME

Bivio::Biz::Model::F1065Form - IRS 1065 fields

=head1 SYNOPSIS

    use Bivio::Biz::Model::F1065Form;
    Bivio::Biz::Model::F1065Form->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::Model::F1065Form::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::F1065Form> IRS 1065 fields

=cut

#=IMPORTS
use Bivio::Biz::Accounting::ClubOwnership;
use Bivio::Biz::Accounting::Tax;
use Bivio::Biz::Model::Tax1065;
use Bivio::SQL::Connection;
use Bivio::Type::CountryCode;
use Bivio::Type::Date;
use Bivio::Type::EntryClass;
use Bivio::Type::F1065AccountingMethod;
use Bivio::Type::F1065Partner;
use Bivio::Type::F1065Partnership;
use Bivio::Type::F1065Return;
use Bivio::Type::F1065ForeignTax;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_SQL_DATE_VALUE) = Bivio::Type::DateTime->to_sql_value('?');
my($_M) = 'Bivio::Type::Amount';

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::Request req) : Bivio::Biz::Model::F1065Form

Creates a new 1065 information model.

=cut

sub new {
    my($self) = Bivio::Biz::ListModel::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_foreign_income"></a>

=head2 static get_foreign_income(Bivio::Agent::Request req, string date) : string

Returns the amount of foreign income for the specified year.

=cut

sub get_foreign_income {
    my(undef, $req, $date) = @_;

    return $req->get('Bivio::Biz::Model::ForeignIncomeList')
	    ->get_summary->get('foreign_income');
}

=for html <a name="get_foreign_income_country"></a>

=head2 get_foreign_income_country(Bivio::Agent::Request req) : string

Returns the name of the foreign country, or "See attached" if > 1.

=cut

sub get_foreign_income_country {
    my(undef, $req) = @_;

    my($list) = $req->get('Bivio::Biz::Model::ForeignIncomeList');
    my($size) = $list->get_result_set_size;

    return '' if $size == 0;
    return "See attached" if $size > 1;

    $list->set_cursor_or_die(0);

    my($code) = Bivio::Type::CountryCode->unsafe_from_any(
	    $list->get('RealmInstrument.country'));

    return $code
	    ? $code->get_short_desc
	    : $list->get('RealmInstrument.country') || '';
}

=for html <a name="get_investment_income"></a>

=head2 static get_investment_income(hash_ref properties) : string

Returns the investment_income amount calculated from existing properties.
Also called by the F1065K1Form.

=cut

sub get_investment_income {
    my(undef, $properties) = @_;
    return _add($properties,
	    qw(interest_income dividend_income other_portfolio_income));
}

=for html <a name="get_margin_interest"></a>

=head2 get_margin_interest(Bivio::Agent::Request req, string date) : (string, string)

Returns the amount of expenses classified as margin interest, as two
values (normal, equal allocation).

=cut

sub get_margin_interest {
    my(undef, $req, $date) = @_;

    my($normal_allocated) = 0;
    my($equally_allocated) = 0;

    # get tax year start
    my($start_date) = Bivio::Biz::Accounting::Tax->get_start_of_fiscal_year(
	    $date);

    # get the margin interest within the year, by equal allocation
    my($sth) = Bivio::SQL::Connection->execute("
            SELECT expense_info_t.allocate_equally, -SUM(entry_t.amount)
            FROM realm_transaction_t, entry_t,
                expense_info_t, expense_category_t
            WHERE realm_transaction_t.realm_transaction_id
                =entry_t.realm_transaction_id
            AND entry_t.entry_id=expense_info_t.entry_id
            AND expense_info_t.expense_category_id
                =expense_category_t.expense_category_id
            AND expense_category_t.name='Margin Interest'
            AND realm_transaction_t.date_time BETWEEN
                $_SQL_DATE_VALUE AND $_SQL_DATE_VALUE
            AND realm_transaction_t.realm_id=?
            GROUP BY expense_info_t.allocate_equally",
	    [$start_date, $date,
		$req->get('auth_id')]);
    while (my $row = $sth->fetchrow_arrayref) {
	my($equal, $amount) = @$row;
	if ($equal) {
	    $equally_allocated = $amount || 0;
	}
	else {
	    $normal_allocated = $amount || 0;
	}
    }
    return ($normal_allocated, $equally_allocated);
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 2,
	other => [
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
		name => 'number_of_8865_forms',
		type => 'Amount',
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
		name => 'margin_interest',
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
		name => 'nondeductible_expenses',
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
		name => 'income_general_corporate',
		type => 'Amount',
		constraint => 'NONE',
	    },
	    {
		name => 'income_general_individual',
		type => 'Amount',
		constraint => 'NONE',
	    },
	    {
		name => 'income_general_partnership',
		type => 'Amount',
		constraint => 'NONE',
	    },
	    {
		name => 'income_general_exempt_org',
		type => 'Amount',
		constraint => 'NONE',
	    },
	    {
		name => 'income_general_other',
		type => 'Amount',
		constraint => 'NONE',
	    },
	    {
		name => 'income_limited_corporate',
		type => 'Amount',
		constraint => 'NONE',
	    },
	    {
		name => 'income_limited_individual',
		type => 'Amount',
		constraint => 'NONE',
	    },
	    {
		name => 'income_limited_partnership',
		type => 'Amount',
		constraint => 'NONE',
	    },
	    {
		name => 'income_limited_exempt_org',
		type => 'Amount',
		constraint => 'NONE',
	    },
	    {
		name => 'income_limited_other',
		type => 'Amount',
		constraint => 'NONE',
	    },
	    {
		name => 'draft',
		type => 'Boolean',
		constraint => 'NONE',
	    },
	],
    };
}

=for html <a name="internal_load_rows"></a>

=head2 internal_load_rows(Bivio::SQL::ListQuery query, string where, array_ref params, Bivio::SQL::ListSupport sql_support) : array_ref

Returns a single row with calculated values.

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
  12      F1065Form.number_of_8865_forms
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
  14a     F1065Form.margin_interest
  14b(1)  F1065Form.investment_income
  14b(2)  F1065Form.investment_expenses
  17a     F1065Form.foreign_income_type
  17b     F1065Form.foreign_income_country
  17c     F1065Form.foreign_income
  17e     F1065Form.foreign_tax_type
  17e     F1065Form.foreign_tax
  19      F1065Form.tax_exempt_interest
  21      F1065Form.nondeductible_expenses
  22      F1065Form.cash_distribution
  23      F1065Form.property_distribution

  1065 page 4 Analysis of Net Income

  1       F1065Form.net_income
  2a(i)   F1065Form.income_general_corporate
  2a(ii)  F1065Form.income_general_individual
  2a(iv)  F1065Form.income_general_partnership
  2a(v)   F1065Form.income_general_exempt_org
  2a(vi)  F1065Form.income_general_other
  2b(i)   F1065Form.income_limited_corporate
  2b(ii)  F1065Form.income_limited_individual
  2b(iv)  F1065Form.income_limited_partnership
  2b(v)   F1065Form.income_limited_exempt_org
  2b(vi)  F1065Form.income_limited_other

=cut

sub internal_load_rows {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($req) = $self->get_request;

    my($date) = $req->get('report_date');
    my($tax) = 'Bivio::Type::TaxCategory';

    my($income) = $req->get('Bivio::Biz::Model::IncomeAndExpenseList')
	    ->set_cursor_or_die(0);
    my($schedule_d) = $req->get('Bivio::Biz::Model::ScheduleDList')
	    ->set_cursor_or_die(0);

    my($properties) = {
	%{Bivio::Biz::Model::Tax1065->new($req)
		    ->load_or_default($date)->get_shallow_copy()},
	business_activity => 'Finance',
	principal_service => 'Investment Club',
	business_code => '525990',
	return_type => _get_return_type($self, $date),
	accounting_method => Bivio::Type::F1065AccountingMethod->CASH,
	number_of_k1s => _get_member_count($self),
	three_requirements => _meets_three_requirements($self, $date),
	foreign_partners => _has_foreign_partners($self, $date),
	foreign_account => 0,
	transfer_of_interest => _has_transfer_of_interest($self, $date),
	number_of_8865_forms => 0,
	interest_income => $income->get($tax->INTEREST->get_short_desc),
	dividend_income => $income->get($tax->DIVIDEND->get_short_desc),
	net_stcg => $schedule_d->get('net_stcg'),
	net_ltcg => $schedule_d->get('net_ltcg'),
	other_portfolio_income => $income->get(
		$tax->MISC_INCOME->get_short_desc),
	foreign_income => $self->get_foreign_income($self->get_request, $date),
	foreign_tax => $_M->neg($income->get(
		$tax->FOREIGN_TAX->get_short_desc)),
	foreign_income_country => $self->get_foreign_income_country(
		$self->get_request),
	tax_exempt_interest => $income->get(
		$tax->FEDERAL_TAX_FREE_INTEREST->get_short_desc),
	nondeductible_expenses => $_M->neg($income->get(
		$tax->NON_DEDUCTIBLE_EXPENSE->get_short_desc)),
	cash_distribution => _get_cash_withdrawal_amount($self, $date),
	property_distribution => _get_stock_withdraw_amount($self, $date),
    };

    _get_expenses($self, $properties, $income, $date);

    $properties = {
	%$properties,
	investment_income => $self->get_investment_income($properties),
	investment_expenses => $properties->{portfolio_deductions},
	foreign_income_type => ($properties->{foreign_tax} == 0
	        ? '' : 'Passive'),
	foreign_tax_type => ($properties->{foreign_tax} == 0
	        ? Bivio::Type::F1065ForeignTax->UNKNOWN
	        : Bivio::Type::F1065ForeignTax->PAID),
    };

    Bivio::Biz::Accounting::Tax->round_all($self, $properties);
    _calculate_income($self, $properties, $date);

    return [$properties];
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
	$sum = $_M->add($sum, $properties->{$field});
    }
    return $sum;
}

# _calculate_income(hash_ref properties, string date)
#
# Calculates net_income, and the income by partner type fields
#
sub _calculate_income {
    my($self, $properties, $date) = @_;

    # net_income
    $properties->{net_income} = _add($properties,
	    qw(interest_income dividend_income net_stcg	net_ltcg
               other_portfolio_income));

    # subtract deductions
    $properties->{net_income} = $_M->sub(
	    $properties->{net_income}, _add($properties,
		    qw(portfolio_deductions margin_interest foreign_tax)));

    my($list) = $self->get_request->get('Bivio::Biz::Model::MemberTaxList');
    $list->reset_cursor;

    while ($list->next_row) {
	my($k1) = Bivio::Biz::Model::TaxK1->new($self->get_request)
		->load_or_default($list->get('RealmUser.user_id'), $date);

	# categorize by member partner type and entity type
	my($field) = 'income_';
	if ($k1->get('partner_type') == Bivio::Type::F1065Partner::GENERAL()) {
	    $field .= 'general_';
	}
	else {
	    $field .= 'limited_';
	}

	my($type) = $k1->get('entity_type');
	if ($type == $type->CORPORATION) {
	    $field .= 'corporate';
	}
	elsif ($type == $type->INDIVIDUAL) {
	    $field .= 'individual';
	}
	elsif ($type == $type->PARTNERSHIP) {
	    $field .= 'partnership';
	}
	elsif ($type == $type->EXEMPT_ORGANIZATION) {
	    $field .= 'exempt_org';
	}
	else {
	    $field .= 'other';
	}
	$properties->{$field} = $_M->add($properties->{$field} || 0,
		$list->get('taxable_net_income'));
    }

    # ensure the amounts match the partnership net income
    my($total) = 0;
    foreach my $field (qw(income_general_corporate income_general_individual
            income_general_partnership income_general_exempt_org
            income_general_other income_limited_corporate
            income_limited_individual income_limited_partnership
            income_limited_exempt_org income_limited_other)) {

	if ($properties->{$field}) {
	    $total = $_M->add($total, $properties->{$field});
	}
	else {
	    $properties->{$field} = 0;
	}
    }

    my($diff) = $_M->sub($properties->{net_income}, $total);

    # the Schedule D can be off by a few pennies, unfortunately
    if ($diff != 0) {
	Bivio::IO::Alert->info('adjusting allocations ', $diff);

	# use income_general_individual to take up the slack
	$properties->{income_general_individual} = $_M->add(
		$properties->{income_general_individual}, $diff);
    }
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

# _get_expenses(hash_ref properties, Bivio::Biz::Model::IncomeAndExpenseList income, string date)
#
# Calculates the portfolio_deductions and margin_interest fields.
#
sub _get_expenses {
    my($self, $properties, $income, $date) = @_;

    my($deductions) = $_M->neg(
	    $income->get(Bivio::Type::TaxCategory->MISC_EXPENSE
		    ->get_short_desc));

    my($margin, $equal_margin) = $self->get_margin_interest(
	    $self->get_request, $date);

    $properties->{margin_interest} = $_M->add($margin, $equal_margin);
    $properties->{portfolio_deductions} = $_M->sub(
	    $deductions, $properties->{margin_interest});
    return;
}

# _get_member_count() : int
#
# Returns the number of members who were active in the club for the
# current year.
#
sub _get_member_count {
    my($self) = @_;
    return $self->get_request->get('Bivio::Biz::Model::MemberAllocationList')
	    ->get_result_set_size;
}

# _get_return_type(string date) : Bivio::Type::F1065Return
#
# Returns the type of return. If there is no club ownership on the end
# date, then the return is final.
#
sub _get_return_type {
    my($self, $date) = @_;

    my($ownership) = Bivio::Biz::Accounting::ClubOwnership->new(
	    $self->get_request, $date)->get_ownership($date);

    foreach my $row (values(%$ownership)) {
	return Bivio::Type::F1065Return::UNKNOWN() if ($row->[0] != 0);
    }
    return Bivio::Type::F1065Return::FINAL_RETURN();
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

# _has_foreign_partners(string date) : boolean
#
# Returns 1 if one of the partners isn't domestic.
#
sub _has_foreign_partners {
    my($self, $date) = @_;

    my($sth) = Bivio::SQL::Connection->execute("
            SELECT SUM(tax_k1_t.foreign_partner)
            FROM tax_k1_t
            WHERE tax_k1_t.fiscal_end_date = $_SQL_DATE_VALUE
            AND tax_k1_t.realm_id=?",
	    [$date, $self->get_request->get('auth_id')]);
    my($result) = 0;
    while (my $row = $sth->fetchrow_arrayref) {
	$result = $row->[0] || 0;
    }
    return $result > 0 ? 1 : 0;
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

# _meets_three_requirements(string date) : boolea
#
# Returns 1 if the club meets the three requirements needed to avoid
# filling out the Scheduls L, M-1 and M-2.
#
sub _meets_three_requirements {
    my($self, $date) = @_;
    return Bivio::Biz::Accounting::Tax->meets_three_requirements(
	    $self->get_request, $date);
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
