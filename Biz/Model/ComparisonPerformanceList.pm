# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::ComparisonPerformanceList;
use strict;
$Bivio::Biz::Model::ComparisonPerformanceList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::ComparisonPerformanceList - compare realm cash flow

=head1 SYNOPSIS

    use Bivio::Biz::Model::ComparisonPerformanceList;
    Bivio::Biz::Model::ComparisonPerformanceList->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::Model::MonthlyPerformanceList>

=cut

use Bivio::Biz::Model::MonthlyPerformanceList;
@Bivio::Biz::Model::ComparisonPerformanceList::ISA = ('Bivio::Biz::Model::MonthlyPerformanceList');

=head1 DESCRIPTION

C<Bivio::Biz::Model::ComparisonPerformanceList> compare realm cash flow

=cut

#=IMPORTS
use Bivio::Biz::Model::MGFSSplitList;
use Bivio::SQL::Connection;
use Bivio::Type::Amount;
use Bivio::Type::Date;
use Bivio::Type::DateTime;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_SQL_DATE_VALUE) = Bivio::Type::DateTime->to_sql_value('?');
my($math) = 'Bivio::Type::Amount';

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Biz::Model::RealmPerformanceList

Creates a new performance list

=cut

sub new {
    # using dynamic lookup, no new in immediate super class
    my($self) = shift->SUPER::new(@_);
    $self->{$_PACKAGE} = {
	count => 0,
	current_date => Bivio::Type::Date->get_min,
	current_price => 0,
	next_date => Bivio::Type::Date->get_min,
	next_price => 0,
	splits => undef,
	sth => undef,
	ticker => undef,
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="internal_get_count"></a>

=head2 internal_get_count(hash_ref row) : string

Returns the number of units/shares purchased for the specified data
row.

=cut

sub internal_get_count {
    my($self, $row) = @_;

    # determine the number of shares affected by Entry.amount
    # on the transaction date
    return _get_count($self, $math->neg($row->{'Entry.amount'}),
	    $row->{'RealmTransaction.date_time'});
}

=for html <a name="internal_get_end_value"></a>

=head2 internal_get_end_value(string date) : (string, string)

Returns the (value, count) for the specified ending date.

=cut

sub internal_get_end_value {
    my($self, $date) = @_;
    my($fields) = $self->{$_PACKAGE};

    # return the ending shares, and their ending value
    my($price) = _get_price($self, $date);

    # clean up the sql statement buffer if not exhausted
    $fields->{sth}->finish;

    return ($math->mul($fields->{count}, $price), $fields->{count});
}

=for html <a name="internal_get_start_value"></a>

=head2 internal_get_start_value(string start_date, string end_date) : (string, string)

Returns the (value, count) for the specified starting date.

=cut

sub internal_get_start_value {
    my($self, $start_date, $end_date) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($req) = $self->get_request;

    # get the ticker from the currently loaded MGFSInstrument
    $fields->{ticker} = $req->get('Bivio::Biz::Model::MGFSInstrument')
	    ->get('symbol');

    # start the quote stream for start - end dates
    my($date_param) = Bivio::Type::DateTime->from_sql_value(
	    'mgfs_daily_quote_t.date_time');
#TODO: the order in the FROM is _very_ important,
#      it is extremely slow if the mgfs_instrument_t is first
    my($day, $time) = split(' ', $start_date);
    $fields->{sth} = Bivio::SQL::Connection->execute("
            SELECT $date_param, mgfs_daily_quote_t.close
            FROM mgfs_daily_quote_t, mgfs_instrument_t
            WHERE mgfs_instrument_t.mg_id=mgfs_daily_quote_t.mg_id
            AND mgfs_instrument_t.symbol=?
            AND mgfs_daily_quote_t.date_time
                BETWEEN $_SQL_DATE_VALUE AND $_SQL_DATE_VALUE
            ORDER BY mgfs_daily_quote_t.date_time",
	    [$fields->{ticker}, ($day - 8)." $time", $end_date]);

    _get_splits($self, $start_date, $end_date);

    # determine the number of shares equivalent RealmPerformanceList
    # start value

    my($list) = $req->get('Bivio::Biz::Model::RealmPerformanceList');
    $list->set_cursor_or_die(0);
    my($amount) = $list->get('Entry.amount');

    return ($amount, _get_count($self, $amount, $start_date));
}

#=PRIVATE METHODS

# _get_count(string amount, string date) : string
#
# Returns the number of shares purchased/sold on the specified date.
#
sub _get_count {
    my($self, $amount, $date) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($price) = _get_price($self, $date);
    my($count) = $math->div($amount, $price);

    # adjust count for future splits
    my($splits) = $fields->{splits};
    for (my($i) = 0; $i < int(@$splits); $i += 2) {
	my($split_date, $ratio) = (@$splits)[$i..$i+1];
	last if Bivio::Type::Date->compare($date, $split_date) > 0;
	#print(STDERR "adjusting $count by $ratio for "
	#.Bivio::Type::Date->to_literal($date)."\n");
	$count = $math->div($count, $ratio);
    }
    die("couldn't calculate count") unless defined($count);
    $fields->{count} = $math->add($fields->{count}, $count);
    return $count;
}

# _get_price(string date) : string
#
# Returns the price of the investment on the specified date.
#
sub _get_price {
    my($self, $date) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($sth) = $fields->{sth};

    return $fields->{current_price}
	    if Bivio::Type::Date->compare($fields->{next_date}, $date) > 0;

    while (my $row = $sth->fetchrow_arrayref) {
	my($quote_date, $close) = @$row;
	$fields->{current_date} = $fields->{next_date};
	$fields->{current_price} = $fields->{next_price};

	$fields->{next_date} = $quote_date;
	$fields->{next_price} = $close;

	last if Bivio::Type::Date->compare($quote_date, $date) > 0;
    }
    die("couldn't calculate price for ".Bivio::Type::Date->to_literal($date))
	    unless $fields->{current_price};
    return $fields->{current_price};
}

# _get_splits(string start_date, string end_date)
#
# Loads the splits field with an array of (date, ratio) values for
# splits between the specified dates.
#
sub _get_splits {
    my($self, $start_date, $end_date) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($result) = [];
    my($list) = Bivio::Biz::Model::MGFSSplitList->new($self->get_request);
    $list->load_all({'s' => $fields->{ticker}});
    while ($list->next_row) {
	my($date, $ratio) = $list->get(qw(
                MGFSSplit.date_time MGFSSplit.factor));
	next unless Bivio::Type::Date->compare($date, $start_date) >= 0
		&& Bivio::Type::Date->compare($date, $end_date) <= 0;
	push(@$result, $date, $ratio);
    }
    $fields->{splits} = $result;
    return;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
