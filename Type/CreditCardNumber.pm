# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Type::CreditCardNumber;
use strict;
$Bivio::Type::CreditCardNumber::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::CreditCardNumber::VERSION;

=head1 NAME

Bivio::Type::CreditCardNumber - a credit card number, TEST MODULE ONLY!

=head1 SYNOPSIS

    use Bivio::Type::CreditCardNumber;

=cut

=head1 EXTENDS

L<Bivio::Type::Secret>

=cut

use Bivio::Type::Secret;
@Bivio::Type::CreditCardNumber::ISA = ('Bivio::Type::Secret');

=head1 DESCRIPTION

C<Bivio::Type::CreditCardNumber> interprets a string as a credit card number.

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
use vars qw($_TRACE);
Bivio::IO::Trace->register;

=head1 METHODS

=cut

=for html <a name="from_literal"></a>

=head2 static from_literal(string value) : array

Returns C<undef> if the value is empty or does not pass the Luhn test

=cut

sub from_literal {
    my($proto, $value) = @_;
    $value = $proto->SUPER::from_literal($value);
    return undef unless defined($value);

#TODO: See doc about Secret::to_literal/to_html
#    # The user theoretically didn't modify the value.
#    return $value if $proto->value_is_blanked($value);

    # Remove dashes and spaces to be friendly
    $value =~ s/[-\s]+//g;
    return $proto->luhn_mod10($value) ? $value :
            (undef, Bivio::TypeError::CREDITCARD_INVALID_NUMBER());
}

=for html <a name="get_width"></a>

=head2 get_width() : int

Returns the maximum width of a credit card.

=cut

sub get_width {
    return 19;
}

=for html <a name="luhn_mod10"></a>

=head2 luhn_mod10(string number) : boolean

Returns TRUE if I<number> passes the Luhn Mod-10 test

=cut

sub luhn_mod10 {
    my(undef, $number) = @_;
    return 0 unless defined($number);
    my($len) = length($number);
    return 0 if $len < 12 || $len > 19 || $number =~ /\D/;

    my($sum) = 0;
    my($mul) = 1;
    my(@digits) = split('', $number);
    for (my $i = $len-1; $i >= 0; $i--) {
        $a = $digits[$i] * $mul;
        $sum += $a % 10 + ($a > 9 ? 1 : 0);
        $mul = $mul == 1 ? 2 : 1;
    }
    return ($sum % 10) == 0 ? 1 : 0;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
