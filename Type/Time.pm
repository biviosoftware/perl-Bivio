# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::Time;
use strict;
$Bivio::Type::Time::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::Time - describes the type time without a calendar value

=head1 SYNOPSIS

    use Bivio::Type::Time;

=cut

=head1 EXTENDS

L<Bivio::Type::DateTime>

=cut

use Bivio::Type::DateTime;
@Bivio::Type::Time::ISA = qw(Bivio::Type::DateTime);

=head1 DESCRIPTION

C<Bivio::Type::Time> describes a time value which cannot have
does not have a date component.  C<Time> is stored in the
database as an SQL C<DATE> whose calendar component is
L<Bivio::Type::DateTime::FIRST_DATE_IN_JULIAN_DAYS|Bivio::Type::DateTime::FIRST_DATE_IN_JULIAN_DAYS>.
In perl, a date is represented as
julian days and seconds on that day ('J SSSSS').

=cut

#=IMPORTS

#=VARIABLES
my($_DATE_PREFIX) = Bivio::Type::DateTime::FIRST_DATE_IN_JULIAN_DAYS().' ';
my($_MAX) = $_DATE_PREFIX.(Bivio::Type::DateTime::SECONDS_IN_DAY()-1);

=head1 METHODS

=cut

=for html <a name="from_literal"></a>

=head2 static from_literal(string value) : array

Convert from the following formats: h:m:s or h:m:s am, etc.

=cut

sub from_literal {
    my($proto, $value) = @_;
    $proto->internal_from_literal_warning
        unless wantarray;
#TODO: Improve the checks here
    return undef unless defined($value) && $value =~ /\S/;
    # Get rid of all blanks to be nice to user
    $value =~ s/\s+//g;
    return (undef, Bivio::TypeError->TIME) unless
	    $value =~ m!^(\d+):(\d+)(?::(\d+))?(?:([ap])(?:|m|\.m\.))?$!i;
    my($h, $m, $s, $am_pm) = ($1, $2, $3, $4);
    $s = 0 unless defined($s);
    if (defined($am_pm)) {
	return (undef, Bivio::TypeError->HOUR) if $h > 12;
	if ($h == 12) {
	    # 12 a.m is really 0 o'clock
	    $h = 0 if $am_pm eq 'a';
	}
	else {
	    # 12:\d+ p.m. is noon, not midnight
	    $h += 12 if $am_pm eq 'p';
	}
    }
    else {
	if ($h > 23) {
	    # 24:0:0 is allowed
	    return (undef, Bivio::TypeError->HOUR) if $h > 24
		    || $m + $s > 0;
	    $h = 0;
	}
    }
    return Bivio::Type::DateTime->time_from_parts($s, $m, $h);
}

=for html <a name="from_unix"></a>

=head2 from_unix(int unix_time) : string

Returns the clock component of I<unix_time> interpreted in GMT.

=cut

sub from_unix {
    my(undef, $unix_time) = @_;
    # Must be same truncation algorithm as Date::from_unix
    my($s) = int($unix_time % Bivio::Type::DateTime::SECONDS_IN_DAY());
    return $_DATE_PREFIX.$s;
}

=for html <a name="get_max"></a>

=head2 get_max() : int

Seconds in day minus one.

=cut

sub get_max {
    return $_MAX;
}

=for html <a name="get_width"></a>

=head2 static get_width : int

Returns 13 for hh:mm:ss a.m.

=cut

sub get_width {
    return 13;
}

=for html <a name="now"></a>

=head2 now() : string

Returns time with DEFAULT_DATE for now.

=cut

sub now {
    return shift->from_unix(time);
}

=for html <a name="to_literal"></a>

=head2 to_literal(any value) : string

Converts the time part which is acceptable to from_literal.  Never returns
undef, always a string.

=cut

sub to_literal {
    my($proto, $value) = @_;
    return '' unless defined($value);
    my($s, $m, $h) = $proto->to_parts($value);
    return sprintf('%02d:%02d:%02d', $h, $m, $s);
}

=for html <a name="to_sql_param"></a>

=head2 to_sql_param(string param_value) : string

Returns value which is acceptable
to a positional parameter generated by L<to_sql_value|"to_sql_value">.

=cut

sub to_sql_param {
    my(undef, $param_value) = @_;
    return undef unless defined($param_value);
    Bivio::Die->die($param_value, ': invalid time (date component)')
	    unless $param_value =~ /^$_DATE_PREFIX/o;
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

Converts to a XSL time (see
http://www.w3.org/TR/xmlschema-2/#time).
See also ISO 8601 (see http://www.iso.ch/markete/8601.pdf).

=cut

sub to_xml {
    my($proto, $value) = @_;
    return '' unless defined($value);
    my($sec, $min, $hour) = $proto->to_parts($value);
    return sprintf('%02d:%02d:%02dZ', $hour, $min, $sec);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
