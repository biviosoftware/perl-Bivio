# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Type::DateInterval;
use strict;
$Bivio::Type::DateInterval::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::DateInterval::VERSION;

=head1 NAME

Bivio::Type::DateInterval - various date periods

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::DateInterval;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::DateInterval::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::DateInterval> is a list and computations for various time
offsets:

=over 4

=item NONE : 0 days

=item DAY : 1 day

=item WEEK : 7 days

=item MONTH

A month relative to current date/time.  Time component unmodified.

=item YEAR

A year relative to current date/time.  Time component unmodified.

=item FISCAL_YEAR

=item SIX_MONTHS

Six months.

=back

=cut

#=IMPORTS
use Bivio::Type::DateTime;

#=VARIABLES
my($_DT) = 'Bivio::Type::DateTime';
__PACKAGE__->compile([
    NONE => [
        0,
    ],
    DAY => [
	1,
    ],
    WEEK => [
	7,
    ],
    MONTH => [
	-1,
    ],
    YEAR => [
	-2,
    ],
    FISCAL_YEAR => [
	-3,
    ],
    SIX_MONTHS => [
	-4,
    ],
]);

=head1 METHODS

=cut

=for html <a name="dec"></a>

=head2 dec(string date_time) : string

Returns I<date_time> decremented by this DateInterval.

=cut

sub dec {
    my($self, $date_time) = @_;
    return $_DT->add_days($date_time, -$self->as_int)
	    if $self->as_int >= 0;
    return &{\&{'_dec_'.lc($self->get_name)}}($date_time);
}

=for html <a name="inc"></a>

=head2 inc(string date_time) : string

Returns I<date_time> incremented by this DateInterval.

=cut

sub inc {
    my($self, $date_time) = @_;
    return $_DT->add_days($date_time, $self->as_int)
	    if $self->as_int >= 0;
    return &{\&{'_inc_'.lc($self->get_name)}}($date_time);
}

=for html <a name="inc_to_end"></a>

=head2 inc_to_end(string start_date) : string

Increments I<start_date> to end of interval.  It does not adjust the time
component.  For DAY and NONE is no-op.  For YEAR, WEEK, and MONTH increments by
the amount and substracts one day.  It does not go to the calendar period
except for FISCAL_YEAR, e.g. MONTH-E<gt>inc_to_end('12/22/2001') is
1/21/2001 (not 12/31/2001).

FISCAL_YEAR increments to 12/31.

=cut

sub inc_to_end {
    my($self, $start_date) = @_;
    my($sub) = \&{'_inc_to_end_'.lc($self->get_name)};
    return defined(&$sub) ? &$sub($self, $start_date)
	: $_DT->add_days($self->inc($start_date), -1);
}

=for html <a name="is_continuous"></a>

=head2 is_continuous() : boolean

Returns false.

=cut

sub is_continuous {
    return 0;
}

#=PRIVATE METHODS

# _dec_fiscal_year(string date_time) : string
#
# On 1/1, goes to prior year.  Else, goes to beginning of this year.
#
sub _dec_fiscal_year {
    my($date_time) = @_;
    my($sec, $min, $hour, $mday, $mon, $year) = $_DT->to_parts($date_time);
    $year-- if $mday == 1 && $mon == 1;
    return $_DT->from_parts_or_die($sec, $min, $hour, 1, 1, $year);
}

# _dec_month(string date_time) : string
#
# Goes to same date/time in previous month.  Goes to end of month if outside
# of month boundary.
#
sub _dec_month {
    my($date_time) = @_;
    my($sec, $min, $hour, $mday, $mon, $year)
	= $_DT->to_parts($date_time);
    $mon = $mon == 1 ? ($year--, 12) : $mon - 1;
    return _from_parts_with_mday_correction($sec, $min, $hour,
	$mday, $mon, $year);
}

# _dec_six_months(string date_time) : string
#
# Decrement six months.
#
sub _dec_six_months {
    my($date_time) = @_;
    return $_DT->add_months($date_time, -6);
}

# _dec_year(string date_time) : string
#
# Goes to same date/time in previous year.  Goes to month of year if outside
# of month boundary.
#
sub _dec_year {
    my($date_time) = @_;
    my($sec, $min, $hour, $mday, $mon, $year)
	= $_DT->to_parts($date_time);
    return _from_parts_with_mday_correction($sec, $min, $hour,
	$mday, $mon, $year - 1);
}

# _from_parts_with_mday_correction(int sec, int min, int hour, int mday, int mon, int year) : string
#
# Returns DateTime->from_parts correcting mday to be at month's end
# if not already at month's end.
#
sub _from_parts_with_mday_correction {
    my($sec, $min, $hour, $mday, $mon, $year) = @_;
    my($last) = $_DT->get_last_day_in_month($mon, $year);
    return $_DT->from_parts_or_die($sec, $min, $hour,
	    $mday > $last ? $last : $mday, $mon, $year);
}

# _inc_fiscal_year(string date_time) : string
#
# Goes to beginning of next year.
#
sub _inc_fiscal_year {
    my($date_time) = @_;
    my($sec, $min, $hour, $mday, $mon, $year)
	= $_DT->to_parts($date_time);
    return $_DT->from_parts_or_die($sec, $min, $hour, 1, 1, 1 + $year);
}

# _inc_month(string date_time) : string
#
# Goes to same date/time next month.  Goes to end of month if outside
# of month boundary.
#
sub _inc_month {
    my($date_time) = @_;
    my($sec, $min, $hour, $mday, $mon, $year)
	= $_DT->to_parts($date_time);
    $mon = $mon == 12 ? ($year++, 1) : $mon + 1;
    return _from_parts_with_mday_correction($sec, $min, $hour,
	$mday, $mon, $year);
}

# _inc_six_months(string date_time) : string
#
# Increments by six months.
#
sub _inc_six_months {
    my($date_time) = @_;
    return $_DT->add_months($date_time, 6);
}

# _inc_to_end_day(self, string start_date) : string
#
# No-op.
#
sub _inc_to_end_day {
    shift;
    return shift;
}

# _inc_to_end_none(self, string start_date) : string
#
# No-op.
#
sub _inc_to_end_none {
    shift;
    return shift;
}

# _inc_year(string date_time) : string
#
# Goes to same date/time in previous year.  Goes to month of year if outside
# of month boundary.
#
sub _inc_year {
    my($date_time) = @_;
    my($sec, $min, $hour, $mday, $mon, $year)
	= $_DT->to_parts($date_time);
    return _from_parts_with_mday_correction($sec, $min, $hour,
	$mday, $mon, $year + 1);
}


=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
