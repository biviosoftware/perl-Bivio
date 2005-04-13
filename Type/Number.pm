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
use GMP::Mpf ();

#=VARIABLES
my($_FUDGE) = _mpf('1e-20');
my($_HALF) = _mpf('0.5');
my($_POWER) = {};

=head1 METHODS

=cut

=for html <a name="abs"></a>

=head2 static abs(string v) : string

Converts a negative into a positive number.

=cut

sub abs {
    my($proto, $v) = @_;
    return _format($proto, abs(_mpf($v)));
}

=head2 static add(string v, string v2, int decimals) : string

Adds two numbers and returns the result using the specified decimal precision.
If decimals is undef, then the default precision is used.

=cut

sub add {
    my($proto, $v, $v2, $decimals) = @_;
    return _format($proto,
        GMP::Mpf::overload_addeq(_mpf($v), _mpf($v2), 0), $decimals);
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
        && $proto->compare($proto->get_min, 0) <= 0 ? 1 : 0;
}

=for html <a name="compare_defined"></a>

=head2 static compare_defined(string left, string right, int decimals) : int

See L<Bivio::Type::compare_defined|Bivio::Type/"compare_defined">.

=cut

sub compare_defined {
    my($proto, $left, $right, $decimals) = @_;
    return _mpf($left) <=> _mpf($right);
}

=for html <a name="div"></a>

=head2 static div(string numerator, string denominator, int decimals) : string

Divides numerator by denominator and returns the result using the specified
decimal precision.

Dies if dividing by 0.

=cut

sub div {
    my($proto, $v, $v2, $decimals) = @_;
    Bivio::Die->die('divide by zero: ', $v, '/', $v2)
        if ! defined($v2) || $v2 =~ /^[0.]+$/;
    return _format($proto,
        GMP::Mpf::overload_diveq(_mpf($v), _mpf($v2), 0), $decimals);
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

    Bivio::IO::ClassLoader->simple_require('Bivio::TypeError');
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

=for html <a name="get_decimals"></a>

=head2 get_decimals() : int

Abstract method to be defined by subclasses.

=cut

sub get_decimals {
    die("abstract method");
}

=for html <a name="max"></a>

=head2 max(string left, string right) : string

Returns maximum of I<left> and I<right>.

=cut

sub max {
    my($self, $left, $right) = @_;
    return $self->compare($left, $right) <= 0 ? $right : $left;
}

=for html <a name="min"></a>

=head2 min(string left, string right) : string

Returns minimum of I<left> and I<right>.

=cut

sub min {
    my($self, $left, $right) = @_;
    return $self->compare($left, $right) <= 0 ? $left : $right;
}

=for html <a name="mul"></a>

=head2 mul(string v, string v2, int decimals) : string

Multiplies two numbers and returns the result using the specified decimal
precision.
If decimals is undef, then the default precision is used.

=cut

sub mul {
    my($proto, $v, $v2, $decimals) = @_;
    return _format($proto,
        GMP::Mpf::overload_muleq(_mpf($v), _mpf($v2), 0), $decimals);
}

=for html <a name="neg"></a>

=head2 neg(string number) : string

Returns a number with the opposite sign from the specified one.

=cut

sub neg {
    my($proto, $number) = @_;
    return _format($proto, - _mpf($number));
}

=for html <a name="round"></a>

=head2 round(string number, int decimals) : string

Rounds the number to the specified number of decimal places.

=cut

sub round {
    my($proto, $number, $decimals) = @_;
    Bivio::Die->die('invalid decimals: ', $decimals) if $decimals < 0;
    return _format($proto, _mpf($number), $decimals);
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
    return _format($proto,
        GMP::Mpf::overload_subeq(_mpf($v), _mpf($v2), 0), $decimals);
}

=for html <a name="to_literal"></a>

=head2 to_literal(any value) : string

Converts from internal form to a literal string value.

=cut

sub to_literal {
    my($proto, $value) = @_;
    return $proto->SUPER::to_literal($value)
	unless defined($value);

    # remove leading '+', replace '.1', '-.1' with '0.1', '-0.1' respectively
    $value =~ s/^\+//;
    $value =~ s/^\./0./;
    $value =~ s/^-\./-0./;

    # remove trailing 0s after decimal point
    $value =~ s/^(.*\..+?)(0+)$/$1/
        unless $value =~ s/\.0*$//;
    return $value;
}

=for html <a name="trunc"></a>

=head2 trunc(string number, int decimals) : string

Truncates the number to the specified number of decimal places.

=cut

sub trunc {
    my($proto, $number, $decimals) = @_;
    Bivio::Die->die('invalid decimals: ', $decimals) if $decimals < 0;
    my($pow) = 10 ** $decimals;
    return return _format($proto, GMP::Mpf::trunc($number * $pow) / $pow,
        $decimals);
}

#=PRIVATE METHODS

# _format(proto, ref v) : string
#
# _format(proto, ref v, int decimals) : string
#
# Formats the amount, rounded to the specified number of decimals.
#
sub _format {
    my($proto, $v, $decimals) = @_;
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

# _mpf(string value) : ref
#
# Returns a GMP::Mpf value for the specified string value.
#
sub _mpf {
    my($value) = @_;

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

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut


1;
