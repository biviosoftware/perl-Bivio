# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::Date;
use strict;
use Bivio::Base 'Type.DateTime';

# C<Bivio::Type::Date> describes a date value which cannot have does not have a
# time component.  C<Date> is stored in the database as an SQL C<DATE> whose
# clock componentis 21:59:59 (GMT).  In perl, a date is represented as
# julian days and seconds on that day ('J SSSSS').

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = __PACKAGE__->use('Type.DateTime');
my($_TIME_SUFFIX) = ' '.Bivio::Type::DateTime::DEFAULT_TIME();
my($_MIN) = $_DT->FIRST_DATE_IN_JULIAN_DAYS().$_TIME_SUFFIX;
my($_MAX) = $_DT->LAST_DATE_IN_JULIAN_DAYS().$_TIME_SUFFIX;
#TODO: Assumes we are in the US.
my($_NOW_SLOP) = 9 * 60 * 60;

sub can_be_zero {
    # Returns false.
    return 0;
}

sub delta_days {
    my(undef, $start_date, $end_date) = @_;
    # Returns the number of days between two dates.
    my($start_days, undef) = split(/\s+/, $start_date);
    my($end_days, undef) = split(/\s+/, $end_date);
    return $end_days - $start_days;
}

sub delta_months {
    my($proto, $start_date, $end_date) = @_;
    # Returns the number of full months between start_date and end_date.

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

sub from_datetime {
    my($proto, $date_time) = @_;
    # Extracts date from C<Bivio::Type::DateTime> and returns C<Bivio::Type::Date>.
    my($date, $time) = split(' ', $date_time);
    my($v, $e) = Bivio::Type::DateTime->from_literal($date . ' ' . Bivio::Type::DateTime->DEFAULT_TIME);
    return ($v, $e) if $e;
    return $v;
}

sub from_literal {
    my($proto, $value) = @_;
    # Handles I<value> in mm/dd/yyyy, mm-dd-yyyy, yyyymmdd,
    # dd-mmm-yyyy or C<Bivio::Type::DateTime> format.
    $proto->internal_from_literal_warning
        unless wantarray;
#TODO: Improve the checks here
    return undef unless defined($value) && $value =~ /\S/;
    return _from_date_time($value, $1) if $value =~ /^\d+ (\d+)$/;
    # Get rid of all blanks to be nice to user
    $value =~ s/\s+//g;
    return Bivio::Type::DateTime->date_from_parts($3, $2, $1)
	if $value =~ m!^(\d{4})[/-](\d{2})[/-](\d{2})$!i;
    return Bivio::Type::DateTime->date_from_parts($2, $1, $3)
	if $value =~ m!^(\d+)[/-](\d+)[/-](\d+)$!i;
    return Bivio::Type::DateTime->date_from_parts($3, $2, $1)
	if $value =~ m!^(\d{4})(\d{2})(\d{2})$!i;
    return Bivio::Type::DateTime->date_from_parts(
        $1,
	Bivio::Type::DateTime->english_month3_to_int($2),
	$3,
    )
	if $value =~ m!^(\d{2})-(\w{3})-(\d{4})$!i;
    return (undef, Bivio::TypeError::DATE());
}

sub from_sql_column {
    my($proto) = shift;
    # Ensures the time component is valid.
    my($value) = $proto->SUPER::from_sql_column(@_);
    Bivio::Die->die($value, ': invalid date in database (clock component)')
        if defined($value) && $value !~ /$_TIME_SUFFIX$/o;
    return $value;
}

sub from_unix {
    my($proto, $unix_time) = @_;
    # Return date from unix time (interpreted in GMT).
    # Must be same truncation algorithm as Time::from_unix
    my($s) = int($unix_time % $proto->SECONDS_IN_DAY);
    my($j) = int(($unix_time - $s)
	    / $proto->SECONDS_IN_DAY
	    + $proto->UNIX_EPOCH_IN_JULIAN_DAYS);
    return $j.$_TIME_SUFFIX;
}

sub get_max {
    # Maximum date: 12/31/2199
    return $_MAX;
}

sub get_min {
    # Returns 1/1/1800.
    return $_MIN;
}

sub get_width {
    # Returns 10 for mm/dd/yyyy.
    return 10;
}

sub local_today {
    my($proto) = @_;
    # Returns date today relative to the current timezone.
    return (split(' ',
	$proto->add_seconds(
	    Bivio::Type::DateTime->now, -$proto->timezone * 60)))[0]
        .$_TIME_SUFFIX;
}

sub local_yesterday {
    my($proto) = @_;
    # Returns GMT date so it renders as yesterday local time.
    return $proto->add_days($proto->local_today, -1);
}

sub now {
    my($proto) = @_;
    return $proto->from_datetime($proto->SUPER::now);
}

sub to_file_name {
    my($proto, $value) = @_;
    # Returns I<value> as a string that can be used as a part of filename.
    my($sec, $min, $hour, $day, $mon, $year) = $proto->to_parts($value);
    return sprintf('%04d%02d%02d', $year, $mon, $day);
}

sub to_literal {
    my($proto, $value) = @_;
    # Converts the date part which is acceptable to from_literal.  Never returns
    # undef, always a string.
    return shift->SUPER::to_literal(@_)
	unless defined($value);
    my(undef, undef, undef, $d, $m, $y) = $proto->to_parts($value);
    return sprintf('%02d/%02d/%04d', $m, $d, $y);
}

sub to_sql_param {
    my(undef, $param_value) = @_;
    # Returns value which is acceptable
    # to a positional parameter generated by L<to_sql_value|"to_sql_value">.
    return undef unless defined($param_value);
    Bivio::Die->die($param_value, ': invalid date (clock component)')
		unless $param_value =~ /$_TIME_SUFFIX$/o;
    return $param_value;
}

sub to_string {
    # Returns L<to_literal|"to_literal">
    return shift->to_literal(@_);
}

sub to_xml {
    my($proto, $value) = @_;
    # Converts to a XSL date (see
    # http://www.w3.org/TR/xmlschema-2/#date).
    # See also ISO 8601 (see http://www.iso.ch/markete/8601.pdf).
    return '' unless defined($value);
    my(undef, undef, undef, $mday, $mon, $year) = $proto->to_parts($value);
    return sprintf('%04d-%02d-%02d', $year, $mon, $mday);
}

sub _from_date_time {
    my($value, $time) = @_;
    # Makes sure is a valid date time.
    my($v, $e) = Bivio::Type::DateTime->from_literal($value);
    return ($v, $e) if $e;
    return (undef, Bivio::TypeError->TIME_COMPONENT_OF_DATE)
	    unless $time eq Bivio::Type::DateTime->DEFAULT_TIME;
    return $v;
}

1;
