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
clock componentis 21:59:59 (GMT).  In perl, a date is represented as the number
of seconds since the unix epoch.

=cut


#=IMPORTS
use Time::Local;

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
    my($m, $d, $y) = ($1, $2, $3);
    return (undef, Bivio::TypeError::DATE_RANGE())
	    unless 1970 <= $y && $y <= 2037;
    return (undef, Bivio::TypeError::MONTH()) unless 1 <= $m && $m <= 12;
    my($time) = Time::Local::timegm(0, 0, 0, $d, --$m, $y);
    return (undef, Bivio::TypeError::DAY_OF_MONTH())
	    unless $d == (gmtime($time))[3];
    return $time + Bivio::Type::DateTime::DEFAULT_TIME();
}

=for html <a name="get_max"></a>

=head2 get_max() : int

Maximum date: Jan 19 I<DEFAULT_TIME> 2038 GMT.

=cut

sub get_max {
    return 2147472000 + Bivio::Type::DateTime::DEFAULT_TIME();
}

=for html <a name="get_min"></a>

=head2 get_min() : int

Returns 0.

=cut

sub get_min {
    return Bivio::Type::DateTime::DEFAULT_TIME();
}

=for html <a name="get_width"></a>

=head2 static get_width : int

Returns 10 for mm/dd/yyyy.

=cut

sub get_width {
    return 10;
}

=for html <a name="to_sql_param"></a>

=head2 to_sql_param(string param_value) : string

Returns string form of unix time (integer) which is acceptable
to a positional parameter generated by L<to_sql_value|"to_sql_value">.

=cut

sub to_sql_param {
    my(undef, $param_value) = @_;
    return undef unless defined($param_value);
    Carp::croak("$param_value: invalid date (clock component)")
		if $param_value % Bivio::Type::DateTime::SECONDS_IN_DAY()
			!= Bivio::Type::DateTime::DEFAULT_TIME();
    return Bivio::Type::DateTime->to_sql_param($param_value);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
