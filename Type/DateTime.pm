# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Type::DateTime;
use strict;
$Bivio::Type::DateTime::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::DateTime::VERSION;

=head1 NAME

Bivio::Type::DateTime - base class for all date/time types and type in itself

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::DateTime;

=cut

=head1 EXTENDS

L<Bivio::Type>

=cut

use Bivio::Type;
@Bivio::Type::DateTime::ISA = qw(Bivio::Type);

=head1 DESCRIPTION

C<Bivio::Type::DateTime> is an absolute date, i.e. has both
clock and calendar components.  It is also the base class of
L<Bivio::Type::Date|Bivio::Type::Date>
and L<Bivio::Type::Time|Bivio::Type::Time>.
This allows for some common code.

Although a C<DateTime> is represented as the number of
julian days separated by the number of seconds in the day,
i.e. same as C<TO_CHAR('J SSSSS')> in SQL.
A C<DateTime> is not a L<Bivio::Type::Number|Bivio::Type::Number>.

=cut

=head1 CONSTANTS

=cut

=for html <a name="DEFAULT_DATE"></a>

=head2 DEFAULT_DATE : string

Returns L<FIRST_DATE_IN_JULIAN_DAYS|"FIRST_DATE_IN_JULIAN_DAYS">.
Used when there is only a time value.  See
L<Bivio::Type::Time|Bivio::Type::Time>.

=cut

sub DEFAULT_DATE {
    return FIRST_DATE_IN_JULIAN_DAYS();
}

=for html <a name="DEFAULT_TIME"></a>

=head2 DEFAULT_TIME : int

Returns 21:59:59 in seconds (79199).  Used when the
user doesn't supply a "clock" part in from_literal, e.g.
in L<Bivio::Type::Date|Bivio::Type::Date>.  This module may
use it eventually, which is why it is declared here.

The time 21:59:59 is interpreted in GMT, since both
L<Bivio::Type::Date|Bivio::Type::Date> and
L<Bivio::Type::Time|Bivio::Type::Time> are interpreted in
GMT.  It is the latest time in the day in Middle European
Time (MET) during DST.  This means that a DateTime without a
clock component in MET will still be the same date in GMT
and in the US.

This is a compromise until we have more time work on DateTime.

=cut

sub DEFAULT_TIME {
    return 79199;
}

=for html <a name="FIRST_DATE_IN_JULIAN_DAYS"></a>

=head2 FIRST_DATE_IN_JULIAN_DAYS : int

Returns 2378497.

=cut

sub FIRST_DATE_IN_JULIAN_DAYS {
    return 2378497;
}

=for html <a name="FIRST_YEAR"></a>

=head2 FIRST_YEAR : int

Returns 1800.

=cut

sub FIRST_YEAR {
    return 1800;
}

=for html <a name="LAST_YEAR"></a>

=head2 LAST_YEAR : int

Returns 2199.

=cut

sub LAST_YEAR {
    return 2199;
}

=for html <a name="LAST_DATE_IN_JULIAN_DAYS"></a>

=head2 LAST_DATE_IN_JULIAN_DAYS : int

Returns 1/1/2199 in julian.

=cut

sub LAST_DATE_IN_JULIAN_DAYS {
    return 2524593;
}

=for html <a name="RANGE_IN_DAYS"></a>

=head2 RANGE_IN_DAYS : int

Number of days between
L<FIRST_DATE_IN_JULIAN_DAYS|"FIRST_DATE_IN_JULIAN_DAYS">
and
L<LAST_DATE_IN_JULIAN_DAYS|"LAST_DATE_IN_JULIAN_DAYS">


=cut

sub RANGE_IN_DAYS {
    return LAST_DATE_IN_JULIAN_DAYS() - FIRST_DATE_IN_JULIAN_DAYS();
}

=for html <a name="REGEX_ALERT"></a>

=head2 REGEX_ALERT : string

Returns a regex which matches L<Bivio::IO::Alert|Bivio::IO::Alert>'s
time format (mon/day/year hour:min:sec).
Doesn't include begin and trailing anchors.

=cut

sub REGEX_ALERT {
    return '(\d{4})/(\d+)/(\d+) (\d+):(\d+):(\d+)';
}

=for html <a name="REGEX_CTIME"></a>

=head2 REGEX_CTIME : string

Returns the "ctime" regex.  Ignores the time zone and day of week.
Doesn't include begin and trailing anchors.

=cut

sub REGEX_CTIME {
    return '(?:\w+ )?(\w+)\s+(\d+) (\d+):(\d+):(\d+)(?: \w+)? (\d+)';
}

=for html <a name="SECONDS_IN_DAY"></a>

=head2 SECONDS_IN_DAY : int

Returns the number of seconds in a day

=cut

sub SECONDS_IN_DAY {
    return 86400;
}

=for html <a name="SQL_FORMAT"></a>

=head2 SQL_FORMAT : string

Returns 'J SSSSS'.

=cut

sub SQL_FORMAT {
    return 'J SSSSS';
}

=for html <a name="UNIX_EPOCH_IN_JULIAN_DAYS"></a>

=head2 UNIX_EPOCH_IN_JULIAN_DAYS : int

Number of days between the unix and julian epoch.

=cut

sub UNIX_EPOCH_IN_JULIAN_DAYS {
    return 2440588;
}

#=IMPORTS
use Bivio::Die;
use Bivio::Type::Array;
use Bivio::TypeError;
if ($^O !~ /win32/i) {
    package main;
    require 'syscall.ph';
}

#=VARIABLES
my($_MIN) = FIRST_DATE_IN_JULIAN_DAYS().' 0';
my($_MAX) = LAST_DATE_IN_JULIAN_DAYS().' '.(SECONDS_IN_DAY() - 1);
# Is this year (- FIRST_YEAR) a leap year?  Returns 0 or 1.
my(@_IS_LEAP_YEAR);
# First index is "is_leap_year", next is month - 1.
# Returns days in month and days in year up to month.
my(@_MONTH_DAYS, @_MONTH_BASE);
# Index is year - FIRST_YEAR.  Returns number of days up to this year.
my(@_YEAR_BASE);
my($_TIME_SUFFIX) = ' '.DEFAULT_TIME();
my($_DATE_PREFIX) = FIRST_DATE_IN_JULIAN_DAYS().' ';
my($_END_OF_DAY) = SECONDS_IN_DAY()-1;
my(@_DOW) = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat');
my(@_MONTH) = ('Jan','Feb','Mar','Apr','May','Jun',
	'Jul','Aug','Sep','Oct','Nov','Dec');
# Maps uc(months) to numbers (see _initialize() and _from_ctime())
my(%_MONTH);
my(%_PART_NAMES) = (
    second => 0,
    minute => 1,
    hour => 2,
    day => 3,
    month => 4,
    year => 5,
);
my($_REGEX_CTIME) = REGEX_CTIME();
my($_REGEX_ALERT) = REGEX_ALERT();
my($_LOCAL_TIMEZONE);
my($_WINDOW_YEAR);
_initialize();

=head1 METHODS

=cut

=for html <a name="add_days"></a>

=head2 static add_days(string date_time, int days) : string

Returns I<date_time> adjusted by I<days> (may be negative).

Dies on range error.

=cut

sub add_days {
    my($proto, $date_time, $days) = @_;
    my($j, $s) = split(' ', $date_time);
    if (abs($days) < RANGE_IN_DAYS()) {
	$j += $days;
	return $j.' '.$s
		if FIRST_DATE_IN_JULIAN_DAYS() <= $j
			&& $j < LAST_DATE_IN_JULIAN_DAYS();
    }
    Bivio::Die->die('range_error: ', $date_time, ' + ', $days);
    # DOES NOT RETURN
}

=for html <a name="add_months"></a>

=head2 static add_months(string date_time, int months) : string

Returns I<date_time> adjusted by I<> (may be negative).

Aborts on range error.

=cut

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

=for html <a name="add_seconds"></a>

=head2 static add_seconds(string date_time, int seconds) : string

Returns I<date_time> adjusted by I<seconds> (may be negative).

Aborts on range error.

=cut

sub add_seconds {
    my($proto, $date_time, $seconds) = @_;

    # Compute the adjustment in seconds and days
    my($abs) = abs($seconds);
    my($sign) = $seconds < 0 ? -1 : 1;
    my($secs) = $abs % SECONDS_IN_DAY();
    my($days) = $sign * int(($abs - $secs) / SECONDS_IN_DAY() + 0.5);
    $secs *= $sign;

    # Adjust for the seconds component
    my($j, $s) = split(' ', $date_time);
    $s += $secs;

    # Compute wrap, if any
    if ($s < 0) {
	$days--;
	$s += SECONDS_IN_DAY();
    }
    elsif ($s >= SECONDS_IN_DAY()) {
	$days++;
	$s -= SECONDS_IN_DAY();
    }

    # Adjust the days component (also checks range)
    return $proto->add_days($j.' '.$s, $days);
}

=for html <a name="can_be_negative"></a>

=head2 static can_be_negative : boolean

Returns false.

=cut

sub can_be_negative {
    return 0;
}

=for html <a name="can_be_positive"></a>

=head2 static can_be_positive : boolean

Returns true.

=cut

sub can_be_positive {
    return 1;
}

=for html <a name="can_be_zero"></a>

=head2 static can_be_zero : boolean

Returns false.

=cut

sub can_be_zero {
    return 0;
}

=for html <a name="compare"></a>

=head2 compare(string left, string right) : int

Returns 1 if I<left> is greater than I<right>.
Returns 0 if I<left> is equal to I<right>.
Returns -1 if I<left> is less than I<right>.

=cut

sub compare {
    my(undef, $left, $right) = @_;
    my($ld, $lt) = split(/\s+/, $left);
    my($rd, $rt) = split(/\s+/, $right);
    return 1 if $ld > $rd;
    return -1 if $ld < $rd;
    return 1 if $lt > $rt;
    return -1 if $lt < $rt;
    return 0;
}

=for html <a name="date_from_parts"></a>

=head2 date_from_parts(int mday, int mon, int year) : array

Returns the date/time value comprising the parts.  If there is an
error converting, returns undef and L<Bivio::TypeError|Bivio::TypeError>.

=cut

sub date_from_parts {
    my(undef, $mday, $mon, $year) = @_;
    return (undef, Bivio::TypeError::YEAR_DIGITS())
	    if $year < 100;
    return (undef, Bivio::TypeError::YEAR_RANGE())
	    unless FIRST_YEAR() <= $year && $year <= LAST_YEAR();
    return (undef, Bivio::TypeError::MONTH()) unless 1 <= $mon && $mon <= 12;
    $mon--;
    $year -= Bivio::Type::DateTime::FIRST_YEAR();
    my($ly) = $_IS_LEAP_YEAR[$year];
    return (undef, Bivio::TypeError::DAY_OF_MONTH())
	    unless 1 <= $mday && $mday <= $_MONTH_DAYS[$ly]->[$mon];
    return ($_YEAR_BASE[$year] + $_MONTH_BASE[$ly]->[$mon] + --$mday)
	    .$_TIME_SUFFIX;
}

=for html <a name="diff_seconds"></a>

=head2 diff_seconds(string left, string right) : int

Subtract I<right> from I<left> and return the number of seconds.

=cut

sub diff_seconds {
    my(undef, $left, $right) = @_;
    my($lj, $ls) = split(' ', $left);
    my($rj, $rs) = split(' ', $right);
    return ($lj - $rj) * SECONDS_IN_DAY() + $ls - $rs;
}

=for html <a name="english_month3"></a>

=head2 english_month3(int month) : string

Returns I<month> as a three character string with first letter caps.

=cut

sub english_month3 {
    my(undef, $month) = @_;
    Bivio::Die->die('month out of range: ', $month)
		unless 1 <= $month && $month <= 12;
    return $_MONTH[$month - 1];
}

=for html <a name="from_local_literal"></a>

=head2 static from_local_literal(string value) : array

Calls L<from_literal|"from_literal"> and adds in the timezone.
I<value> should be in local time.

=cut

sub from_local_literal {
    my($proto, $value) = @_;
    my($res, $err) = $proto->from_literal($value);
    return ($res, $err) unless $res;
    return (_adjust_from_local($res), undef);
}

=for html <a name="from_parts"></a>

=head2 static from_parts(int sec, int min, int hour, int mday, int mon, int year) : array

Returns the date/time value from I<sec>, I<min>, I<hour>, I<mday>,
I<mon>, and I<year>.

=cut

sub from_parts {
    my($proto, $sec, $min, $hour, $mday, $mon, $year) = @_;
    my($date, $err) = $proto->date_from_parts($mday, $mon, $year);
    return (undef, $err) if $err;
    my($time, $err2) = $proto->time_from_parts($sec, $min, $hour);
    return (undef, $err2) if $err2;
    return (split(' ', $date))[0].' '.(split(' ', $time))[1];
}

=for html <a name="from_parts_or_die"></a>

=head2 static from_parts_or_die(int sec, int min, int hour, int mday, int mon, int year) : array

Same as L<from_parts|"from_parts">, but dies if there is an error.

=cut

sub from_parts_or_die {
    my($proto) = shift;
    my($res, $e) = $proto->from_parts(@_);
    return $res if defined($res);
    Bivio::Die->throw_die('DIE', {
	message => 'from_parts failed: '.$e->get_long_desc,
	program_error => 1,
	error_enum => $e,
	entity => [@_],
	class => (ref($proto) || $proto),
    });
    # DOES NOT RETURN
}

=for html <a name="get_last_day_in_month"></a>

=head2 get_last_day_in_month(int mon, int year) : int

Given I<year> and I<month>, return the last day in that month

=cut

sub get_last_day_in_month {
    my($proto, $mon, $year) = @_;
    my($ly) = $_IS_LEAP_YEAR[$year - Bivio::Type::DateTime::FIRST_YEAR()];
    $mon--;
    return $_MONTH_DAYS[$ly]->[$mon];
}

=for html <a name="get_local_timezone"></a>

=head2 static get_local_timezone() : int

Returns the localtime zone in minutes suitable for setting
on L<Bivio::Agent::Request|Bivio::Agent::Request>.

This value is computed dynamically which means it can account
for the shift in daylight savings time.

=cut

sub get_local_timezone {
    return $_LOCAL_TIMEZONE;
}

=for html <a name="get_part"></a>

=head2 get_part(string date, string part_name) : string

Returns the specific part of the date. Valid parts are:
   second
   minute
   hour
   day (of the month)
   month
   year

=cut

sub get_part {
    my($proto, $date, $part_name) = @_;

    my($index) = $_PART_NAMES{$part_name};
    Bivio::Die->die('invalid part name', $part_name) unless defined($index);

    return ($proto->to_parts($date))[$index];
}

=for html <a name="get_previous_day"></a>

=head2 static get_previous_day(string date) : string

Returns the date value for the day previous to the specified date.

=cut

sub get_previous_day {
    my($proto, $date) = @_;
    my($j, $s) = split(' ', $date);
    return ($j - 1) . ' ' . $s;
}

=for html <a name="get_previous_month"></a>

=head2 get_previous_month(string date) : string

Returns the date value closest to the previous month of the specified date.

=cut

sub get_previous_month {
    my($proto, $date) = @_;

    my($day, $month, $year) = ($proto->to_parts($date))[3..5];
    if (--$month == 0) {
	$month = 12;
	$year--;
    }

    my($prev_date, $err);
    # find the closest day of that month
    for my $i (0 .. 3) {
	($prev_date, $err) = $proto->date_from_parts($day, $month, $year);
	last unless $err;
	$day--;
    }

    # may drop off the end if original date near min
    return $prev_date || $proto->get_min;
}

=for html <a name="get_previous_year"></a>

=head2 get_previous_year(string date) : string

Returns the date value closest to the previous year of the specified date.

=cut

sub get_previous_year {
    my($proto, $date) = @_;

    my($day, $month, $year) = ($proto->to_parts($date))[3..5];
    $year--;

    my($prev_date, $err);
    # find the closest day of that month
    for my $i (0 .. 1) {
	($prev_date, $err) = $proto->date_from_parts($day, $month, $year);
	last unless $err;
	$day--;
    }

    # may drop off the end if original date near min
    return $prev_date || $proto->get_min;
}

=for html <a name="gettimeofday"></a>

=head2 static gettimeofday() : array_ref

Wraps the unix gettimeofday call in something handier to use.
Returns an array_ref of seconds and microseconds.

=cut

sub gettimeofday {
    my($i) = '8..bytes';
    syscall(&main::SYS_gettimeofday, $i, 0);
    return [unpack('ll', $i)];
}

=for html <a name="gettimeofday_diff_seconds"></a>

=head2 static gettimeofday_diff_seconds(array_ref start_time) : float

Returns the delta in seconds from I<start_time>
to L<gettimeofday|"gettimeofday"> as a floating point number.
I<start_time> is a return result of L<gettimeofday|"gettimeofday">.

=cut

sub gettimeofday_diff_seconds {
    my($proto, $start_time) = @_;
    Carp::croak('invalid start_time') unless $start_time;
    my($end_time) = $proto->gettimeofday;
    return $end_time->[0] - $start_time->[0]
        + ($end_time->[1] - $start_time->[1]) / 1000000.0;
}

=for html <a name="local_end_of_today"></a>

=head2 local_end_of_today() : string

Returns the date/time for the last second in the user's "today".
Used to generate reports that includes the "end of business".

=cut

sub local_end_of_today {
    return Bivio::Type::DateTime->set_local_end_of_day(Bivio::Type::DateTime->now);
}

=for html <a name="from_unix"></a>

=head2 from_unix(int unix_time) : string

Returns date/time for I<unix_time>.

=cut

sub from_unix {
    my(undef, $unix_time) = @_;
    return undef unless defined($unix_time);
    my($s) = int($unix_time % SECONDS_IN_DAY() + 0.5);
    my($j) = int(($unix_time - $s)/SECONDS_IN_DAY() + 0.5)
	    + UNIX_EPOCH_IN_JULIAN_DAYS();
    return $j . ' ' . $s;
}

=for html <a name="local_now_as_file_name"></a>

=head2 static local_now_as_file_name() : string

Returns the file name for I<now> adjusted by the I<timezone> in the
current request.  If no request, just like now_as_file_name.

See also L<now_as_filename|"now_as_filename">.

=cut

sub local_now_as_file_name {
    my($proto) = @_;
    # We call DateTime now, because we have to adjust for timezone.
    return $proto->to_file_name(_adjust_to_local(__PACKAGE__->now()));
}

=for html <a name="local_to_parts"></a>

=head2 local_to_parts(string date_time) : array

Adjusts for local time and calls L<to_parts|"to_parts">.

=cut

sub local_to_parts {
    my($self, $date_time) = @_;
    return $self->to_parts(_adjust_to_local($date_time));
}

=for html <a name="max"></a>

=head2 max(string left, string right) : string

Returns the greater of the two dates.

=cut

sub max {
    my($proto, $left, $right) = @_;
    return $left if $proto->compare($left, $right) > 0;
    return $right;
}

=for html <a name="min"></a>

=head2 min(string left, string right) : string

Returns the lesser of the two dates.

=cut

sub min {
    my($proto, $left, $right) = @_;
    return $left if $proto->compare($left, $right) < 0;
    return $right;
}

=for html <a name="now"></a>

=head2 now() : string

Returns date/time for now.

=cut

sub now {
    return from_unix(__PACKAGE__, time);
}

=for html <a name="now_as_file_name"></a>

=head2 static now_as_file_name() : string

Returns L<now|"now"> as a timestamp which can be embedded in a file name.

=cut

sub now_as_file_name {
    my($proto) = @_;
    return $proto->to_file_name($proto->now);
}

=for html <a name="now_as_string"></a>

=head2 now_as_string() : string

Convience routine to print L<now|"now">.

=cut

sub now_as_string {
    my($proto) = @_;
    return $proto->to_string($proto->now);
}

=for html <a name="rfc822"></a>

=head2 rfc822() : string

=head2 rfc822(int unix_time) : string

=head2 rfc822(string date_time) : string

Return the rfc822 for the date/time in GMT. Format is:

    Dow, DD Mon YYYY HH::MM::SS GMT

=cut

sub rfc822 {
    my($proto, $unix_time) = @_;
    $unix_time = time unless defined($unix_time);
    $unix_time = $proto->to_unix($unix_time) if $unix_time =~ /\s/;

    # We go to unix_time, because we need the weekday
    my($sec, $min, $hour, $mday, $mon, $year, $wday)
	    = gmtime($unix_time);
    return sprintf('%s, %2d %s %04d %02d:%02d:%02d GMT',
	    $_DOW[$wday], $mday, $_MONTH[$mon], $year + 1900,
	    $hour, $min, $sec);
}

=for html <a name="set_local_end_of_day"></a>

=head2 set_local_end_of_day(string date_time) : string

Sets the time component of the date/time to 23:59:59 in the user's
time zone.

=cut

sub set_local_end_of_day {
    my($proto, $date_time) = @_;
    my($date, $time) = split(' ', $date_time);
    my($tz) = _timezone();

    return $date.' '.$_END_OF_DAY unless defined($tz);
    # The timezone is really a timezone offset for now.  This will
    # have to be fixed someday, but not right now.
    $tz *= 60;

    # This algorithm is "dumb and stupid", because I'm trying to get it
    # right.  Probably smarter ways...

    # First figure out what the day is
    $time -= $tz;
    if ($time < 0) {
	$date--;
    }
    elsif ($time >= SECONDS_IN_DAY()) {
	$date++;
    }

    # Next figure out what day GMT is in when today is at end of day
    $time = ($_END_OF_DAY + $tz) % SECONDS_IN_DAY();
    if ($tz > 0) {
	$date++;
    }
    elsif ($tz < 0) {
	$date--;
    }

    # Return the adjusted date and time
    return $date.' '.$time;
}

=for html <a name="from_literal"></a>

=head2 static from_literal(string value) : array

Converts literal (J SSSSS), ctime, and alert formats.

=cut

sub from_literal {
    my($proto, $value) = @_;
    return undef unless defined($value) && $value =~ /\S/;
    # Fix up blanks (multiples, leading, trailing)
    $value =~ s/^\s+|\s+$//;
    $value =~ s/\s+/ /g;
    my($res, $err);
    foreach my $method (\&_from_literal, \&_from_alert, \&_from_ctime) {
	return ($res, $err) if &$method($proto, $value, \$res, \$err);
    }
    # unknown format
    return (undef, Bivio::TypeError::DATE_TIME());
}

=for html <a name="from_sql_value"></a>

=head2 from_sql_value(string place_holder) : string

Returns C<TO_CHAR(I<place_holder>, 'J SSSSS')>.

=cut

sub from_sql_value {
    my(undef, $place_holder) = @_;
    return 'TO_CHAR('.$place_holder.",'".SQL_FORMAT()."')";
}

=for html <a name="get_decimals"></a>

=head2 static get_decimals : int

Return 0.

=cut

sub get_decimals {
    return 0;
}

=for html <a name="get_max"></a>

=head2 get_max() : string

Maximum date: 12/31/2199 23:59:59

=cut

sub get_max {
    return $_MAX;
}

=for html <a name="get_min"></a>

=head2 get_min() : string

Returns 1/1/1800 0:0:0.

=cut

sub get_min {
    return $_MIN;
}

=for html <a name="get_width"></a>

=head2 static get_width : int

Returns 13.

=cut

sub get_width {
    return 13;
}

=for html <a name="to_file_name"></a>

=head2 static to_file_name(string value) : string

Returns I<value> as a string that can be used as a part of filename.

=cut

sub to_file_name {
    my($proto, $value) = @_;
    my($sec, $min, $hour, $day, $mon, $year) = $proto->to_parts($value);
    return sprintf('%04d%02d%02d%02d%02d%02d', $year, $mon, $day,
	    $hour, $min, $sec);
}

=for html <a name="time_from_parts"></a>

=head2 time_from_parts(int sec, int min, int hour) : array

Returns the date/time value comprising the parts.  If there is an
error converting, returns undef and L<Bivio::TypeError|Bivio::TypeError>.

=cut

sub time_from_parts {
    my(undef, $sec, $min, $hour) = @_;
    return (undef, Bivio::TypeError::HOUR) if $hour > 23 || $hour < 0;
    return (undef, Bivio::TypeError::MINUTE) if $min > 59 || $min < 0;
    return (undef, Bivio::TypeError::SECOND) if $sec > 59 || $sec < 0;
    return $_DATE_PREFIX.(($hour * 60 + $min) * 60 + $sec);
}

=for html <a name="to_four_digit_year"></a>

=head2 to_four_digit_year(int year) : int

Returns a four digit year, if not already a four digit year.

Date windowing adjusts twenty years ahead of this year.

=cut

sub to_four_digit_year {
    my(undef, $year) = @_;
    return $year >= 100 ? $year
	    : $year + ($year > $_WINDOW_YEAR ? 1900 : 2000);
}

=for html <a name="to_local_string"></a>

=head2 static to_local_string(string value) : string

Converts to a human readable string in the local timezone.

=cut

sub to_local_string {
    my($proto, $date_time) = @_;
    return _to_string($proto, _adjust_to_local($date_time));
}

=for html <a name="to_parts"></a>

=head2 to_parts(string value) : array

Returns the date/time in parts in the same order as C<gmtime>
(sec, min, hour, mday, mon, year), but mday is one-based and
year is four digits.

Handles BOTH unix and date/time formats (for convenience).

=cut

sub to_parts {
    my(undef, $value) = @_;
    my($date, $time) = split(/\s+/, $value);

    # Unix time doesn't have a "$time" component
    return _localtime($value) unless defined($time);

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

=for html <a name="to_sql_value"></a>

=head2 to_sql_value(string place_holder) : string

Returns C<TO_DATE(I<place_holder>, 'J SSSSS')>.

=cut

sub to_sql_value {
    my(undef, $place_holder) = @_;
    return 'TO_DATE('.$place_holder.",'".SQL_FORMAT()."')";
}

=for html <a name="to_string"></a>

=head2 static to_string(string value) : string

Converts to a human readable string

=cut

sub to_string {
    my($proto, $date_time) = @_;
    return _to_string($proto, $date_time, 'GMT');
}

=for html <a name="to_unix"></a>

=head2 to_unix(string date_time) : int

Returns unix time or blows up if before epoch.

=cut

sub to_unix {
    my(undef, $date_time) = @_;
    my($date, $time) = split(/\s+/, $date_time);
    die($date, ': date before unix epoch')
	    if $date < UNIX_EPOCH_IN_JULIAN_DAYS();
    return ($date - UNIX_EPOCH_IN_JULIAN_DAYS()) * SECONDS_IN_DAY() + $time;
}

=for html <a name="to_xml"></a>

=head2 static to_xml(string value) : string

Converts to a XSL timeInstant (see
http://www.w3.org/TR/xmlschema-2/#timeInstant).
See also ISO 8601 (http://www.iso.ch/markete/8601.pdf).

=cut

sub to_xml {
    my($proto, $value) = @_;
    return '' unless defined($value);
    my($sec, $min, $hour, $mday, $mon, $year) = $proto->to_parts($value);
    return sprintf('%04d-%02d-%02dT%02d:%02d:%02dZ', $year, $mon, $mday,
	    $hour, $min, $sec);
}

#=PRIVATE METHODS

# _adjust_from_local(string value) : value
#
# Converts from local to GMT.
#
sub _adjust_from_local {
    my($value) = @_;
    my($tz) = _timezone();
    return $tz ? __PACKAGE__->add_seconds($value, $tz * 60) : $value;
}

# _adjust_to_local(string value) : value
#
# Subtracts timezone to get to local time.
#
sub _adjust_to_local {
    my($value) = @_;
    my($tz) = _timezone();
    return $tz ? __PACKAGE__->add_seconds($value, -$tz * 60) : $value;
}

# _compute_local_timezone()
#
# Computes the local timezone by using _localtime().
#
sub _compute_local_timezone {
    my($now) = time();
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

# _from_alert(proto, string value, string_ref res, Bivio::TypeError_ref $err) : boolean
#
# Returns true if it matches the pattern.  Parses alert format.
#
sub _from_alert {
    my($proto, $value, $res, $err) = @_;
    my($y, $mon, $d, $h, $m, $s) = $value =~ /^$_REGEX_ALERT$/o;
    return 0 unless defined($s);
    ($$res, $$err) = $proto->from_parts($s, $m, $h, $d, $mon, $y);
    return 1;
}


# _from_ctime(proto, string value, string_ref res, Bivio::TypeError_ref $err) : boolean
#
# Returns true if it matches the pattern.  Parses ctime format.
#
sub _from_ctime {
    my($proto, $value, $res, $err) = @_;
    my($mon, $d, $h, $m, $s, $y) = $value =~ /^$_REGEX_CTIME$/o;
    return 0 unless defined($y);
    $mon = $_MONTH{uc($mon)};
    if (defined($mon)) {
	($$res, $$err) = $proto->from_parts($s, $m, $h, $d, $mon, $y);
    }
    else {
	$$err = Bivio::TypeError::MONTH();
    }
    return 1;
}

# _from_literal(proto, string value, string_ref res, Bivio::TypeError_ref $err) : boolean
#
# Returns true if it matches the pattern.  Parses literal format.
#
sub _from_literal {
    my($proto, $value, $res, $err) = @_;
    my($date, $time) = $value =~ /^(\d+) (\d+)$/;
    return 0 unless defined($time);
    if (length($date) > length(LAST_DATE_IN_JULIAN_DAYS())
	    || $date < FIRST_DATE_IN_JULIAN_DAYS()
	    || $date > LAST_DATE_IN_JULIAN_DAYS()) {
	$$err = Bivio::TypeError::DATE_RANGE();
    }
    elsif (length($time) > length(SECONDS_IN_DAY())
	    || $time >= SECONDS_IN_DAY()) {
	$$err = Bivio::TypeError::TIME_RANGE();
    }
    else {
	$$res = $date.' '.$time;
    }
    return 1;
}

# _initialize()
#
# Initializes year and month tables.
#
sub _initialize {
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
    $_YEAR_BASE[0] = Bivio::Type::DateTime::FIRST_DATE_IN_JULIAN_DAYS();
    foreach my $y (Bivio::Type::DateTime::FIRST_YEAR()+1
	    ..Bivio::Type::DateTime::LAST_YEAR()) {
	my($yy) = $y - Bivio::Type::DateTime::FIRST_YEAR();
	$_IS_LEAP_YEAR[$yy] = ($y % 4 == 0 && ($y % 100 != 0 || $y == 2000))
		? 1 : 0;
	$_YEAR_BASE[$yy] = $_YEAR_BASE[$yy-1]
		+ ($_IS_LEAP_YEAR[$yy-1] ? 366 : 365);
    }
    my($i) = 1;
    %_MONTH = map {(uc($_), $i++)} @_MONTH;
    _compute_local_timezone();

    # Windowing year is always 20 years ahead of now.
    $_WINDOW_YEAR = int(((localtime)[5] + 20) % 100);
    return;
}

# _localtime(string unix_time) : array
#
# Returns the parts adjust for month and year.
#
sub _localtime {
    my($unix_time) = @_;
    my($sec, $min, $hour, $mday, $mon, $year) = localtime($unix_time);
    $mon++;
    $year += 1900;
    return ($sec, $min, $hour, $mday, $mon, $year);
}

# _timezone() : int
#
# Returns the timezone from the current request or returns undef.
#
sub _timezone {
    return $_LOCAL_TIMEZONE
	    unless UNIVERSAL::can('Bivio::Agent::Request', 'get_current');
    # We can't return something other than undef.
    my($req) = Bivio::Agent::Request->get_current;
    return $req ? $req->unsafe_get('timezone') : $_LOCAL_TIMEZONE;
}

# _to_string(proto, string value, string timezone) : string
#
# Does the work of to_string and to_local_string.
#
sub _to_string {
    my($proto, $date_time, $timezone) = @_;
    return '' unless defined($date_time);
    my($sec, $min, $hour, $mday, $mon, $year)
	    = $proto->to_parts($date_time);
    return sprintf('%02d/%02d/%04d %02d:%02d:%02d', $mon, $mday, $year,
	    $hour, $min, $sec).($timezone ? ' '.$timezone : '');
}

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
