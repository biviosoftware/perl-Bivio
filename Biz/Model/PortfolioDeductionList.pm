# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::PortfolioDeductionList;
use strict;
$Bivio::Biz::Model::PortfolioDeductionList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::PortfolioDeductionList::VERSION;

=head1 NAME

Bivio::Biz::Model::PortfolioDeductionList - lists portfolio expense entries

=head1 SYNOPSIS

    use Bivio::Biz::Model::PortfolioDeductionList;
    Bivio::Biz::Model::PortfolioDeductionList->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::Model::PortfolioDeductionList::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::PortfolioDeductionList> lists portfolio expense entries

=cut

#=IMPORTS
use Bivio::Biz::Accounting::Tax;
use Bivio::Type::Amount;
use Bivio::Type::DateInterval;
use Bivio::Type::DateTime;
use Bivio::Type::EntryType;
use Bivio::Type::TaxCategory;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_SQL_DATE_VALUE) = Bivio::Type::DateTime->to_sql_value('?');
my($_INSTRUMENT_FEE_LIST) = Bivio::Biz::ListModel->new_anonymous({
    version => 1,
    auth_id => [qw(RealmTransaction.realm_id)],
    primary_key => [
	[qw(Entry.entry_id)],
    ],
    date => ['RealmTransaction.date_time'],
    want_date => 1,
    can_iterate => 1,
    other => [qw(
        Entry.amount
        Entry.entry_type
        Entry.class
        Entry.tax_basis
        Entry.tax_category
        RealmInstrument.name
        Instrument.name
        ),
	[qw(RealmTransaction.realm_transaction_id
            Entry.realm_transaction_id)],
	[qw(Entry.entry_id RealmInstrumentEntry.entry_id)],
	[qw(RealmInstrumentEntry.realm_instrument_id
            RealmInstrument.realm_instrument_id)],
	[qw{RealmInstrument.instrument_id Instrument.instrument_id(+)}],
    ],
    where => [
	'Entry.tax_category', '=',
	Bivio::Type::TaxCategory::MISC_EXPENSE()->as_sql_param,
    ],
});

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	auth_id => [qw(RealmTransaction.realm_id)],
	primary_key => [
	    [qw(Entry.entry_id)],
	],
	other => [qw(
	    RealmTransaction.date_time
            RealmTransaction.remark
            Entry.amount
            Entry.entry_type
            Entry.class
	    Entry.tax_basis
            ExpenseCategory.name
            ExpenseCategory.deductible
	    ),
	    [qw(Entry.realm_transaction_id
                RealmTransaction.realm_transaction_id)],
	    [qw(Entry.entry_id ExpenseInfo.entry_id)],
	    [qw(ExpenseInfo.expense_category_id
                    ExpenseCategory.expense_category_id)],
	],
	where => [
	    'Entry.entry_type', '=',
	    Bivio::Type::EntryType::CASH_EXPENSE()->as_sql_param,
            'AND',
            'Entry.class', '=',
	    Bivio::Type::EntryClass::CASH()->as_sql_param,
	    'AND',
	    'Entry.tax_basis', '=', '1',
	    'AND',
	    'ExpenseCategory.deductible', '=', '1',
	    'AND',
	    'RealmTransaction.date_time', 'BETWEEN',
	    $_SQL_DATE_VALUE, 'AND', $_SQL_DATE_VALUE,
	],
    };
}

=for html <a name="internal_load_rows"></a>

=head2 internal_load_rows(Bivio::SQL::ListQuery query, string where, array_ref params, Bivio::SQL::ListSupport sql_support) : array_ref

Returns rows.

=cut

sub internal_load_rows {
    my($self, $query, $where, $params, $sql_support) = @_;
    my($rows) = $self->SUPER::internal_load_rows($query, $where, $params,
	    $sql_support);

    # add in any fees from instrument transactions
    my($iter) = $_INSTRUMENT_FEE_LIST->iterate_start({
	date => $self->get_request->get('report_date'),
	interval => Bivio::Type::DateInterval::BEGINNING_OF_YEAR(),
    });

    my($row) = {};
    while ($_INSTRUMENT_FEE_LIST->iterate_next($iter, $row)) {
	$row->{'RealmTransaction.remark'} = 'Investment fee: '
		.($row->{'RealmInstrument.name'} || $row->{'Instrument.name'});
	# copy the row values into a new hash
	push(@$rows, {%$row});
    }
    $_INSTRUMENT_FEE_LIST->iterate_end($iter);

    # change the sign on all the amounts
    foreach my $row (@$rows) {
	$row->{'Entry.amount'} = Bivio::Type::Amount->neg(
		$row->{'Entry.amount'});

	# use the expense category name in the remark
	# if it isn't the generic "Deductible Expense"
	if ($row->{'ExpenseCategory.name'}) {
	    my($remark) = $row->{'RealmTransaction.remark'};
	    next if $row->{'ExpenseCategory.name'} eq 'Deductible Expense';
	    $row->{'RealmTransaction.remark'} = defined($remark)
		    ? $row->{'ExpenseCategory.name'}."\n".$remark
		    : $row->{'ExpenseCategory.name'};
	}

	$row->{'RealmTransaction.remark'} ||= '';
    }

    # sort the account and investment entries by date and remark
    my(@sorted) = sort({
	# date
	my($r) = Bivio::Type::DateTime->compare(
		$a->{'RealmTransaction.date_time'},
		$b->{'RealmTransaction.date_time'});
	return $r unless $r == 0;

	# description
	$r = $a->{'RealmTransaction.remark'}
	cmp $b->{'RealmTransaction.remark'};
	return $r;
    } @$rows);

    return \@sorted;
}

=for html <a name="internal_pre_load"></a>

=head2 internal_pre_load(Bivio::SQL::ListQuery query, Bivio::SQL::ListSupport support, array_ref params) : string

Adds dynamic start/end dates to the SQL parameters.

=cut

sub internal_pre_load {
    my($self, $query, $support, $params) = @_;
    my($end_date) = $self->get_request->get('report_date');

    # get tax year start
    my($start_date) = Bivio::Biz::Accounting::Tax->get_start_of_fiscal_year(
	    $end_date);

    push(@$params, $start_date, $end_date);
    return '';
}


#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
