# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Type::Number;
use strict;
$Bivio::Type::Number::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::Number::VERSION;

=head1 NAME

Bivio::Type::Number - base class for all number types

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::Number;

=cut

=head1 EXTENDS

L<Bivio::Type>

=cut

use Bivio::Type;
@Bivio::Type::Number::ISA = qw(Bivio::Type);

=head1 DESCRIPTION

C<Bivio::Type::Number> is the abstract base class for all number types.
It provides arbitrary precision arithmetic for like-based numbers.

=cut

#=IMPORTS
# also uses Bivio::TypeError dynamically
use Bivio::IO::ClassLoader;
use Math::BigInt ();

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="abs"></a>

=head2 static abs(string v) : string

Converts a negative into a positive number.

=cut

sub abs {
    my(undef, $v) = @_;
    $v =~ s/^-//;
    return $v;
}

=head2 static add(string v, string v2, int decimals) : string

Adds two numbers and returns the result using the specified decimal precision.
If decimals is undef, then the default precision is used.

=cut

sub add {
    my($proto, $v, $v2, $decimals) = @_;

    return _math_op('badd', $v, $v2,
	    defined($decimals) ? $decimals : $proto->get_decimals());
}

=for html <a name="can_be_negative"></a>

=head2 static can_be_negative : boolean

Returns true if L<get_min|"get_min"> is less than 0.

=cut

sub can_be_negative {
    my($proto) = @_;
    return $proto->compare($proto->get_min, 0) < 0 ? 1 : 0;
}

=for html <a name="can_be_positive"></a>

=head2 static can_be_positive : boolean

Returns true if L<get_max|"get_max"> is greater than 0.

=cut

sub can_be_positive {
    my($proto) = @_;
    return $proto->compare($proto->get_max, 0) > 0 ? 1 : 0;
}

=for html <a name="can_be_zero"></a>

=head2 static can_be_zero : boolean

Returns true if range crosses through zero.

=cut

sub can_be_zero {
    my($proto) = @_;
    return $proto->compare($proto->get_max, 0) >= 0
	    && $proto->compate($proto->get_min, 0) <= 0 ? 1 : 0;
}

=for html <a name="compare"></a>

=head2 static compare(string left, string right, int decimals) : int

See L<Bivio::Type::compare|Bivio::Type/"compare">.

=cut

sub compare {
    my($proto, $left, $right, $decimals) = @_;

    $decimals = $proto->get_decimals() unless defined($decimals);
    $left = _pad_decimal($proto->round($left, $decimals), $decimals);
    $right = _pad_decimal($proto->round($right, $decimals), $decimals);

    # remove the .
    $left =~ s/\.//;
    $right =~ s/\.//;

    return Math::BigInt->new($left)->bcmp(Math::BigInt->new($right));
}

=for html <a name="div"></a>

=head2 static div(string numerator, string denominator, int decimals) : string

Divides numerator by denominator and returns the result using the specified
decimal precision.
If decimals is undef, then the default precision is used.
Returns 'NaN' if the value isn't valid, ie. x/0.

NOTE: the result is truncated, not rounded

#TODO: the result is should be rounded, not truncated

=cut

sub div {
    my($proto, $v, $v2, $decimals) = @_;

    return _math_op('bdiv', $v, $v2,
	    defined($decimals) ? $decimals : $proto->get_decimals());
}

=for html <a name="fraction_as_string"></a>

=head2 static fraction_as_string(string number, int decimals) : string

Returns the fractional part of I<number> up to decimals without
the leading decimal with rounding.  If I<decimals> is zero, always
returns the empty string.

=cut

sub fraction_as_string {
    my($proto, $number, $decimals) = @_;
    return '' if $decimals == 0;
    my($res) = $proto->round($number, $decimals);
    $res =~ s/.*\.//;
    return $res;
}

=for html <a name="from_literal"></a>

=head2 static from_literal(string value) : string

Makes sure is a number.  Does not except scientific notation.
Allows fractional values like "-7 11/15" or "32/3". Fractional
values are converted to decimal using the precision returned by
get_decimals().

=cut

sub from_literal {
    my($proto, $value) = @_;
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

    Bivio::IO::ClassLoader->simple_require('Bivio::TypeError');
    # not a number
    return (undef, Bivio::TypeError::NUMBER())
	    unless defined($parsed_value);

    # round to the acceptable number of decimals
    $parsed_value = $proto->round($parsed_value, $proto->get_decimals);

    # range check
    return $parsed_value
	    if $proto->compare($parsed_value, $proto->get_min) >= 0
		    && $proto->compare($parsed_value, $proto->get_max) <= 0;

    return (undef, Bivio::TypeError::NUMBER_RANGE());
}

=for html <a name="get_decimals"></a>

=head2 get_decimals() : int

Abstract method to be defined by subclasses.

=cut

sub get_decimals {
    die("abstract method");
}

=for html <a name="mul"></a>

=head2 mul(string v, string v2, int decimals) : string

Multiplies two numbers and returns the result using the specified decimal
precision.
If decimals is undef, then the default precision is used.

NOTE: the result is truncated, not rounded

#TODO: the result is should be rounded, not truncated

=cut

sub mul {
    my($proto, $v, $v2, $decimals) = @_;

    return _math_op('bmul', $v, $v2,
	    defined($decimals) ? $decimals : $proto->get_decimals());
}

=for html <a name="neg"></a>

=head2 neg(string number) : string

Returns a number with the opposite sign from the specified one.

=cut

sub neg {
    my($proto, $number) = @_;

    return $number if $proto->compare($number, 0) == 0;

    my($sign, $num);
    if (($sign, $num) = $number =~ /^([-+])(.*)$/) {
	return ($sign eq '-' ? '+' : '-').$num;
    }
    return '-'.$number;
}

=for html <a name="round"></a>

=head2 round(string number, int decimals) : string

Rounds the number to the specified number of decimal places.

=cut

sub round {
    my($proto, $number, $decimals) = @_;
    die("invalid decimals $decimals") if $decimals < 0;
    my($rounder) = '0.'.('0' x $decimals).'5';
    if ($number =~ /^[-]/) {
	$rounder = '-'.$rounder;
    }
    $number = $proto->add($number, $rounder, $decimals + 1);
    return $proto->trunc($number, $decimals);
}

=for html <a name="sign"></a>

=head2 static sign(string number) : int

Returns -1, 0, +1 depending on the sign of number.

=cut

sub sign {
    my($proto, $number) = @_;
    my($sign) = $number =~ /^([-+])/;
    return $sign eq '-' ? -1 : 1 if defined($sign);
    return $proto->compare($number, 0) == 0 ? 0 : 1;
}

=for html <a name="sub"></a>

=head2 static sub(string v, string v2, int decimals) : string

Subtracts v2 from v and returns the result using the specified decimal
precision.
If decimals is undef, then the default precision is used.

=cut

sub sub {
    my($proto, $v, $v2, $decimals) = @_;

    return _math_op('bsub', $v, $v2,
	    defined($decimals) ? $decimals : $proto->get_decimals());
}

=for html <a name="to_literal"></a>

=head2 to_literal(any value) : string

Converts from internal form to a literal string value.

=cut

sub to_literal {
    my(undef, $value) = @_;
    return undef unless defined($value);

    # remove leading '+', replace '.1', '-.1' with '0.1', '-0.1' respectively
    $value =~ s/^\+//;
    $value =~ s/^\./0./;
    $value =~ s/^-\./-0./;

    # remove trailing 0s after decimal point
    $value =~ s/^(.*\..+?)(0+)$/$1/;
    return $value;
}

=for html <a name="trunc"></a>

=head2 trunc(string number, int decimals) : string

Truncates the number to the specified number of decimal places.

=cut

sub trunc {
    my($proto, $number, $decimals) = @_;
    die("invalid decimals $decimals") if $decimals < 0;

    my($int, $dec);
    if (($int, $dec) = $number =~ /^(.*)\.(.*)$/) {

	if (length($dec) > $decimals) {
	    $dec = substr($dec, 0, $decimals);
	    $number = $int.'.'.$dec;
	}
    }
    return $number;
}

#=PRIVATE METHODS

# _math_op(string op, string v, string v2, int decimals) : string
#
# Performs the specified math operation on the values, using the
# specified decimal precision.
#
sub _math_op {
    my($op, $v, $v2, $decimals) = @_;
    die("invalid decimals $decimals") if $decimals < 0;
    $v ||= 0;
    $v2 ||= 0;

    # right pad with zeros, double for div
    $v = _pad_decimal($v, $op eq 'bdiv' ? $decimals * 2 : $decimals);
    $v2 = _pad_decimal($v2, $decimals);

    # remove the .
    $v =~ s/\.//;
    $v2 =~ s/\.//;

    my($result) = Math::BigInt->new($v)->$op(Math::BigInt->new($v2));
    # strip and save the sign
    $result =~ s/^(.)//;
    my($sign) = $1;

    if ($op eq 'bmul') {
	# trim off extra decimals
	$result = substr($result, 0, length($result) - $decimals);
    }
    # left pad with zeros
    my($left_pad) = ($decimals + 1) - length($result);
    if ($left_pad > 0) {
	$result = ('0' x $left_pad).$result;
    }

    # put the . back in
    if ($decimals != 0) {
	my($expr) = '(.*)('.('.' x $decimals).')';
	$result =~ s/^$expr$/$1\.$2/x;
    }
    return $sign.$result;
}

# _pad_decimal(string value, int count) : string
#
# Pads the specified numeric string to exactly count decimal places.
#
sub _pad_decimal {
    my($value, $count) = @_;

    my($length) = length($value);
    my($dot_pos) = index($value, '.');
    my($decimals) = ($dot_pos == -1) ? undef : $length - $dot_pos - 1;

    # pad to exactly count decimal places
    if (! defined($decimals)) {
	$value .= '.'.('0' x $count);
    }
    elsif ($decimals < $count) {
	$value .= '0' x ($count - $decimals);
    }
    elsif ($decimals > $count) {
	$value = substr($value, 0, $length - ($decimals - $count));
	if ($value eq '.') {
	    $value = '0';
	}
    }
    return $value;
}

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut


1;
