# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::MonthlyPerformanceList;
use strict;
$Bivio::Biz::Model::MonthlyPerformanceList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::MonthlyPerformanceList - monthly member cash flow summary

=head1 SYNOPSIS

    use Bivio::Biz::Model::MonthlyPerformanceList;
    Bivio::Biz::Model::MonthlyPerformanceList->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::Model::MonthlyPerformanceList::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::MonthlyPerformanceList> monthly member cash flow summary

=cut

#=IMPORTS
use Bivio::Biz::Accounting::IRR;
use Bivio::Biz::Model::MemberCashFlowList;
use Bivio::Type::Amount;
use Bivio::Type::Date;
use Bivio::Type::DateTime;
use Bivio::Type::IRR;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($math) = 'Bivio::Type::Amount';

=head1 METHODS

=cut

=for html <a name="get_irr"></a>

=head2 get_irr() : string

Returns the IRR for the member's cash flow.

=cut

sub get_irr {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{irr};
}

=for html <a name="internal_get_count"></a>

=head2 abstract internal_get_count(hash_ref row) : string

Returns the number of units/shares purchased for the specified data
row.

=cut

sub internal_get_count {
    die("abstract method");
}

=for html <a name="internal_get_end_value"></a>

=head2 abstract internal_get_end_value(string date) : (string, string)

Returns the (value, count) for the specified ending date.

=cut

sub internal_get_end_value {
    die("abstract method");
}

=for html <a name="internal_get_start_value"></a>

=head2 abstract internal_get_start_value(string start_date, string end_date) : (string, string)

Returns the (value, count) for the specified starting date.

=cut

sub internal_get_start_value {
    die("abstract method");
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize()

All local fields.

=cut

sub internal_initialize {

    return {
	version => 1,
	primary_key => [
	    ['Entry.entry_id'],
	],
	auth_id => [qw(RealmTransaction.realm_id)],
	other => [
	    'Entry.amount',
	    {
		name => 'quantity',
		type => 'Amount',
		constraint => 'NOT_NULL',
	    },
	    {
	        name => 'description',
   	        type => 'Line',
	        constraint => 'NONE',
	    },
	    {
		name => 'month',
		type => 'Line',
		constraint => 'NOT_NULL',
	    },
       ],
    };
}

=for html <a name="internal_load_rows"></a>

=head2 internal_load_rows(Bivio::SQL::ListQuery query, string where, array_ref params, Bivio::SQL::ListSupport sql_support) : array_ref

Returns rows.

=cut

sub internal_load_rows {
    my($self, @args) = @_;
    my($fields) = $self->{$_PACKAGE} = {
	irr => Bivio::Type::IRR::NOT_APPLICABLE(),
    };
    my($req) = $self->get_request;

    return [] unless $req->has_keys(qw(start_date report_date));

    my($start_date) = $req->get('start_date');
    my($end_date) = $req->get('report_date');

    my($irr_dates) = $fields->{irr_dates} = [];
    my($irr_amounts) = $fields->{irr_amounts} = [];

    my($rows) = [];
    return $rows if Bivio::Type::Date->compare($start_date, $end_date) > 0;

    # the realm's initial value
    my($current_month) = _get_month($start_date);
    my($value, $count) = $self->internal_get_start_value(
	    $start_date, $end_date);
    push(@$rows, {
	month => $current_month,
	description => 'beginning market value',
	'Entry.amount' => $value,
	quantity => $count,
    });
    push(@$irr_dates, $start_date);
    push(@$irr_amounts, $math->neg($value));

    # group deposits and withdrawals by month
    my($deposits) = [0, 0, 0];
    my($withdrawals) = [0, 0, 0];

    my($cash_flow) = Bivio::Biz::Model::MemberCashFlowList->new($req);
    my($it) = $cash_flow->iterate_start();
    my($row) = {};
    while ($cash_flow->iterate_next($it, $row)) {
	my($date) = $row->{'RealmTransaction.date_time'};
	my($amount) = $row->{'Entry.amount'};

	push(@$irr_dates, $date);
	push(@$irr_amounts, $amount);

	my($month) = _get_month($date);
	if ($current_month ne $month) {
	    _add_rows($rows, $current_month, $deposits, $withdrawals);
	    $current_month = $month;
	}

	$amount = $math->neg($amount);
	my($array) = ($math->compare($amount, 0) > 0)
		? $deposits : $withdrawals;
	$array->[0]++;
	$array->[1] = $math->add($array->[1], $amount);
	$array->[2] = $math->add($array->[2],
	       $self->internal_get_count($row));
    }
    $cash_flow->iterate_end($it);

    # get the last row, if any
    _add_rows($rows, $current_month, $deposits, $withdrawals);

    # the realm's ending value
    ($value, $count) = $self->internal_get_end_value($end_date);
    push(@$rows, {
	month => _get_month($end_date),
	description => 'ending market value',
	'Entry.amount' => $value,
	quantity => $count,
    });
    push(@$irr_dates, $end_date);
    push(@$irr_amounts, $value);

    # have to make a copy of the vectors because they are
    # needed in the original form for the comparison performance list
    $fields->{irr} = Bivio::Biz::Accounting::IRR->calculate_irr(
	    [@$irr_dates], [@$irr_amounts]);
    return $rows;
}

#=PRIVATE METHODS

# _add_rows(array_ref rows, string month, array_ref deposits, array_ref withdrawals)
#
# Adds 0-2 rows to the specified rows array. Resets deposit or withdrawal
# info.
#
sub _add_rows {
    my($rows, $month, $deposits, $withdrawals) = @_;

    foreach my $array ($deposits, $withdrawals) {
	my($i, $amount, $count) = @$array;
	next unless $i;

	my($description) = $i.($array == $deposits
		    ? ' deposit' : ' withdrawal');
	$description .= 's' if $i > 1;

	push(@$rows, {
	    month => $month,
	    description => $description,
	    'Entry.amount' => $amount,
	    quantity => $count,
	});

	# clear the count, amount, unit values
	@{$array}[0..2] = (0, 0, 0);
    }
    return;
}

# _get_month(string date) : string
#
# Returns the month's for the specified date as mm/yyyy.
#
sub _get_month {
    my($date) = @_;
    my($month, $year) = (Bivio::Type::DateTime->to_parts($date))[4..5];
    return $month.'/'.$year;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
