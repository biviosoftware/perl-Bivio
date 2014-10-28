# Copyright (c) 1999-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::Date;
use strict;
use Bivio::Base 'Type.DateTime';

# C<Bivio::Type::Date> describes a date value which cannot have does not have a
# time component.  C<Date> is stored in the database as an SQL C<DATE> whose
# clock componentis 21:59:59 (GMT).  In perl, a date is represented as
# julian days and seconds on that day ('J SSSSS').

my($_DT) = b_use('Type.DateTime');
my($_DEFAULT_TIME) = __PACKAGE__->DEFAULT_TIME;
my($_MIN) = _to(__PACKAGE__, __PACKAGE__->FIRST_DATE_IN_JULIAN_DAYS);
my($_MAX) = _to(__PACKAGE__, __PACKAGE__->LAST_DATE_IN_JULIAN_DAYS);
#TODO: Assumes we are in the US.
my($_NOW_SLOP) = 9 * 60 * 60;

sub REGEX_FILE_NAME {
    return qr{(\d{4})(\d{2})(\d{2})};
}

sub TO_STRING_REGEX {
    return qr{(\d+/\d+/\d+)};
}

sub can_be_zero {
    return 0;
}

sub delta_days {
    my($proto, $start_date, $end_date) = @_;
    return ($proto->internal_split($end_date))[0]
        - ($proto->internal_split($start_date))[0];
}

sub delta_months {
    my($proto, $start_date, $end_date) = @_;
    return -$proto->delta_months($end_date, $start_date)
	if $proto->compare($start_date, $end_date) > 0;
    my(undef, undef, undef, $start_day, $start_month, $start_year)
	= $proto->to_parts($start_date);
    my(undef, undef, undef, $end_day, $end_month, $end_year)
	= $proto->to_parts($end_date);
    my($months) = 12 * ($end_year - $start_year)
	+ ($end_month - $start_month);
    $months--
	if $start_day > $end_day;
    return $months;
}

sub from_datetime {
    my($proto, $date_time) = @_;
    my($date, $time) = $proto->internal_split($date_time);
    my($v, $e) = $proto->SUPER::from_literal(_to($proto, $date));
    return ($v, $e)
	if $e;
    return $v;
}

sub from_literal {
    my($proto, $value) = @_;
    $proto->internal_from_literal_warning
        unless wantarray;
    return undef
	unless defined($value) && $value =~ /\S/;
    return _from_date_time($proto, $value, $1)
	if $value =~ /^\d+ (\d+)$/;
    $value =~ s/\s+//g;
    return $proto->date_from_parts($3, $2, $1)
	if $value =~ m{^(\d{4})[/-](\d+)[/-](\d+)$}s;
    return $proto->date_from_parts($2, $1, $3)
	if $value =~ m{^(\d+)[/-](\d+)[/-](\d{4})$}s;
    return $proto->date_from_parts($3, $2, $1)
	if $value =~ m{^(\d{4})(\d{2})(\d{2})$}s;
    return $proto->date_from_parts(
        $1,
	$proto->english_month3_to_int($2),
	$3,
    ) if $value =~ m{^(\d+)-([a-z]{3})-(\d{4})$}is;
    return $proto->date_from_parts($1, $2, $3)
	if $value =~ m{^(\d+)\.(\d+)\.(\d{4})$}s;
    return (undef, Bivio::TypeError->DATE);
}

sub from_sql_column {
    my($proto) = shift;
    my($value) = $proto->SUPER::from_sql_column(@_);
    b_die($value, ': invalid date in database (clock component)')
        if defined($value) && $value !~ /$_DEFAULT_TIME$/o;
    return $value;
}

sub from_unix {
    my($proto) = shift;
    return $proto->from_datetime($proto->SUPER::from_unix(@_));
}

sub get_default {
    my($self) = @_;
    return $self->now;
}

sub get_max {
    return $_MAX;
}

sub get_min {
    return $_MIN;
}

sub get_width {
    return 10;
}

sub local_today {
    my($proto) = @_;
    return _to(
	$proto,
	($proto->internal_split(
	    $proto->add_seconds($proto->SUPER::now, -$proto->timezone * 60),
	))[0],
    );
}

sub local_yesterday {
    my($proto) = @_;
    return $proto->add_days($proto->local_today, -1);
}

sub now {
    my($proto) = @_;
    return $proto->from_datetime($proto->SUPER::now);
}

sub to_file_name {
    my($proto, $value) = @_;
    my($sec, $min, $hour, $day, $mon, $year) = $proto->to_parts($value);
    return sprintf('%04d%02d%02d', $year, $mon, $day);
}

sub to_literal {
    my($proto, $value) = @_;
    return shift->SUPER::to_literal(@_)
	unless defined($value);
    my(undef, undef, undef, $d, $m, $y) = $proto->to_parts($value);
    return sprintf('%02d/%02d/%04d', $m, $d, $y);
}

sub to_sql_param {
    my(undef, $param_value) = @_;
    return undef
	unless defined($param_value);
    b_die($param_value, ': invalid date (clock component)')
	unless $param_value =~ /$_DEFAULT_TIME$/o;
    return $param_value;
}

sub to_string {
    return shift->to_literal(@_);
}

sub to_xml {
    my($proto, $value) = @_;
    # Converts to a XSL date (see
    # http://www.w3.org/TR/xmlschema-2/#date).
    # See also ISO 8601 (see http://www.iso.ch/markete/8601.pdf).
    return ''
	unless defined($value);
    my(undef, undef, undef, $mday, $mon, $year) = $proto->to_parts($value);
    return sprintf('%04d-%02d-%02d', $year, $mon, $mday);
}

sub _from_date_time {
    my($proto, $value, $time) = @_;
    my($v, $e) = $proto->SUPER::from_literal($value);
    return ($v, $e)
	if $e;
    return (undef, Bivio::TypeError->TIME_COMPONENT_OF_DATE)
	unless $time eq $_DEFAULT_TIME;
    return $v;
}

sub _to {
    my($proto, $julian) = @_;
    return $proto->internal_join($julian, $_DEFAULT_TIME);
}

1;
