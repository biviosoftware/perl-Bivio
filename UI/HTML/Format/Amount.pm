# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Format::Amount;
use strict;
$Bivio::UI::HTML::Format::Amount::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Format::Amount - formats numeric values

=head1 SYNOPSIS

    use Bivio::UI::HTML::Format::Amount;
    Bivio::UI::HTML::Format::Amount->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Format>

=cut

use Bivio::UI::HTML::Format;
@Bivio::UI::HTML::Format::Amount::ISA = ('Bivio::UI::HTML::Format');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Format::Amount> formats a numeric value to a specified
number of decimal points.

=cut

#=IMPORTS
use Math::BigInt ();

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_DECIMAL_MAX) = 7;
my($_FULL_PAD) = '.' . ('0' x $_DECIMAL_MAX);


=head1 METHODS

=cut

=for html <a name="get_widget_value"></a>

=head2 static get_widget_value(string amount, $round) : string

Formats a numeric amount to the specified number of decimal digits. The
amount must be of the form:

  (-)?d+(.d+)?

=cut

sub get_widget_value {
    my(undef, $amount, $round) = @_;

#TODO: very ugly code needs revisiting

    die("round $round > $_DECIMAL_MAX") if $round > $_DECIMAL_MAX;
    die("invalid number $amount") unless $amount =~ /^-?\d+(\.\d+)?$/;

    my($negative) = $amount =~ /^-/;

    my($length) = length($amount);
    my($dot_pos) = index($amount, '.');
    my($decimals) = ($dot_pos == -1) ? 0 : $length - $dot_pos - 1;

    # pad to exactly _DECIMAL_MAX decimal places
    if ($decimals == 0) {
	$amount .= $_FULL_PAD;
    }
    elsif ($decimals < $_DECIMAL_MAX) {
	$amount .= '0' x ($_DECIMAL_MAX - $decimals);
    }
    elsif ($decimals > $_DECIMAL_MAX) {
	$amount = substr($amount, 0, $length - ($decimals - $_DECIMAL_MAX));
    }

    # strip . and round up
    $amount =~ s/\.//;
    my($bigint) = Math::BigInt->new($amount);
    my($rounder) = '5'.('0' x ($_DECIMAL_MAX - $round - 1));
    $rounder = '-'.$rounder if $negative;
    $bigint = $bigint->badd($rounder);

    # strip sign and left pad with 0 if necessary
    $bigint =~ s/^.//;
    my($need_pad) = ($_DECIMAL_MAX + 1) - length($bigint);
    if ($need_pad > 0) {
	$bigint = ('0' x $need_pad) . $bigint;
    }

    # extract number and decimal
    my($dec) = substr($bigint, length($bigint) - $_DECIMAL_MAX, $round);
    my($num) = substr($bigint, 0, length($bigint) - $_DECIMAL_MAX);

#TODO: put , in num

    my($result) = $num.'.'.$dec;
    return $negative ? '-'.$result : $result;
}

#=PRIVATE METHODS

=begin


print(
Bivio::UI::HTML::Format::Amount->get_widget_value('123.456', 2)."\n".
Bivio::UI::HTML::Format::Amount->get_widget_value('0.456', 2)."\n".
Bivio::UI::HTML::Format::Amount->get_widget_value('0', 2)."\n".
Bivio::UI::HTML::Format::Amount->get_widget_value('-1.1', 2)."\n".
Bivio::UI::HTML::Format::Amount->get_widget_value('-1.12345678', 2)."\n".
Bivio::UI::HTML::Format::Amount->get_widget_value('12345678901234567890.777777777777', 2)."\n"
       );

=cut

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
