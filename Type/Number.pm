# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::Number;
use strict;
$Bivio::Type::Number::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::Number - base class for all number types

=head1 SYNOPSIS

    use Bivio::Type::Number;

=cut

=head1 EXTENDS

L<Bivio::Type>

=cut

use Bivio::Type;
@Bivio::Type::Number::ISA = qw(Bivio::Type);

=head1 DESCRIPTION

C<Bivio::Type::Number> is the base class for all number types.
It provides arbitrary precision arithmetic for like-based numbers.

=cut

#=IMPORTS
# intesting circular import if you uncomment this, 'use Bivio::Enum' instead
#use Bivio::TypeError;
use Math::BigInt ();

#=VARIABLES

=head1 METHODS

=cut

=head2 static add(string v, string v2, int decimals) : string

Adds two numbers and returns the result using the specified decimal precision.
If decimals is undef, then the default precision is used.

=cut

sub add {
    my($proto, $v, $v2, $decimals) = @_;

    return _math_op('badd', $v, $v2,
	    defined($decimals) ? $decimals : $proto->get_decimals());
}

=for html <a name="compare"></a>

=head2 static compare(string v, string v2, int decimals) : int

Returns > 0 if I<v> is greater than I<v2>.
Returns 0 if I<v> is equal to I<v2>.
Returns < 0 if I<v> is less than I<v2>.

=cut

sub compare {
    my($proto, $v, $v2, $decimals) = @_;

    $decimals = $proto->get_decimals() unless defined($decimals);
    $v = $proto->round($v, $decimals);
    $v2 = $proto->round($v2, $decimals);

    return _math_op('bcmp', $v, $v2, $decimals);
}

=for html <a name="div"></a>

=head2 div(string numerator, string denominator, int decimals) : string

Divides numerator by denominator and returns the result using the specified
decimal precision.
If decimals is undef, then the default precision is used.
Returns 'NaN' if the value isn't valid, ie. x/0.

NOTE: the result is truncated, not rounded

=cut

sub div {
    my($proto, $v, $v2, $decimals) = @_;

    return _math_op('bdiv', $v, $v2,
	    defined($decimals) ? $decimals : $proto->get_decimals());
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
    $value =~ s/[,\$]//g;

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
	    return $value;
	}
    }
    else {
	# Get rid of all blanks to be nice to user
	$value =~ s/\s+//g;
	return $value if $value =~ /^[-+]?(\d+\.?\d*|\.\d+)$/;
    }
    return (undef, Bivio::TypeError::NUMBER());
}

=for html <a name="mul"></a>

=head2 mul(string v, string v2, int decimals) : string

Multiplies two numbers and returns the result using the specified decimal
precision.
If decimals is undef, then the default precision is used.

NOTE: the result is truncated, not rounded

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
    $value =~ s/^\+//;
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

    # right pad with zeros, double for div
    $v = _pad_decimal($v, $op eq 'bdiv' ? $decimals * 2 : $decimals);
    $v2 = _pad_decimal($v2, $decimals);

    # remove the .
    $v =~ s/\.//;
    $v2 =~ s/\.//;

#    print("($v) ($v2)\n");
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

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut


1;
