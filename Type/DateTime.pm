# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::DateTime;
use strict;
$Bivio::Type::DateTime::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::DateTime - base class for all date/time types and type in itself

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

Returns L<FIRST_YEAR_IN_JULIAN_DAYS|"FIRST_YEAR_IN_JULIAN_DAYS">.
Used when there is only a time value.  See
L<Bivio::Type::Time|Bivio::Type::Time>.

=cut

sub DEFAULT_DATE {
    return FIRST_YEAR_IN_JULIAN_DAYS();
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

=for html <a name="FIRST_YEAR"></a>

=head2 FIRST_YEAR : int

Returns 1800.

=cut

sub FIRST_YEAR {
    return 1800;
}

=for html <a name="FIRST_YEAR_IN_JULIAN_DAYS"></a>

=head2 FIRST_YEAR_IN_JULIAN_DAYS : int

Returns 2378497.

=cut

sub FIRST_YEAR_IN_JULIAN_DAYS {
    return 2378497;
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
use Bivio::TypeError;

#=VARIABLES
my($_MIN) = FIRST_YEAR_IN_JULIAN_DAYS().' 0';
my($_MAX) = LAST_DATE_IN_JULIAN_DAYS().' '.(SECONDS_IN_DAY() - 1);
# Is this year (- FIRST_YEAR) a leap year?  Returns 0 or 1.
my(@_IS_LEAP_YEAR);
# First index is "is_leap_year", next is month - 1.
# Returns days in month and days in year up to month.
my(@_MONTH_DAYS, @_MONTH_BASE);
# Index is year - FIRST_YEAR.  Returns number of days up to this year.
my(@_YEAR_BASE);
my($_TIME_SUFFIX) = ' '.DEFAULT_TIME();
my($_DATE_PREFIX) = FIRST_YEAR_IN_JULIAN_DAYS().' ';
my($_END_OF_DAY) = SECONDS_IN_DAY()-1;
my(@_DOW) = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat');
my(@_MONTH) = ('Jan','Feb','Mar','Apr','May','Jun',
	'Jul','Aug','Sep','Oct','Nov','Dec');
_initialize();

=head1 METHODS

=cut

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

=for html <a name="get_previous_day"></a>

=head2 static get_previous_day(string date) : string

Returns the date value for the day previous to the specified date.

=cut

sub get_previous_day {
    my($proto, $date) = @_;
    my($j, $s) = split(' ', $date);
    return ($j - 1) . ' ' . $s;
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

=for html <a name="now"></a>

=head2 now() : string

Returns date/time for now.

=cut

sub now {
    return from_unix(__PACKAGE__, time);
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
    my(undef, $date_time) = @_;
    my($date, $time) = split(' ', $date_time);
    my($req) = Bivio::Agent::Request->get_current;
    my($tz) = $req->unsafe_get('timezone');

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

=for html <a name="date_from_parts"></a>

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

=for html <a name="from_literal"></a>

=head2 static from_literal(string value) : array

Makes sure is a unsigned number.

=cut

sub from_literal {
    my($proto, $value) = @_;
    return undef unless defined($value) && $value =~ /\S/;
    # Get rid of all blanks to be nice to user
    return (undef, Bivio::TypeError::DATE_TIME())
	    unless $value =~ /^\s*(\d+)\s+(\d+)\s*$/;
    $value = "$1 $2";
    # Compare as strings for date range, because don't want integer
    # conversion to wrap
#    return (undef, Bivio::TypeError::NUMBER_RANGE())
#	    unless length($value) < $proto->get_width
#		    || $value le $proto->get_max;
    return $value;
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

=for html <a name="to_parts"></a>

=head2 to_parts(string value) : array

Returns the date/time in parts in the same order as C<gmtime>.

Handles BOTH unix and date/time formats (for convenience).

=cut

sub to_parts {
    my(undef, $value) = @_;
    my($date, $time) = split(/\s+/, $value);

    # Unix time doesn't have a "$time" component
    unless (defined($time)) {
	my($sec, $min, $hour, $mday, $mon, $year) = localtime($value);
	$year += 1900;
	$mon++;
	return ($sec, $min, $hour, $mday, $mon, $year);
    }

    # Parse time component
    my($sec) = int($time % 60 + 0.5);
    $time = int(($time - $sec)/ 60 + 0.5);
    my($min) = int($time % 60 + 0.5);
    my($hour) = int(($time - $min)/ 60 + 0.5);

    # Search for $date in julian tables
    my($exact, $i) = Bivio::Util::bsearch_numeric($date, \@_YEAR_BASE);
    my($year) = FIRST_YEAR() + $i;
    return ($sec, $min, $hour, 1, 1, $year) if $exact;

    # Make sure within range
    if ($i == 0) {
	Carp::croak("$value: time less than first year")
		    if FIRST_YEAR_IN_JULIAN_DAYS > $date;
    }
    elsif ($i >= $#_YEAR_BASE) {
	Carp::croak("$value: time greater than last year")
		    if LAST_DATE_IN_JULIAN_DAYS() < $date;
    }

    # Adjust year if base is after $date
    $year--, $i-- if $_YEAR_BASE[$i] > $date;
    $date -= $_YEAR_BASE[$i];
    my($month_base) = $_MONTH_BASE[$_IS_LEAP_YEAR[$i]];

    # Search for month (always in range)
    ($exact, $i) = Bivio::Util::bsearch_numeric($date, $month_base);
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
    return '' unless defined($date_time);
    my($sec, $min, $hour, $mday, $mon, $year)
	    = $proto->to_parts($date_time);
    return sprintf('%02d/%02d/%04d %02d:%02d:%02d GMT', $mon, $mday, $year,
	    $hour, $min, $sec);
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
    $_YEAR_BASE[0] = Bivio::Type::DateTime::FIRST_YEAR_IN_JULIAN_DAYS();
    foreach my $y (Bivio::Type::DateTime::FIRST_YEAR()+1
	    ..Bivio::Type::DateTime::LAST_YEAR()) {
	my($yy) = $y - Bivio::Type::DateTime::FIRST_YEAR();
	$_IS_LEAP_YEAR[$yy] = ($y % 4 == 0 && ($y % 100 != 0 || $y == 2000))
		? 1 : 0;
	$_YEAR_BASE[$yy] = $_YEAR_BASE[$yy-1]
		+ ($_IS_LEAP_YEAR[$yy-1] ? 366 : 365);
    }
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
