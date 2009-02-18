# Copyright (c) 1999-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::Time;
use strict;
use Bivio::Base 'Type.DateTime';

# C<Bivio::Type::Time> describes a time value which cannot have
# does not have a date component.  C<Time> is stored in the
# database as an SQL C<DATE> whose calendar component is
# L<Bivio::Type::DateTime::FIRST_DATE_IN_JULIAN_DAYS|Bivio::Type::DateTime::FIRST_DATE_IN_JULIAN_DAYS>.
# In perl, a date is represented as
# julian days and seconds on that day ('J SSSSS').

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DATE_PREFIX) = __PACKAGE__->FIRST_DATE_IN_JULIAN_DAYS . ' ';
my($_MAX) = $_DATE_PREFIX . (__PACKAGE__->SECONDS_IN_DAY - 1);

sub from_datetime {
    my($proto, $date_time) = @_;
    # Extracts date from C<Bivio::Type::DateTime> and returns C<Bivio::Type::Time>.
    my($date, $time) = split(' ', $date_time);
    my($v, $e) = $proto->SUPER::from_literal($proto->DEFAULT_DATE . ' ' . $time);
    return ($v, $e) if $e;
    return $v;
}

sub from_literal {
    my($proto, $value) = @_;
    # Convert from the following formats: h:m:s or h:m:s am, etc.
    $proto->internal_from_literal_warning
        unless wantarray;
    return (undef, undef)
	unless defined($value) && $value =~ /\S/;
    $value =~ s/\s+//g;
    return (undef, Bivio::TypeError->TIME) unless
	$value =~ m{^(\d{1,2})(?::(\d{1,2}))?(?::(\d{1,2}))?(?:([ap])(?:|m|\.m\.))?$}i
	|| $value =~ m{^(\d{2})(\d{2})(?:(\d{2})?)$};
    my($h, $m, $s, $am_pm) = ($1, $2, $3, $4);
    $s = 0 unless defined($s);
    $m = 0 unless defined($m);
    if (defined($am_pm)) {
	return (undef, Bivio::TypeError->HOUR) if $h > 12;
	if ($h == 12) {
	    # 12 a.m is really 0 o'clock
	    $h = 0 if lc($am_pm) eq 'a';
	}
	else {
	    # 12:\d+ p.m. is noon, not midnight
	    $h += 12 if lc($am_pm) =~ 'p';
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
    return $proto->time_from_parts($s, $m, $h);
}

sub from_unix {
    my($proto, $unix_time) = @_;
    # Returns the clock component of I<unix_time> interpreted in GMT.
    # Must be same truncation algorithm as Date::from_unix
    my($s) = int($unix_time % $proto->SECONDS_IN_DAY);
    return $_DATE_PREFIX.$s;
}

sub get_max {
    # Seconds in day minus one.
    return $_MAX;
}

sub get_width {
    # Returns 13 for hh:mm:ss a.m.
    return 13;
}

sub now {
    my($proto) = @_;
    return $proto->from_unix($proto->to_unix($proto->SUPER::now));
}

sub to_literal {
    my($proto, $value) = @_;
    # Converts the time part which is acceptable to from_literal.  Never returns
    # undef, always a string.
    return $proto->SUPER::to_literal(@_)
	unless defined($value);
    my($s, $m, $h) = $proto->to_parts($value);
    return sprintf('%02d:%02d' . ($s ? ':%02d' : ''), $h, $m, $s ? $s : ());
}

sub to_sql_param {
    my(undef, $param_value) = @_;
    # Returns value which is acceptable
    # to a positional parameter generated by L<to_sql_value|"to_sql_value">.
    return undef unless defined($param_value);
    Bivio::Die->die($param_value, ': invalid time (date component)')
	    unless $param_value =~ /^$_DATE_PREFIX/o;
    return $param_value;
}

sub to_string {
    # Returns L<to_literal|"to_literal">
    return shift->to_literal(@_);
}

sub to_xml {
    my($proto, $value) = @_;
    # Converts to a XSL time (see
    # http://www.w3.org/TR/xmlschema-2/#time).
    # See also ISO 8601 (see http://www.iso.ch/markete/8601.pdf).
    return '' unless defined($value);
    my($sec, $min, $hour) = $proto->to_parts($value);
    return sprintf('%02d:%02d:%02dZ', $hour, $min, $sec);
}

1;
