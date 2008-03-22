# Copyright (c) 1999-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::Number;
use strict;
use base 'Bivio::Type';
use GMP::Mpf ();

# C<Bivio::Type::Number> is the abstract base class for all number types.
# It provides arbitrary precision arithmetic for like-based numbers.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
# also uses Bivio::TypeError dynamically
my($_FUDGE) = _mpf('1e-20');
my($_HALF) = _mpf('0.5');
my($_POWER) = {};

sub abs {
    my($proto, $v) = @_;
    ($v = _format($proto, _mpf($v))) =~ s/^-//;
    return $v;
}

sub add {
    my($proto, $v, $v2, $decimals) = @_;
    # Adds two numbers and returns the result using the specified decimal precision.
    # If decimals is undef, then the default precision is used.
    return _format($proto,
        GMP::Mpf::overload_addeq(_mpf($v), _mpf($v2), 0), $decimals);
}

sub can_be_negative {
    my($proto) = @_;
    # Returns true if L<get_min|"get_min"> is less than 0.
    return $proto->compare($proto->get_min, 0) < 0 ? 1 : 0;
}

sub can_be_positive {
    my($proto) = @_;
    # Returns true if L<get_max|"get_max"> is greater than 0.
    return $proto->compare($proto->get_max, 0) > 0 ? 1 : 0;
}

sub can_be_zero {
    my($proto) = @_;
    # Returns true if range crosses through zero.
    return $proto->compare($proto->get_max, 0) >= 0
        && $proto->compare($proto->get_min, 0) <= 0 ? 1 : 0;
}

sub compare_defined {
    my($proto, $left, $right, $decimals) = @_;
    # See L<Bivio::Type::compare_defined|Bivio::Type/"compare_defined">.
    return _mpf($left) <=> _mpf($right);
}

sub div {
    my($proto, $v, $v2, $decimals) = @_;
    # Divides numerator by denominator and returns the result using the specified
    # decimal precision.
    #
    # Dies if dividing by 0.
    Bivio::Die->die('divide by zero: ', $v, '/', $v2)
        if ! defined($v2) || $v2 =~ /^[0.]+$/;
    return _format($proto,
        GMP::Mpf::overload_diveq(_mpf($v), _mpf($v2), 0), $decimals);
}

sub fraction_as_string {
    my($proto, $number, $decimals) = @_;
    # Returns the fractional part of I<number> up to decimals without
    # the leading decimal with rounding.  If I<decimals> is zero, always
    # returns the empty string.
    return '' if $decimals == 0;
    my($res) = $proto->round($number, $decimals);
    $res =~ s/.*\.//;
    return $res;
}

sub from_literal {
    my($proto, $value) = @_;
    # Makes sure is a number.  Does not except scientific notation.
    # Allows fractional values like "-7 11/15" or "32/3". Fractional
    # values are converted to decimal using the precision returned by
    # get_decimals().
    $proto->internal_from_literal_warning
        unless wantarray;
    return undef unless defined($value) && $value =~ /\S/;

    # Delete commas and dollar signs
    $value =~ s/[,\$\)]//g;

    # Replace parens with minus signs (remove dup minuses)
    $value =~ s/\(/-/g;
    $value =~ s/-+/-/g;

    my($parsed_value);

    # check for possible "i n/d" format
    if ($value =~ /\//) {
	# parse it and convert to decimal
	my($sign, $integer, $numerator, $denominator) =
		$value =~ /^([-+])?(\d+\s)?(\d+)\/(\d+)$/;
	if (defined($denominator) && $denominator != 0) {

	    $value = $proto->add($integer || 0,
		    $proto->div($numerator, $denominator));

	    if (defined($sign) && $sign eq '-') {
		$value = $proto->neg($value);
	    }
	    $parsed_value = $value;
	}
    }
    else {
	# Get rid of all blanks to be nice to user
	$value =~ s/\s+//g;
	$parsed_value = $value if $value =~ /^[-+]?(\d+\.?\d*|\.\d+)$/;
    }

    # not a number
    return (undef, Bivio::TypeError->NUMBER)
	    unless defined($parsed_value);

    # round to the acceptable number of decimals
    $parsed_value = $proto->round($parsed_value, $proto->get_decimals);

    # range check
    return $parsed_value
	    if $proto->compare($parsed_value, $proto->get_min) >= 0
		    && $proto->compare($parsed_value, $proto->get_max) <= 0;

    return (undef, Bivio::TypeError->NUMBER_RANGE);
}

sub get_decimals {
    # Abstract method to be defined by subclasses.
    die("abstract method");
}

sub max {
    my($proto, @values) = @_;
    return $proto->iterate_reduce(sub {
        my($v1, $v2) = @_;
	return $proto->compare($v1, $v2) > 0 ? $v1 : $v2;
    }, \@values);
}

sub min {
    my($proto, @values) = @_;
    return $proto->iterate_reduce(sub {
        my($v1, $v2) = @_;
	return $proto->compare($v1, $v2) < 0 ? $v1 : $v2;
    }, \@values);
}

sub mul {
    my($proto, $v, $v2, $decimals) = @_;
    # Multiplies two numbers and returns the result using the specified decimal
    # precision.
    # If decimals is undef, then the default precision is used.
    return _format($proto,
        GMP::Mpf::overload_muleq(_mpf($v), _mpf($v2), 0), $decimals);
}

sub neg {
    my($proto, $number) = @_;
    # Returns a number with the opposite sign from the specified one.
    return _format($proto, - _mpf($number));
}

sub round {
    my($proto, $number, $decimals) = @_;
    $decimals = _decimals($proto, $decimals);
    return _format($proto, _mpf($number), $decimals);
}

sub sign {
    my($proto, $number) = @_;
    # Returns -1, 0, +1 depending on the sign of number.
    my($sign) = $number =~ /^([-+])/;
    return $sign eq '-' ? -1 : 1 if defined($sign);
    return $proto->compare($number, 0) == 0 ? 0 : 1;
}

sub sub {
    my($proto, $v, $v2, $decimals) = @_;
    # Subtracts v2 from v and returns the result using the specified decimal
    # precision.
    # If decimals is undef, then the default precision is used.
    return _format($proto,
        GMP::Mpf::overload_subeq(_mpf($v), _mpf($v2), 0), $decimals);
}

sub sum {
    my($proto, @values) = @_;
    return $proto->iterate_reduce(sub {
        return $proto->add(@_);
    }, \@values);
}

sub to_literal {
    my($proto, $value) = @_;
    # Converts from internal form to a literal string value.
    return $proto->SUPER::to_literal($value)
	unless defined($value);

    # remove leading '+', replace '.1', '-.1' with '0.1', '-0.1' respectively
    $value =~ s/^\+//;
    $value =~ s/^\./0./;
    $value =~ s/^-\./-0./;

    # remove leading 0s
    $value =~ s/^0+(\d)/$1/;

    # remove trailing 0s after decimal point
    $value =~ s/^(.*\..+?)(0+)$/$1/
        unless $value =~ s/\.0*$//;
    return $value;
}

sub trunc {
    my($proto, $number, $decimals) = @_;
    $decimals = _decimals($proto, $decimals);
    my($pow) = 10 ** $decimals;
    return return _format($proto, GMP::Mpf::trunc($number * $pow) / $pow,
        $decimals);
}

sub _decimals {
    my($proto, $decimals) = @_;
    $decimals = $proto->get_decimals
        unless defined($decimals);
    Bivio::Die->die('invalid decimals: ', $decimals)
        if $decimals < 0;
    return $decimals;
}

sub _format {
    my($proto, $v, $decimals) = @_;
    # Formats the amount, rounded to the specified number of decimals.
    $decimals = $proto->get_decimals
        unless defined($decimals);
    # add in a fudge factor for for values such as 0.07 which is represented
    # internally as 0.0699999..., so floor() works correctly.
    # Mpf seems to always use the lower value, so not needed for negatives
    $v += $_FUDGE if $v > 0;
    # round towards +inf
    my($pow) = $_POWER->{$decimals} ||= 10 ** $decimals;
    return GMP::sprintf('%.' . $decimals . 'f',
       GMP::Mpf::floor($v * $pow + $_HALF) / $pow);
}

sub _mpf {
    my($value) = @_;
    # Returns a GMP::Mpf value for the specified string value.

    unless (defined($value)) {
        Bivio::IO::Alert->warn_deprecated(
            'numeric amount not defined, defaulting to 0');
        $value = 0;
    }
    # leading + and commas not accepted by GMP
    $value =~ s/^\+//;
    $value =~ s/\,//g;
    # the empty concatenation is very important because it forces values
    # passed as floats, such as 0.03 which is represented inexactly
    # to become the literal '0.03' which can be more closely
    # represented by Mpf (using 500 bits of precision)
    return GMP::Mpf::mpf($value . '', 500);
}

1;
