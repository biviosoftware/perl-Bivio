# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Format::Amount;
use strict;
$Bivio::UI::HTML::Format::Amount::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Format::Amount::VERSION;

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
use Bivio::TypeError;
use Bivio::Type::Amount;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="get_widget_value"></a>

=head2 static get_widget_value(string amount) : string

=head2 static get_widget_value(string amount, int round, boolean want_parens, boolean zero_as_blank) : string

Formats a numeric amount to the specified number of decimal digits.
L<Bivio::Type::Number|Bivio::Type::Number> is used to check whether
the amount is a valid number.

Default I<round> is two (2).

Returns the empty string if I<amount> is not defined.

If I<want_parens>, negative numbers will be displayed with parenthesis
and positive numbers will be bracketed in spaces.

if I<zero_as_blank>, 0 will be rendered as ' '.

=cut

sub get_widget_value {
    my(undef, $amount, $round, $want_parens, $zero_as_blank) = @_;

    return '' unless defined($amount);
    return ' ' if $zero_as_blank && $amount == 0;
    $round = 2 unless defined($round);

    $amount = Bivio::Type::Amount->round($amount, $round);
    # check for leading '-' and not '-0.00'
    my($negative) = $amount =~ /^[-]/ && $amount =~ /[^\-^0^\.]/;

    my($num, $dec);
    if (($num, $dec) = $amount =~ /^[+-]?(.*)\.(.*)$/) {
	;
    }
    else {
	$num = $amount;
    }

    # put ',' in the number
    if (length($num) > 3) {
	my(@chars) = reverse(split(//, $num));
	$num = '';
	for (my($i) = 0; $i < int(@chars); $i++) {
	    $num = ','.$num unless ($i == 0 || $i % 3);
	    $num = $chars[$i].$num;
	}
    }

    my($result) = ($round > 0 && defined($dec)) ? ($num.'.'.$dec) : $num;

#TODO: really want &nbsp; around positive values.  Add result_is_html()
    return $negative ? '('.$result.')' : ' '.$result.' ' if $want_parens;
    return $negative ? '-'.$result : $result;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
