# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::Date;
use strict;
$Bivio::Type::Date::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::Date - describes the type date without a clock component

=head1 SYNOPSIS

    use Bivio::Type::Date;

=cut

=head1 EXTENDS

L<Bivio::Type::DateTime>

=cut

use Bivio::Type::DateTime;
@Bivio::Type::Date::ISA = qw(Bivio::Type::DateTime);

=head1 DESCRIPTION

C<Bivio::Type::Date> describes a date value which cannot have does not have a
time component.  C<Date> is stored in the database as an SQL C<DATE> whose
clock componentis 21:59:59 (GMT).  In perl, a date is represented as
julian days and seconds on that day ('J SSSSS').

=cut

#=IMPORTS

#=VARIABLES
my($_TIME_SUFFIX) = ' '.Bivio::Type::DateTime::DEFAULT_TIME();
my($_MIN) = Bivio::Type::DateTime::FIRST_YEAR_IN_JULIAN_DAYS().$_TIME_SUFFIX;
my($_MAX) = Bivio::Type::DateTime::LAST_DATE_IN_JULIAN_DAYS().$_TIME_SUFFIX;
#TODO: Assumes we are in the US.
my($_NOW_SLOP) = 9 * 60 * 60;

=head1 METHODS

=cut

=for html <a name="can_be_zero"></a>

=head2 static can_be_zero : boolean

Returns false.

=cut

sub can_be_zero {
    return 0;
}

=for html <a name="delta_days"></a>

=head2 delta_days(string start_date, string end_date) : int

Returns the number of days between two dates.

=cut

sub delta_days {
    my(undef, $start_date, $end_date) = @_;
    my($start_days, undef) = split(/\s+/, $start_date);
    my($end_days, undef) = split(/\s+/, $end_date);
    return $end_days - $start_days;
}

=for html <a name="delta_months"></a>

=head2 static delta_months(string start_date, string end_date) : int

Returns the number of full months between start_date and end_date.

=cut

sub delta_months {
    my($proto, $start_date, $end_date) = @_;

    if ($proto->compare($start_date, $end_date) > 0) {
	return - $proto->delta_months($end_date, $start_date);
    }

    my(undef, undef, undef, $start_day, $start_month, $start_year) =
	    $proto->to_parts($start_date);
    my(undef, undef, undef, $end_day, $end_month, $end_year) =
	    $proto->to_parts($end_date);

    # year * 12
    my($months) = 12 * ($end_year - $start_year);

    # months difference
    $months += ($end_month - $start_month);

    # subtract 1 month if days difference
    $months-- if ($start_day > $end_day);

    return $months;
}

=for html <a name="from_literal"></a>

=head2 static from_literal(string value) : array

Makes sure is in mm/dd/yyyy format.

=cut

sub from_literal {
    my(undef, $value) = @_;
#TODO: Improve the checks here
    return undef unless defined($value) && $value =~ /\S/;
    # Get rid of all blanks to be nice to user
    $value =~ s/\s+//g;
    return (undef, Bivio::TypeError::DATE())
	    unless $value =~ m!^(\d+)/(\d+)/(\d+)$!i;
    return Bivio::Type::DateTime->date_from_parts($2, $1, $3);
}

=for html <a name="from_unix"></a>

=head2 from_unix(int unix_time) : string

Return date from unix time (interpreted in GMT).

=cut

sub from_unix {
    my(undef, $unix_time) = @_;
    # Must be same truncation algorithm as Time::from_unix
    my($s) = int($unix_time % Bivio::Type::DateTime::SECONDS_IN_DAY());
    my($j) = int(($unix_time - $s)
	    / Bivio::Type::DateTime::SECONDS_IN_DAY())
	    + Bivio::Type::DateTime::UNIX_EPOCH_IN_JULIAN_DAYS();
    return $j.$_TIME_SUFFIX;
}

=for html <a name="get_max"></a>

=head2 get_max() : string

Maximum date: 12/31/2199

=cut

sub get_max {
    return $_MAX;
}

=for html <a name="get_min"></a>

=head2 get_min() : string

Returns 1/1/1800.

=cut

sub get_min {
    return $_MIN;
}

=for html <a name="get_width"></a>

=head2 static get_width : int

Returns 10 for mm/dd/yyyy.

=cut

sub get_width {
    return 10;
}

=for html <a name="local_today"></a>

=head2 local_today() : string

Returns GMT date so it renders as today local time.

=cut

sub local_today {
    my(undef) = @_;
    # Use DateTime, not Date's now
    my($date, $time) = split(' ', Bivio::Type::DateTime->now);
    my($req) = Bivio::Agent::Request->get_current;
    my($tz) = $req->unsafe_get('timezone');

    return $date.$_TIME_SUFFIX unless defined($tz);
    # The timezone is really a timezone offset for now.  This will
    # have to be fixed someday, but not right now.
    $tz *= 60;

    # First figure out what the day is
    $time -= $tz;
    if ($time < 0) {
	$date--;
    }
    elsif ($time >= Bivio::Type::DateTime::SECONDS_IN_DAY()) {
	$date++;
    }
    return $date.$_TIME_SUFFIX;
}

=for html <a name="now"></a>

=head2 now() : string

Returns date with DEFAULT_TIME for now.

=cut

sub now {
    return shift->from_unix(time);
}

=for html <a name="to_literal"></a>

=head2 to_literal(any value) : string

Converts the date part which is acceptable to from_literal.  Never returns
undef, always a string.

=cut

sub to_literal {
    my($proto, $value) = @_;
    return '' unless defined($value);
    my(undef, undef, undef, $d, $m, $y) = $proto->to_parts($value);
    return sprintf('%02d/%02d/%04d', $m, $d, $y);
}

=for html <a name="to_local_date"></a>

=head2 to_local_date(string date_time) : string

Converts a date time to the most recent date boundary.

=cut

sub to_local_date {
    my(undef, $date_time) = @_;
    my($date, $time) = split(' ', $date_time);
    if ($time < Bivio::Type::DateTime::DEFAULT_TIME()) {
	$date--;
    }
    return $date.' '.Bivio::Type::DateTime::DEFAULT_TIME();
}

=for html <a name="to_sql_param"></a>

=head2 to_sql_param(string param_value) : string

Returns value which is acceptable
to a positional parameter generated by L<to_sql_value|"to_sql_value">.

=cut

sub to_sql_param {
    my(undef, $param_value) = @_;
    return undef unless defined($param_value);
    Carp::croak("$param_value: invalid date (clock component)")
		unless $param_value =~ /$_TIME_SUFFIX$/o;
    return $param_value;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
