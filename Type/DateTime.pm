# Copyright (c) 1999-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::DateTime;
use strict;
use Bivio::Base 'Bivio.Type';
use Bivio::Die;
use Bivio::Mail::RFC822;
use Bivio::Type::Array;
use Bivio::TypeError;
use Time::HiRes ();

# C<Bivio::Type::DateTime> is an absolute date, i.e. has both
# clock and calendar components.  It is also the base class of
# L<Bivio::Type::Date|Bivio::Type::Date>
# and L<Bivio::Type::Time|Bivio::Type::Time>.
# This allows for some common code.
#
# Although a C<DateTime> is represented as the number of
# julian days separated by the number of seconds in the day,
# i.e. same as C<TO_CHAR('J SSSSS')> in SQL.
# A C<DateTime> is not a L<Bivio::Type::Number|Bivio::Type::Number>.

my($_IS_TEST) = b_use('IO.Config')->is_test;
my($_TEST_NOW);
my($_MIN) = FIRST_DATE_IN_JULIAN_DAYS().' 0';
my($_MAX) = __PACKAGE__->internal_join(
    __PACKAGE__->LAST_DATE_IN_JULIAN_DAYS,
    (__PACKAGE__->SECONDS_IN_DAY - 1));
# Is this year (- FIRST_YEAR) a leap year?  Returns 0 or 1.
my(@_IS_LEAP_YEAR);
# First index is "is_leap_year", next is month - 1.
# Returns days in month and days in year up to month.
my(@_MONTH_DAYS, @_MONTH_BASE);
# Index is year - FIRST_YEAR.  Returns number of days up to this year.
my(@_YEAR_BASE);
my($_TIME_SUFFIX) = __PACKAGE__->internal_join('', __PACKAGE__->DEFAULT_TIME);
my($_DATE_PREFIX) = __PACKAGE__->internal_join(__PACKAGE__->FIRST_DATE_IN_JULIAN_DAYS, '');
my($_BEGINNING_OF_DAY) = 0;
my($_END_OF_DAY) = __PACKAGE__->SECONDS_IN_DAY-1;
my($_DAY_OF_WEEK, $_DAY_OF_WEEK3) = _init_english(
    [qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)]);
my($_NUM_TO_MONTH, $_NUM_TO_MONTH3) = _init_english(
    [qw(January February March April May June July August September October November December)]);
my($_IS_REGISTERED_WITH_TASK) = 0;
my($_MONTH3_TO_NUM) = _make_map($_NUM_TO_MONTH3);
my($_MONTH_TO_NUM) = _make_map($_NUM_TO_MONTH);
my($_PART_NUMBER) = _make_map([qw(second minute hour day month year)]);
my($_LOCAL_TIMEZONE);
my($_WINDOW_YEAR);
_initialize();

sub DEFAULT_DATE {
    # Returns L<FIRST_DATE_IN_JULIAN_DAYS|"FIRST_DATE_IN_JULIAN_DAYS">.
    # Used when there is only a time value.  See
    # L<Bivio::Type::Time|Bivio::Type::Time>.
    return FIRST_DATE_IN_JULIAN_DAYS();
}

sub DEFAULT_TIME {
    # Returns 21:59:59 in seconds (79199).  Used when the
    # user doesn't supply a "clock" part in from_literal, e.g.
    # in L<Bivio::Type::Date|Bivio::Type::Date>.  This module may
    # use it eventually, which is why it is declared here.
    #
    # The time 21:59:59 is interpreted in GMT, since both
    # L<Bivio::Type::Date|Bivio::Type::Date> and
    # L<Bivio::Type::Time|Bivio::Type::Time> are interpreted in
    # GMT.  It is the latest time in the day in Middle European
    # Time (MET) during DST.  This means that a DateTime without a
    # clock component in MET will still be the same date in GMT
    # and in the US.
    #
    # This is a compromise until we have more time work on DateTime.
    return 79199;
}

sub FIRST_DATE_IN_JULIAN_DAYS {
    # Returns 2378497.
    return 2378497;
}

sub FIRST_YEAR {
    # Returns 1800.
    return 1800;
}

sub FROM_SQL_FORMAT {
    shift->SQL_FORMAT;
}

sub LAST_DATE_IN_JULIAN_DAYS {
    # Returns 1/1/2199 in julian.
    return 2524593;
}

sub LAST_YEAR {
    # Returns 2199.
    return 2199;
}

sub RANGE_IN_DAYS {
    # Number of days between
    # L<FIRST_DATE_IN_JULIAN_DAYS|"FIRST_DATE_IN_JULIAN_DAYS">
    # and
    # L<LAST_DATE_IN_JULIAN_DAYS|"LAST_DATE_IN_JULIAN_DAYS">
    return LAST_DATE_IN_JULIAN_DAYS() - FIRST_DATE_IN_JULIAN_DAYS();
}

sub REGEX_ALERT {
    # Returns a regex which matches L<Bivio::IO::Alert|Bivio::IO::Alert>'s
    # time format (mon/day/year hour:min:sec).
    # Doesn't include begin and trailing anchors.
    return '(\d{4})/(\d+)/(\d+) (\d+):(\d+):(\d+)';
}

sub REGEX_COMMON_LOG_FORMAT {
    # Apache/NCSA Log Format
    return '\[?(\d{2})/([A-Za-z]+)/(\d{4}):(\d{2}):(\d{2}):(\d{2}) ([\-\+])(\d{2})(\d{2})\]?';
}

sub REGEX_CTIME {
    # Returns the "ctime" regex.  Ignores the time zone and day of week.
    # Doesn't include begin and trailing anchors.
    return '(?:\w+ )?(\w+)\s+(\d+) (\d+):(\d+):(\d+)(?: \w+)? (\d+)';
}

sub REGEX_FILE_NAME {
    # Returns the L<to_file_name|"to_file_name"> regex.
    return '(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})';
}

sub REGEX_LITERAL {
    # Returns the "literal" regex (two integers separated by spaces).  Doesn't
    # include begin and trailing anchors.
    return '(\d+) (\d+)';
}

sub REGEX_RFC822 {
    # Internet time.
    return qr{@{[Bivio::Mail::RFC822->DATE_TIME]}};
}

sub REGEX_STRING {
    # Output format for L<to_string|"to_string">.  Allows optional timezone.
    return '(\d+)/(\d+)/(\d{4}) (\d+):(\d+):(\d+)(?: \w+)?';
}

sub REGEX_XML {
    # Output format for L<to_xml|"to_xml"> or to_ical. Only accepts zulu.
    return '(\d{4})-?(\d\d)-?(\d\d)T(\d\d):?(\d\d):?(\d\d)(Z?)';
}

sub SECONDS_IN_DAY {
    # Returns the number of seconds in a day
    return 86400;
}

sub SQL_FORMAT {
    # Returns 'J SSSSS'.
    return 'J SSSSS';
}

sub TEST_NOW_QUERY_KEY {
    return 'date_time_test_now';
}

sub TO_SQL_FORMAT {
    return shift->SQL_FORMAT;
}

sub UNIX_EPOCH_IN_JULIAN_DAYS {
    # Number of days between the unix and julian epoch.
    return 2440588;
}

sub add_days {
    my($proto, $date_time, $days) = @_;
    # Returns I<date_time> adjusted by I<days> (may be negative).
    #
    # Dies on range error.
    my($j, $s) = $proto->internal_split($date_time);
    if (abs($days) < $proto->RANGE_IN_DAYS) {
        $j += $days;
        return $proto->internal_join($j, $s)
            if $proto->FIRST_DATE_IN_JULIAN_DAYS <= $j
            && $j < $proto->LAST_DATE_IN_JULIAN_DAYS;
    }
    Bivio::Die->die('range_error: ', $date_time, ' + ', $days);
    # DOES NOT RETURN
}

sub add_months {
    my($proto, $date_time, $months) = @_;
    my($sec, $min, $hour, $mday, $mon, $year) = $proto->to_parts($date_time);
    $year += $months / 12;
    $mon += $months % 12;
    if ($mon < 1) {
        $mon += 12;
        $year--;
    }
    elsif ($mon > 12) {
        $mon -= 12;
        $year++;
    }
    my($last_day) = $proto->get_last_day_in_month($mon, $year);
    if ($mday > $last_day) {
        $mday = $last_day;
    }
    return $proto->from_parts_or_die($sec, $min, $hour, $mday, $mon, $year);
}

sub add_seconds {
    my($proto, $date_time, $seconds) = @_;
    my($abs) = abs($seconds);
    my($sign) = $seconds < 0 ? -1 : 1;
    my($secs) = $abs % $proto->SECONDS_IN_DAY();
    my($days) = $sign * int(($abs - $secs) / $proto->SECONDS_IN_DAY() + 0.5);
    $secs *= $sign;
    my($j, $s) = $proto->internal_split($date_time);
    $s += $secs;
    if ($s < 0) {
        $days--;
        $s += $proto->SECONDS_IN_DAY;
    }
    elsif ($s >= $proto->SECONDS_IN_DAY) {
        $days++;
        $s -= SECONDS_IN_DAY();
    }
    return $proto->add_days($proto->internal_join($j, $s), $days);
}

sub add_years {
    my($proto, $date_time, $years) = @_;
    return $proto->add_months($date_time, $years * 12);
}

sub can_be_negative {
    # Returns false.
    return 0;
}

sub can_be_positive {
    # Returns true.
    return 1;
}

sub can_be_zero {
    # Returns false.
    return 0;
}

sub compare_defined {
    my($proto, $left, $right) = @_;
    # Returns 1 if I<left> is greater than I<right>.
    # Returns 0 if I<left> is equal to I<right>.
    # Returns -1 if I<left> is less than I<right>.
    my($ld, $lt) = $proto->internal_split($left);
    my($rd, $rt) = $proto->internal_split($right);
    return 1
        if $ld > $rd;
    return -1
        if $ld < $rd;
    return 1
        if $lt > $rt;
    return -1
        if $lt < $rt;
    return 0;
}

sub date_from_parts {
    my($proto, $mday, $mon, $year) = @_;
    # Returns the date/time value comprising the parts.  If there is an
    # error converting, returns undef and L<Bivio::TypeError|Bivio::TypeError>.
    return (undef, Bivio::TypeError->YEAR_DIGITS)
        unless($year) && $year > 99;
    return (undef, Bivio::TypeError->YEAR_RANGE)
        unless FIRST_YEAR() <= $year && $year <= $proto->LAST_YEAR;
    return (undef, Bivio::TypeError->MONTH)
        unless 1 <= $mon && $mon <= 12;
    $mon--;
    $year -= $proto->FIRST_YEAR;
    my($ly) = $_IS_LEAP_YEAR[$year];
    return (undef, Bivio::TypeError->DAY_OF_MONTH)
        unless 1 <= $mday && $mday <= $_MONTH_DAYS[$ly]->[$mon];
    return ($_YEAR_BASE[$year] + $_MONTH_BASE[$ly]->[$mon] + --$mday)
        . $_TIME_SUFFIX;
}

sub date_from_parts_or_die {
    # Same as L<date_from_parts|"date_from_parts">, but dies if there is an error.
    return _from_or_die('date_from_parts', @_);
}

sub delta_days {
    my($proto, $start_date, $end_date) = @_;
    # Returns the floating point difference between two dates.
    return 0
        if $start_date eq $end_date;

    my($sign) = 1;
    my(@dates) = ([$proto->internal_split($start_date)], [$proto->internal_split($end_date)]);
    if ($dates[1]->[0] < $dates[0]->[0] ||
            ($dates[1]->[0] == $dates[0]->[0] &&
                $dates[1]->[1] < $dates[0]->[1])) {
        $sign = -1;
        @dates = reverse(@dates);
    }

    my($start_days, $start_secs) = @{$dates[0]};
    my($end_days, $end_secs) = @{$dates[1]};

    if ($end_secs < $start_secs) {
        $end_secs += $proto->SECONDS_IN_DAY();
        $end_days--;
    }

    return $sign * (($end_days - $start_days) +
        ($end_secs - $start_secs)/$proto->SECONDS_IN_DAY());
}

sub diff_seconds {
    my($proto, $left, $right) = @_;
    # Subtract I<right> from I<left> and return the number of seconds.
    my($lj, $ls) = $proto->internal_split($left);
    my($rj, $rs) = $proto->internal_split($right);
    return ($lj - $rj) * $proto->SECONDS_IN_DAY + $ls - $rs;
}

sub do_iterate {
    my($proto, $op, $begin, $end) = @_;
    while ($proto->is_less_than_or_equals($begin, $end)) {
        return
            unless $proto->internal_verify_do_iterate_result($op->($begin));
        $begin = $proto->add_days($begin, 1);
    }
    return;
}

sub english_day_of_week {
    my($proto, $date) = @_;
    return $_DAY_OF_WEEK->[_dow($proto, $date)];
}

sub english_day_of_week_list {
    return @{$_DAY_OF_WEEK};
}

sub english_month {
    return _english_month($_NUM_TO_MONTH, @_);
}

sub english_month3 {
    return _english_month($_NUM_TO_MONTH3, @_);
}

sub english_month3_list {
    return @{$_NUM_TO_MONTH3};
}

sub english_month3_to_int {
    return shift->english_month_to_int(@_);
}

sub english_month_to_int {
    my($self, $month) = @_;
    $month = lc($month);
    foreach my $map ($_MONTH3_TO_NUM, $_MONTH_TO_NUM) {
        return $map->{$month} || next;
    }
    b_die($month, ': month not found');
    # DOES NOT RETURN
}

sub from_date_and_time {
    my($proto, $date, $time) = @_;
    # Merges GMT date and time values and returns new value.
    die($date, "Not a valid date-only value")
        unless $proto->is_date($date);
    die($time, "Not a valid time-only value")
        unless $proto->is_time($time);
    my($d1_d, $d1_t) = $proto->internal_split($date);
    my($d2_d, $d2_t) = $proto->internal_split($time);
    my($v, $e) = $proto->from_literal($proto->internal_join($d1_d, $d2_t));
    return ($v, $e) if $e;
    return $v;
}

sub from_literal {
    my($proto, $value) = @_;
    # Converts literal (J SSSSS), ctime, and alert formats.
    $proto->internal_from_literal_warning
        unless wantarray;
    return undef unless defined($value) && $value =~ /\S/;
    # Fix up blanks (multiples, leading, trailing)
    $value =~ s/^\s+|\s+$//;
    $value =~ s/\s+/ /g;
    my(@res);
    foreach my $method (
        \&_from_literal,
        \&_from_alert,
        \&_from_ctime,
        \&_from_string,
        \&_from_file_name,
        \&_from_rfc822,
        \&_from_xml,
        \&_from_yyyy_mm_dd_hh_mm_ss,
        \&_from_common_log_format,
        \&_from_dd_mmm_yyyy_hh_mm_ss,
    ) {
        return @res
            if @res = $method->($proto, $value);
    }
    # unknown format
    return (undef, Bivio::TypeError->DATE_TIME);
}

sub from_local_literal {
    my($proto, $value) = @_;
    # Calls L<from_literal|"from_literal"> and adds in the timezone.
    # I<value> should be in local time.
    my($res, $err) = $proto->from_literal($value);
    return $res ? _adjust_from_local($proto, $res) : ($res, $err);
}

sub from_parts {
    my($proto, $sec, $min, $hour, $mday, $mon, $year) = @_;
    my($date, $err) = $proto->date_from_parts($mday, $mon, $year);
    return (undef, $err)
        if $err;
    my($time, $err2) = $proto->time_from_parts($sec, $min, $hour);
    return (undef, $err2)
        if $err2;
    return $proto->internal_join(($proto->internal_split($date))[0], ($proto->internal_split($time))[1]);
}

sub from_parts_or_die {
    # Same as L<from_parts|"from_parts">, but dies if there is an error.
    return _from_or_die('from_parts', @_);
}

sub from_sql_value {
    my($proto, $place_holder) = @_;
    # Returns C<TO_CHAR(I<place_holder>, 'J SSSSS')>.
    return 'TO_CHAR('.$place_holder.",'".$proto->FROM_SQL_FORMAT."')";
}

sub from_unix {
    my($proto, $unix_time) = @_;
    b_die($unix_time, ': must be an unsigned integer')
        unless defined($unix_time) && $unix_time =~ /^(\d+)$/;
    my($s) = int($unix_time % $proto->SECONDS_IN_DAY() + 0.5);
    my($j) = int(($unix_time - $s)/$proto->SECONDS_IN_DAY() + 0.5)
            + $proto->UNIX_EPOCH_IN_JULIAN_DAYS();
    return $proto->internal_join($j, $s);
}

sub get_decimals {
    # Return 0.
    return 0;
}

sub get_default {
    my($proto) = @_;
    # Returns L<local_end_of_today|"local_end_of_today">. This is used by
    # L<Bivio::SQL::ListQuery|Bivio::SQL::ListQuery>
    return $proto->local_end_of_today;
}

sub get_last_day_in_month {
    my($proto, $mon, $year) = @_;
    # Given I<year> and I<month>, return the last day in that month
    my($ly) = $_IS_LEAP_YEAR[$year - Bivio::Type::DateTime::FIRST_YEAR()];
    $mon--;
    return $_MONTH_DAYS[$ly]->[$mon];
}

sub get_local_timezone {
    # Returns the localtime zone in minutes suitable for setting
    # on L<Bivio::Agent::Request|Bivio::Agent::Request>.
    #
    # This value is computed dynamically which means it can account
    # for the shift in daylight savings time.
    return $_LOCAL_TIMEZONE;
}

sub get_max {
    # Maximum date: 12/31/2199 23:59:59
    return $_MAX;
}

sub get_min {
    # Returns 1/1/1800 0:0:0.
    return $_MIN;
}

sub get_part {
    # DEPRECATED: use get_parts.
    return shift->get_parts(@_);
}

sub get_parts {
    my($proto, $date, @parts) = @_;
    # Returns the specific part of the date. Valid parts are:
    #    second
    #    minute
    #    hour
    #    day (of the month)
    #    month
    #    year
    #
    # If called in a scalar context, must be returning a single part_name.
    Bivio::Die->die(\@parts, ': only one part when called in scalar context')
        unless wantarray || @parts == 1;
    return ($proto->to_parts($date))[
        map(
            (
                $_PART_NUMBER->{$_}
                || $_PART_NUMBER->{lc($_)}
                || Bivio::Die->die($_, ': invalid part name'),
            ) - 1,
            @parts,
        ),
    ];
}

sub get_previous_day {
    my($proto, $date_time) = @_;
    b_use('IO.Alert')->warn_deprecated('use add_days');
    return $proto->add_days($date_time, -1);
}

sub get_previous_month {
    my($proto, $date_time) = @_;
    b_use('IO.Alert')->warn_deprecated('use add_months');
    return $proto->add_months($date_time, -1);
}

sub get_previous_year {
    my($proto, $date_time) = @_;
    b_use('IO.Alert')->warn_deprecated('use add_years');
    return $proto->add_years($date_time, -1);
}

sub get_width {
    # Returns 13.
    return 13;
}

sub gettimeofday {
    # Wraps the unix gettimeofday call in something handier to use.
    # Returns an array_ref of seconds and microseconds.
    return [Time::HiRes::gettimeofday()];
}

sub gettimeofday_diff_seconds {
    my($proto, $start_time) = @_;
    # Returns the delta in seconds from I<start_time>
    # to L<gettimeofday|"gettimeofday"> as a floating point number.
    # I<start_time> is a return result of L<gettimeofday|"gettimeofday">.
    Carp::croak('invalid start_time') unless $start_time;
    my($end_time) = $proto->gettimeofday;
    return $end_time->[0] - $start_time->[0]
        + ($end_time->[1] - $start_time->[1]) / 1000000.0;
}

sub handle_pre_execute_task {
    my($proto, undef, $req) = @_;
    if ($_IS_TEST && exists(($req->unsafe_get('query') || {})->{$proto->TEST_NOW_QUERY_KEY})) {
        $proto->set_test_now(
            delete($req->get('query')->{$proto->TEST_NOW_QUERY_KEY}),
            $req,
        );
    }
    return;
}

sub internal_join {
    my(undef, $date, $time) = @_;
    return "$date $time";
}

sub internal_split {
    my(undef, $date_time) = @_;
    return split(' ', $date_time);
}

sub is_date {
    my(undef, $value) = @_;
    # Is this a date (with DEFAULT_TIME)?
    return defined($value) && $value =~ /$_TIME_SUFFIX$/o ? 1 : 0;
}

sub is_time {
    my(undef, $value) = @_;
    # Is this a time (with DEFAULT_DATE)?
    return defined($value) && $value =~ /$_DATE_PREFIX/o ? 1 : 0;
}

sub is_valid_specified {
    return defined((_from_literal(@_))[0]) ? 1 : 0;
}

sub is_weekday {
    my($proto, $date_time) = @_;
    return $proto->is_weekend($date_time) ? 0 : 1;
}

sub is_weekend {
    my($proto, $date_time) = @_;
    return $proto->english_day_of_week($date_time)
        =~ /(@{[$_DAY_OF_WEEK->[0]]}|@{[$_DAY_OF_WEEK->[6]]})/;
}

sub local_end_of_today {
    # Returns the date/time for the last second in the user's "today".
    # Used to generate reports that includes the "end of business".
    return Bivio::Type::DateTime->set_local_end_of_day(Bivio::Type::DateTime->now);
}

sub local_now_as_file_name {
    my($proto) = @_;
    # Returns the file name for I<now> adjusted by the I<timezone> in the
    # current request.  If no request, just like now_as_file_name.
    #
    # See also L<now_as_file_name|"now_as_file_name">.
    # We call DateTime now, because we have to adjust for timezone.
    return $proto->to_local_file_name(__PACKAGE__->now());
}

sub local_to_parts {
    my($proto, $date_time) = @_;
    # Adjusts for local time and calls L<to_parts|"to_parts">.
    return $proto->to_parts(_adjust_to_local($proto, $date_time));
}

sub now {
    my($proto) = @_;
    if ($_IS_TEST) {
        $proto->register_with_agent_task;
        return $_TEST_NOW
            if $_TEST_NOW;
    }
    return __PACKAGE__->from_unix(time);
}

sub now_as_file_name {
    my($proto) = @_;
    # Returns L<now|"now"> as a timestamp which can be embedded in a file name.
    return $proto->to_file_name($proto->now);
}

sub now_as_string {
    my($proto) = @_;
    # Convience routine to print L<now|"now">.
    return $proto->to_string($proto->now);
}

sub now_as_year {
    my($proto) = @_;
    # Returns the year from L<now|"now">.
    return $proto->get_part($proto->now, 'year');
}

sub register_with_agent_task {
    my($self) = @_;
    return
        unless $_IS_TEST && ! $_IS_REGISTERED_WITH_TASK;
    $_IS_REGISTERED_WITH_TASK = 1;
    b_use('Agent.Task')->register(__PACKAGE__);
    return;
}

sub rfc822 {
    my($proto, $unix_time) = @_;
    # Return the rfc822 for the date/time in GMT. Format is:
    #
    #     Dow, DD Mon YYYY HH::MM::SS GMT
    $unix_time = time unless defined($unix_time);
    $unix_time = $proto->to_unix($unix_time) if $unix_time =~ /\s/;

    # We go to unix_time, because we need the weekday
    my($sec, $min, $hour, $mday, $mon, $year, $wday)
            = gmtime($unix_time);
    return sprintf('%s, %2d %s %04d %02d:%02d:%02d GMT',
            $_DAY_OF_WEEK3->[$wday], $mday, $_NUM_TO_MONTH3->[$mon], $year + 1900,
            $hour, $min, $sec);
}

sub set_beginning_of_day {
    my($proto, $date_time) = @_;
    return $proto->internal_join(($proto->internal_split($date_time))[0], $_BEGINNING_OF_DAY)
}

sub set_beginning_of_month {
    my($proto, $date_time) = @_;
    my($sec, $min, $hour, $day, $mon, $year) = $proto->to_parts($date_time);
    return $proto->from_parts_or_die($sec, $min, $hour, 1, $mon, $year);
}

sub set_beginning_of_week {
    my($proto, $date_time) = @_;
    return $proto->add_days($date_time,  -_dow($proto, $date_time));
}

sub set_end_of_day {
    my($proto, $date_time) = @_;
    return $proto->internal_join(($proto->internal_split($date_time))[0], $_END_OF_DAY)
}

sub set_end_of_month {
    my($proto, $date_time) = @_;
    my($sec, $min, $hour, $day, $mon, $year) = $proto->to_parts($date_time);
    return $proto->from_parts_or_die(
        $sec, $min, $hour,
        $proto->get_last_day_in_month($mon, $year), $mon, $year,
    );
}

sub set_end_of_week {
    my($proto, $date_time) = @_;
    return $proto->add_days($date_time, 6 - _dow($proto, $date_time));
}

sub set_local_beginning_of_day {
    my($proto, $date_time, $tz) = @_;
    return $proto->set_local_time_part($date_time, $_BEGINNING_OF_DAY, $tz);
}

sub set_local_end_of_day {
    my($proto, $date_time, $tz) = @_;
    return $proto->set_local_time_part($date_time, $_END_OF_DAY, $tz);
}

sub set_local_time_part {
    my($proto, $date_time, $seconds, $tz) = @_;
    # Sets the time component of the date/time to I<seconds> in the user's
    # time zone.  I<timezone> may be undef iwc it defaults to I<timezone>.
    my($date) = $proto->internal_split(
        $proto->is_date($date_time) ? $date_time
            : _adjust_to_local($proto, $date_time, $tz),
    );
    return _adjust_from_local($proto, "$date $seconds", $tz);
}

sub set_test_now {
    my($proto, $now) = @_;
    return $_TEST_NOW = $proto->from_literal_or_die($now, 1)
        if $_IS_TEST;
    return;
}

sub time_from_parts {
    my(undef, $sec, $min, $hour) = @_;
    # Returns the date/time value comprising the parts.  If there is an
    # error converting, returns undef and L<Bivio::TypeError|Bivio::TypeError>.
    return (undef, Bivio::TypeError->HOUR) if $hour > 23 || $hour < 0;
    return (undef, Bivio::TypeError->MINUTE) if $min > 59 || $min < 0;
    return (undef, Bivio::TypeError->SECOND) if $sec > 59 || $sec < 0;
    return $_DATE_PREFIX . (($hour * 60 + $min) * 60 + $sec);
}

sub timezone {
    # Returns the current timezone (in minutes from UTC) from I<Request.timezone> or
    # the value of L<get_local_timezone|"get_local_timezone">, if no request or not
    # set.
    return $_LOCAL_TIMEZONE
        unless UNIVERSAL::can('Bivio::Agent::Request', 'get_current');
    # We can't return something other than undef.
    my($req) = Bivio::Agent::Request->get_current;
    my($tz) = $req && $req->unsafe_get('timezone');
    return defined($tz) ? $tz : $_LOCAL_TIMEZONE;
}

sub to_alert {
    my($proto, $value) = @_;
    return sprintf(
        '%04d/%02d/%02d %02d:%02d:%02d', reverse($proto->to_parts($value)));
}

sub to_date_parts {
    my($proto, $value) = @_;
    return ($proto->to_parts($value))[3,4,5];
}

sub to_dd_mmm_yyyy {
    my($proto, $value, $sep) = @_;
    # Returns date in DD MMM YYYY format
    $sep = ' '
        unless defined($sep);
    my($mday, $mon, $year) = ($proto->to_parts($value))[3..5];
    my($format) = "%2d${sep}%s${sep}%04d";
    return sprintf($format, $mday, $_NUM_TO_MONTH3->[$mon-1], $year);
}

sub to_file_name {
    my($proto, $value) = @_;
    # Returns I<value> as a string that can be used as a part of file name.
    my($sec, $min, $hour, $day, $mon, $year) = $proto->to_parts($value);
    return sprintf('%04d%02d%02d%02d%02d%02d', $year, $mon, $day,
            $hour, $min, $sec);
}

sub to_four_digit_year {
    my(undef, $year) = @_;
    # Returns a four digit year, if not already a four digit year.
    #
    # Date windowing adjusts twenty years ahead of this year.
    return $year >= 100 ? $year
            : $year + ($year > $_WINDOW_YEAR ? 1900 : 2000);
}

sub to_ical {
    my($proto, $value) = @_;
    return
        unless $value;
    $value = $proto->to_file_name($value);
    substr($value, 8, 0) = 'T';
    return $value . 'Z';
}

sub to_json {
    return ${b_use('MIME.JSON')->to_text(shift->to_xml(shift))};
}

sub to_local {
    my($proto, $date_time, $tz) = @_;
    return _adjust_to_local($proto, $date_time, $tz);
}

sub to_local_file_name {
    my($proto, $date_time, $tz) = @_;
    # Converts to a local time file name. I<tz> is optional timezone.  Defaults to
    # I<timezone>.
    return $proto->to_file_name(_adjust_to_local($proto, $date_time, $tz));
}

sub to_local_string {
    my($proto, $date_time) = @_;
    # Converts to a human readable string in the local timezone.
    return _to_string($proto, _adjust_to_local($proto, $date_time));
}

sub to_mm_dd_yyyy {
    my($proto, $value, $sep) = @_;
    # Returns date in MM DD YYYY format
    $sep ||= '/';
    my($mday, $mon, $year) = ($proto->to_parts($value))[3..5];
    my($format) = "%02d${sep}%02d${sep}%04d";
    return sprintf($format, $mon, $mday, $year);
}

sub to_parts {
    my($proto, $value) = @_;
    # Returns the date/time in parts in the same order as C<gmtime>
    # (sec, min, hour, mday, mon, year), but mday is one-based and
    # year is four digits.
    #
    # Handles BOTH unix and date/time formats (for convenience).
    my($date, $time) = $proto->internal_split($value);

    # Unix time doesn't have a "$time" component
    unless (defined($time)) {
        Bivio::IO::Alert->warn_deprecated('localtime() going away');
        return _localtime($value);
    }

    # Parse time component
    my($sec) = int($time % 60 + 0.5);
    $time = int(($time - $sec)/ 60 + 0.5);
    my($min) = int($time % 60 + 0.5);
    my($hour) = int(($time - $min)/ 60 + 0.5);

    # Search for $date in julian tables
    my($exact, $i) = Bivio::Type::Array->bsearch_numeric($date, \@_YEAR_BASE);
    my($year) = FIRST_YEAR() + $i;
    return ($sec, $min, $hour, 1, 1, $year) if $exact;

    # Make sure within range
    if ($i == 0) {
        die("$value: time less than first year")
                    if FIRST_DATE_IN_JULIAN_DAYS > $date;
    }
    elsif ($i >= $#_YEAR_BASE) {
        die("$value: time greater than last year")
                    if LAST_DATE_IN_JULIAN_DAYS() < $date;
    }

    # Adjust year if base is after $date
    $year--, $i-- if $_YEAR_BASE[$i] > $date;
    $date -= $_YEAR_BASE[$i];
    my($month_base) = $_MONTH_BASE[$_IS_LEAP_YEAR[$i]];

    # Search for month (always in range)
    ($exact, $i) = Bivio::Type::Array->bsearch_numeric($date, $month_base);
    # Adjust month if base is after $date
    $i-- if $month_base->[$i] > $date;
    my($mon) = $i + 1;
    my($mday) = $date - $month_base->[$i] + 1;
    return ($sec, $min, $hour, $mday, $mon, $year);
}

sub to_sql_value {
    my($proto, $place_holder) = @_;
    $place_holder ||= '?';
    return qq{TO_DATE($place_holder,'@{[$proto->TO_SQL_FORMAT]}')};
}

sub to_string {
    my($proto, $date_time, $timezone) = @_;
    return _to_string(
        $proto, $date_time, defined($timezone) ? $timezone : 'GMT');
}

sub to_time_parts {
    my($proto, $value) = @_;
    return ($proto->to_parts($value))[0,1,2];
}

sub to_unix {
    my($proto, $date_time) = @_;
    # Returns unix time or blows up if before epoch.
    my($date, $time) = $proto->internal_split($date_time);
    die($date, ': date before unix epoch')
        if $date < $proto->UNIX_EPOCH_IN_JULIAN_DAYS();
    return ($date - $proto->UNIX_EPOCH_IN_JULIAN_DAYS()) * $proto->SECONDS_IN_DAY() + $time;
}

sub to_xml {
    my($proto, $value) = @_;
    # Converts to a XSL timeInstant (see
    # http://www.w3.org/TR/xmlschema-2/#timeInstant).
    # See also ISO 8601 (http://www.iso.ch/markete/8601.pdf).
    return '' unless defined($value);
    my($sec, $min, $hour, $mday, $mon, $year) = $proto->to_parts($value);
    return sprintf('%04d-%02d-%02dT%02d:%02d:%02dZ',
        $year, $mon, $mday, $hour, $min, $sec);
}

sub to_yyyy_mm_dd {
    my($proto, $date_time, $sep) = @_;
    $sep ||= '';
    my($mday, $mon, $year) = $proto->to_date_parts($date_time);
    return sprintf("%04d$sep%02d$sep%02d", $year, $mon, $mday);
}

sub _adjust_from_local {
    return _adjust_local(+1, @_);
}

sub _adjust_local {
    my($sign, $proto, $value, $tz) = @_;
    return $proto->add_seconds(
        $value, $sign * 60 * (defined($tz) ? $tz : $proto->timezone));
}

sub _adjust_to_local {
    return _adjust_local(-1, @_);
}

sub _compute_local_timezone {
    my($now) = time();
    # Computes the local timezone by using _localtime().
    my($local, $err) = __PACKAGE__->from_parts(_localtime($now));
    Bivio::Die->die('DIE', {
        message => 'unable to convert localtime',
        type_error => $err,
        entity => $now,
    }) unless $local;
    $_LOCAL_TIMEZONE =
        int(__PACKAGE__->diff_seconds(__PACKAGE__->from_unix($now), $local)
            / 60 + 0.5);
    return;
}

sub _dow {
    my($proto, $date) = @_;
    return (gmtime($proto->to_unix($date)))[6];
}

sub _english_month {
    my($array, undef, $month) = @_;
    b_die('month out of range: ', $month)
        unless 1 <= $month && $month <= 12;
    return $array->[$month - 1];
}

sub _from_alert {
    my($proto, $value, $res, $err) = @_;
    # Returns ($res, $err) if it matches the pattern.  Parses alert format.
    my($y, $mon, $d, $h, $m, $s) = $value =~ /^@{[$proto->REGEX_ALERT()]}$/;
    return () unless defined($s);
    return $proto->from_parts($s, $m, $h, $d, $mon, $y);
}

sub _from_common_log_format {
    my($proto, $value, $res, $err) = @_;
    my($d, $mon, $y, $h, $m, $s, $sign, $dh, $dm)
        = $value =~ /^@{[$proto->REGEX_COMMON_LOG_FORMAT()]}$/;
    return ()
        unless defined($y);
    return (undef, Bivio::TypeError->MONTH)
        unless defined($mon = $_MONTH3_TO_NUM->{lc($mon)});
    return $proto->add_seconds(
        $proto->from_parts($s, $m, $h, $d, $mon, $y),
        ($sign eq '-' ? +1 : -1) * (60 * (60 * $dh + $dm)),
    );
}

sub _from_ctime {
    my($proto, $value, $res, $err) = @_;
    my($mon, $d, $h, $m, $s, $y) = $value =~ /^@{[$proto->REGEX_CTIME()]}$/;
    return ()
        unless defined($y);
    return (undef, Bivio::TypeError->MONTH)
        unless defined($mon = $_MONTH3_TO_NUM->{lc($mon)});
    return $proto->from_parts($s, $m, $h, $d, $mon, $y);
}

sub _from_dd_mmm_yyyy_hh_mm_ss {
    my($proto, $value) = @_;
    # ex. 07-Jun-2013 13:56:17
    my($d, $mon, $y, $h, $m, $s) = $value =~ /(\d\d?)\-(\w+)\-(\d{4}) (\d{1,2}):(\d{1,2})(?::(\d{1,2}))?/;
    return ()
        unless defined($y);
    return (undef, Bivio::TypeError->MONTH)
        unless defined($mon = $_MONTH3_TO_NUM->{lc($mon)});
    return $proto->from_parts($s || 0, $m, $h, $d, $mon, $y);
}

sub _from_file_name {
    my($proto, $value) = @_;
    # Parses to_file_name format
    my($y, $mon, $d, $h, $m, $s) = $value =~ /^@{[$proto->REGEX_FILE_NAME()]}$/;
    return defined($s) ? $proto->from_parts($s, $m, $h, $d, $mon, $y) : ();
}

sub _from_literal {
    my($proto, $value, $res, $err) = @_;
    # Returns ($res, $err) if it matches the pattern.  Parses literal format.
    my($date, $time) = $value =~ /^@{[$proto->REGEX_LITERAL()]}$/;
    return () unless defined($time);
    return (undef, Bivio::TypeError->DATE_RANGE)
        if length($date) > length($proto->LAST_DATE_IN_JULIAN_DAYS())
            || $date < $proto->FIRST_DATE_IN_JULIAN_DAYS()
            || $date > $proto->LAST_DATE_IN_JULIAN_DAYS();
    return (undef, Bivio::TypeError->TIME_RANGE)
        if length($time) > length($proto->SECONDS_IN_DAY())
            || $time >= $proto->SECONDS_IN_DAY();
    return $proto->internal_join($date, $time);
}

sub _from_or_die {
    my($method, $proto) = (shift, shift);
    my($res, $e) = $proto->$method(@_);
    return $res
        if defined($res);
    Bivio::Die->throw_die('DIE', {
        message => "$method failed: " . $e->get_long_desc,
        program_error => 1,
        error_enum => $e,
        entity => [@_],
        class => (ref($proto) || $proto),
    });
    # DOES NOT RETURN
}

sub _from_rfc822 {
    my($proto, $value) = @_;
    my($DATE_TIME) = Bivio::Mail::RFC822->DATE_TIME;
    my($mday, $mon, $year, $hour, $min, $sec, $tz)
        = $value =~ /^@{[$proto->REGEX_RFC822]}/s;
    return
        unless defined($mday);
    return (undef, Bivio::TypeError->MONTH)
        unless defined($mon = $_MONTH3_TO_NUM->{lc($mon)});
    my($v, $e) = $proto->from_parts($sec, $min, $hour, $mday, $mon, $year);
    return (undef, $e)
        if $e;
    $tz = Bivio::Mail::RFC822::TIME_ZONES->{uc($tz)}
        if defined(Bivio::Mail::RFC822->TIME_ZONES->{uc($tz)});
    return $v
        if $tz =~ /^0+$/;
    return (undef, Bivio::TypeError->TIME_ZONE)
        unless $tz =~ /^(-|\+?)(\d\d?)(\d\d)/s;
    return $proto->add_seconds(
        $v, - ($1 eq '-' ? -1 : +1) * 60 * ($2 * 60 + $3));

}

sub _from_string {
    my($proto, $value) = @_;
    # Returns ($res, $err) if it matches to_string pattern.  Parses string format.
    my($mon, $d, $y, $h, $m, $s) = $value =~ /^@{[$proto->REGEX_STRING()]}$/;
    return defined($s) ? $proto->from_parts($s, $m, $h, $d, $mon, $y) : ();
}

sub _from_xml {
    my($proto, $value) = @_;
    # Parses to_xml format
    my($y, $mon, $d, $h, $m, $s, $z) = $value =~ /^@{[$proto->REGEX_XML()]}$/;
    return ()
        unless defined($s);
    my($res) = $proto->from_parts($s, $m, $h, $d, $mon, $y);
    return $z ? $res : _adjust_from_local($proto, $res);
}

sub _from_yyyy_mm_dd_hh_mm_ss {
    my($proto, $value) = @_;
    my($y, $mon, $d, $h, $m, $s) = $value =~ /(\d{4})\W(\d{1,2})\W(\d{1,2})\W(\d{1,2}):(\d{1,2})(?::(\d{1,2}))?/;
    return defined($y) ? $proto->from_parts($s || 0, $m, $h, $d, $mon, $y) : ();
}

sub _init_english {
    my($words) = @_;
    return (
        $words,
        [map(substr($_, 0, 3), @$words)],
    );
}

sub _initialize {
    # Initializes year and month tables.
    # 0th index is non-leap year
    @_MONTH_DAYS = [(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)];
    # 1th index is leap-year
    $_MONTH_DAYS[1] = [@{$_MONTH_DAYS[0]}];
    $_MONTH_DAYS[1]->[1] = 29;

    # Create month bases from month days
    foreach my $ly (0..1) {
        $_MONTH_BASE[$ly] = [0];
        foreach my $m (1..11) {
            $_MONTH_BASE[$ly]->[$m] = $_MONTH_BASE[$ly]->[$m-1]
                    + $_MONTH_DAYS[$ly]->[$m-1];
        }
    }
    # 1800 is a leap year and is julian 2378497
    $_IS_LEAP_YEAR[0] = 0;
    $_YEAR_BASE[0] = Bivio::Type::DateTime->FIRST_DATE_IN_JULIAN_DAYS;
    foreach my $y (Bivio::Type::DateTime::FIRST_YEAR()+1
            ..Bivio::Type::DateTime::LAST_YEAR()) {
        my($yy) = $y - Bivio::Type::DateTime::FIRST_YEAR();
        $_IS_LEAP_YEAR[$yy] = ($y % 4 == 0 && ($y % 100 != 0 || $y == 2000))
                ? 1 : 0;
        $_YEAR_BASE[$yy] = $_YEAR_BASE[$yy-1]
                + ($_IS_LEAP_YEAR[$yy-1] ? 366 : 365);
    }
    _compute_local_timezone();

    # Windowing year is always 20 years ahead of now.
    $_WINDOW_YEAR = int(((localtime)[5] + 20) % 100);
    return;
}

sub _localtime {
    my($unix_time) = @_;
    # Returns the parts adjust for month and year.
    my($sec, $min, $hour, $mday, $mon, $year) = localtime($unix_time);
    $mon++;
    $year += 1900;
    return ($sec, $min, $hour, $mday, $mon, $year);
}

sub _make_map {
    my($list) = @_;
    return {map((lc($list->[$_]), $_ + 1), 0 .. $#$list)};
}

sub _to_string {
    my($proto, $date_time, $timezone) = @_;
    # Does the work of to_string and to_local_string.
    return
        '' unless defined($date_time);
    my($sec, $min, $hour, $mday, $mon, $year) = $proto->to_parts($date_time);
    return sprintf(
        '%02d/%02d/%04d %02d:%02d:%02d%s',
        $mon, $mday, $year,
        $hour, $min, $sec,
        $timezone ? " $timezone" : '',
    );
}

1;
