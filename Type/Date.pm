# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::Date;
use strict;
$Bivio::Type::Date::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::Date::VERSION;

=head1 NAME

Bivio::Type::Date - describes the type date without a clock component

=head1 RELEASE SCOPE

bOP

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
my($_MIN) = Bivio::Type::DateTime::FIRST_DATE_IN_JULIAN_DAYS().$_TIME_SUFFIX;
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

=for html <a name="from_datetime"></a>

=head2 static from_datetime(string date_time) : array

Extracts date from C<Bivio::Type::DateTime> and returns C<Bivio::Type::Date>.

=cut

sub from_datetime {
    my($proto, $date_time) = @_;
    my($date, $time) = split(' ', $date_time);
    my($v, $e) = Bivio::Type::DateTime->from_literal($date . ' ' . Bivio::Type::DateTime->DEFAULT_TIME);
    return ($v, $e) if $e;
    return $v;
}

=for html <a name="from_literal"></a>

=head2 static from_literal(string value) : array

Handles I<value> in mm/dd/yyyy, mm-dd-yyyy, yyyymmdd,
dd-mmm-yyyy or C<Bivio::Type::DateTime> format.

=cut

sub from_literal {
    my($proto, $value) = @_;
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

=head2 from_sql_column(string result) : string

Ensures the time component is valid.

=cut

sub from_sql_column {
    my($proto) = shift;
    my($value) = $proto->SUPER::from_sql_column(@_);
    Bivio::Die->die($value, ': invalid date in database (clock component)')
        if defined($value) && $value !~ /$_TIME_SUFFIX$/o;
    return $value;
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

=head2 static local_today() : string

Returns date today relative to the current timezone.

=cut

sub local_today {
    my($proto) = @_;
    return (split(' ',
	$proto->add_seconds(
	    Bivio::Type::DateTime->now, -$proto->timezone * 60)))[0]
        .$_TIME_SUFFIX;
}

=for html <a name="local_yesterday"></a>

=head2 static local_yesterday() : string

Returns GMT date so it renders as yesterday local time.

=cut

sub local_yesterday {
    my($proto) = @_;
    return $proto->add_days($proto->local_today, -1);
}

=for html <a name="now"></a>

=head2 static  now() : string

Returns date with DEFAULT_TIME for now.

=cut

sub now {
    return shift->from_unix(time);
}

=for html <a name="to_file_name"></a>

=head2 static to_file_name(string value) : string

Returns I<value> as a string that can be used as a part of filename.

=cut

sub to_file_name {
    my($proto, $value) = @_;
    my($sec, $min, $hour, $day, $mon, $year) = $proto->to_parts($value);
    return sprintf('%04d%02d%02d', $year, $mon, $day);
}

=for html <a name="to_literal"></a>

=head2 to_literal(any value) : string

Converts the date part which is acceptable to from_literal.  Never returns
undef, always a string.

=cut

sub to_literal {
    my($proto, $value) = @_;
    return shift->SUPER::to_literal(@_)
	unless defined($value);
    my(undef, undef, undef, $d, $m, $y) = $proto->to_parts($value);
    return sprintf('%02d/%02d/%04d', $m, $d, $y);
}

=for html <a name="to_sql_param"></a>

=head2 to_sql_param(string param_value) : string

Returns value which is acceptable
to a positional parameter generated by L<to_sql_value|"to_sql_value">.

=cut

sub to_sql_param {
    my(undef, $param_value) = @_;
    return undef unless defined($param_value);
    Bivio::Die->die($param_value, ': invalid date (clock component)')
		unless $param_value =~ /$_TIME_SUFFIX$/o;
    return $param_value;
}

=for html <a name="to_string"></a>

=head2 static to_string(any value) : string

Returns L<to_literal|"to_literal">

=cut

sub to_string {
    return shift->to_literal(@_);
}

=for html <a name="to_xml"></a>

=head2 static to_xml(string value) : string

Converts to a XSL date (see
http://www.w3.org/TR/xmlschema-2/#date).
See also ISO 8601 (see http://www.iso.ch/markete/8601.pdf).

=cut

sub to_xml {
    my($proto, $value) = @_;
    return '' unless defined($value);
    my(undef, undef, undef, $mday, $mon, $year) = $proto->to_parts($value);
    return sprintf('%04d-%02d-%02d', $year, $mon, $mday);
}

#=PRIVATE METHODS

# _from_date_time(string value, string time) : string
#
# Makes sure is a valid date time.
#
sub _from_date_time {
    my($value, $time) = @_;
    my($v, $e) = Bivio::Type::DateTime->from_literal($value);
    return ($v, $e) if $e;
    return (undef, Bivio::TypeError->TIME_COMPONENT_OF_DATE)
	    unless $time eq Bivio::Type::DateTime->DEFAULT_TIME;
    return $v;
}

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
