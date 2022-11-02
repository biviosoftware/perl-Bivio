# Copyright (c) 2000-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::DateInterval;
use strict;
use Bivio::Base 'Type.Enum';

my($_DT) = b_use('Type.DateTime');
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
    THREE_MONTHS => [
        -5,
    ],
    IRS_TAX_SEASON => [
        -6,
    ],
]);

sub dec {
    # (self, string) : string
    # Returns I<date_time> decremented by this DateInterval.
    my($self, $date_time) = @_;
    return $self->as_int >= 0 ? $_DT->add_days($date_time, -$self->as_int)
        : &{\&{'_dec_'.lc($self->get_name)}}($date_time);
}

sub inc {
    # (self, string) : string
    # Returns I<date_time> incremented by this DateInterval.
    my($self, $date_time) = @_;
    return $self->as_int >= 0 ? $_DT->add_days($date_time, $self->as_int)
        : &{\&{'_inc_'.lc($self->get_name)}}($date_time);
}

sub inc_to_end {
    # (self, string) : string
    # Increments I<start_date> to end of interval.  It does not adjust the time
    # component.  For DAY and NONE is no-op.  For YEAR, WEEK, and MONTH increments by
    # the amount and substracts one day.  It does not go to the calendar period
    # except for FISCAL_YEAR, e.g. MONTH-E<gt>inc_to_end('12/22/2001') is
    # 1/21/2001 (not 12/31/2001).
    #
    # FISCAL_YEAR increments to 12/31.
    my($self, $start_date) = @_;
    my($sub) = \&{'_inc_to_end_'.lc($self->get_name)};
    return defined(&$sub) ? $sub->($self, $start_date)
        : $_DT->add_days($self->inc($start_date), -1);
}

sub is_continuous {
    # (self) : boolean
    # Returns false.
    return 0;
}

sub _dec_fiscal_year {
    # (string) : string
    # On 1/1, goes to prior year.  Else, goes to beginning of this year.
    my($date_time) = @_;
    my($sec, $min, $hour, $mday, $mon, $year) = $_DT->to_parts($date_time);
    $year--
        if $mday == 1 && $mon == 1;
    return $_DT->from_parts_or_die($sec, $min, $hour, 1, 1, $year);
}

sub _dec_irs_tax_season {
    # (string) : string
    # If on or before 4/15, goes to 1/1 prior year.  Else, goes to 1/1 of this
    # year.
    my($date_time) = @_;
    my($sec, $min, $hour, $mday, $mon, $year) = $_DT->to_parts($date_time);
    $year--
        if $mon < 4 || $mon == 4 && $mday <= 15;
    return $_DT->from_parts_or_die($sec, $min, $hour, 1, 1, $year);
}

sub _dec_month {
    # (string) : string
    # Goes to same date/time in previous month.  Goes to end of month if outside
    # of month boundary.
    my($date_time) = @_;
    my($sec, $min, $hour, $mday, $mon, $year)
        = $_DT->to_parts($date_time);
    $mon = $mon == 1 ? ($year--, 12) : $mon - 1;
    return _from_parts_with_mday_correction($sec, $min, $hour,
        $mday, $mon, $year);
}

sub _dec_six_months {
    # (string) : string
    # Decrement six months.
    return $_DT->add_months(shift, -6);
}

sub _dec_three_months {
    # (string) : string
    # Decrement three months.
    return $_DT->add_months(shift, -3);
}

sub _dec_year {
    # (string) : string
    # Goes to same date/time in previous year.  Goes to month of year if outside
    # of month boundary.
    my($date_time) = @_;
    my($sec, $min, $hour, $mday, $mon, $year)
        = $_DT->to_parts($date_time);
    return _from_parts_with_mday_correction($sec, $min, $hour,
        $mday, $mon, $year - 1);
}

sub _from_parts_with_mday_correction {
    # (int, int, int, int, int, int) : string
    # Returns DateTime->from_parts correcting mday to be at month's end
    # if not already at month's end.
    my($sec, $min, $hour, $mday, $mon, $year) = @_;
    my($last) = $_DT->get_last_day_in_month($mon, $year);
    return $_DT->from_parts_or_die($sec, $min, $hour,
            $mday > $last ? $last : $mday, $mon, $year);
}

sub _inc_fiscal_year {
    # (string) : string
    # Goes to beginning of next year.
    my($date_time) = @_;
    my($sec, $min, $hour, $mday, $mon, $year)
        = $_DT->to_parts($date_time);
    return $_DT->from_parts_or_die($sec, $min, $hour, 1, 1, 1 + $year);
}

sub _inc_irs_tax_season {
    # (string) : string
    # Goes to the beginning of next year (just like fiscal year)
    return _inc_fiscal_year(@_);
}

sub _inc_month {
    # (string) : string
    # Goes to same date/time next month.  Goes to end of month if outside
    # of month boundary.
    my($date_time) = @_;
    my($sec, $min, $hour, $mday, $mon, $year)
        = $_DT->to_parts($date_time);
    $mon = $mon == 12 ? ($year++, 1) : $mon + 1;
    return _from_parts_with_mday_correction($sec, $min, $hour,
        $mday, $mon, $year);
}

sub _inc_six_months {
    # (string) : string
    # Increments by six months.
    return $_DT->add_months(shift, 6);
}

sub _inc_three_months {
    # (string) : string
    # Increments by three months.
    return $_DT->add_months(shift, 3);
}

sub _inc_to_end_day {
    # (self, string) : string
    # No-op.
    shift;
    return shift;
}

sub _inc_to_end_irs_tax_season {
    # (self, string) : string
    # Goes to 4/15 of this year if at or before 4/15.
    my($self, $start_date) = @_;
    my($sec, $min, $hour, $mday, $mon, $year) = $_DT->to_parts($start_date);
    return $_DT->from_parts_or_die($sec, $min, $hour, 15, 4, ++$year);
}

sub _inc_to_end_none {
    # (self, string) : string
    # No-op.
    shift;
    return shift;
}

sub _inc_year {
    # (string) : string
    # Goes to same date/time in previous year.  Goes to month of year if outside
    # of month boundary.
    my($date_time) = @_;
    my($sec, $min, $hour, $mday, $mon, $year)
        = $_DT->to_parts($date_time);
    return _from_parts_with_mday_correction($sec, $min, $hour,
        $mday, $mon, $year + 1);
}

1;
