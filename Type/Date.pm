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

=for html <a name="get_days_between"></a>

=head2 get_days_between(string date, string date2) : int

Returns the number of days between two dates.

=cut

sub get_days_between {
    my(undef, $date, $date2) = @_;
    my($days, undef) = split(/\s+/, $date);
    my($days2, undef) = split(/\s+/, $date2);
    return $days2 - $days;
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

=for html <a name="now"></a>

=head2 now() : string

Returns date with DEFAULT_TIME for now.

=cut

sub now {
    my($unix_time) = time;
    my($s) = int($unix_time % Bivio::Type::DateTime::SECONDS_IN_DAY() + 0.5);
    my($j) = int(($unix_time - $s - $_NOW_SLOP)
	    / Bivio::Type::DateTime::SECONDS_IN_DAY())
	    + Bivio::Type::DateTime::UNIX_EPOCH_IN_JULIAN_DAYS();
    return $j.$_TIME_SUFFIX;
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
