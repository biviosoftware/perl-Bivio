# Copyright (c) 2000-2002 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Type::ECCreditCardType;
use strict;
$Bivio::Type::ECCreditCardType::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::ECCreditCardType::VERSION;

=head1 NAME

Bivio::Type::ECCreditCardType - supported credit card types

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::ECCreditCardType;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::ECCreditCardType::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::ECCreditCardType> lists the currently supported credit card types.

=over 4

=item VISA

=item MASTERCARD

=item AMEX

=item DISCOVER

=back

=cut

#=IMPORTS
use Bivio::IO::Config;

#=VARIABLES
__PACKAGE__->compile([
    UNKNOWN => [0],
    VISA => [1],
    MASTERCARD => [2, 'MasterCard'],
    AMEX => [3, 'Amex', 'American Express'],
    DISCOVER => [4],
]);

Bivio::IO::Config->register({
    supported_card_list => 'VISA MASTERCARD AMEX DISCOVER',
});
my($_SUPPORTED_CARDS);

=head1 METHODS

=cut

=for html <a name="get_by_number"></a>

=head2 static get_by_number(string number) : Bivio::Type::ECCreditCard

Given a card I<number>, return its type  Handles C<undef> as unknown.

=cut

sub get_by_number {
    my($proto, $number) = @_;
    return $proto->UNKNOWN unless defined($number);
    $number =~ s/\s+//g;
    return $proto->UNKNOWN if $number =~ /\D/;
    my($len) = length($number);
    return $proto->VISA
            if ($len == 13 || $len == 16) && $number =~ /^4/;
    return $proto->MASTERCARD
            if $len == 16 && $number =~ /^5[1-5]/;
    return $proto->AMEX
            if $len == 15 && $number =~ /^3[47]/;
    return $proto->DISCOVER
	    if $len == 16 && $number =~ /^6011/;
    return $proto->UNKNOWN;
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item supported_card_list : string

List of supported card enum names.
Defaults to 'VISA MASTERCARD AMEX DISCOVER'.

=back

=cut

sub handle_config {
    my($proto, $cfg) = @_;

    # map of enum name values, ensures they are valid before adding
    $_SUPPORTED_CARDS = {
	map {$proto->from_name($_)->get_name => 1}
	    split(' ', $cfg->{supported_card_list}),
    };
    return;
}

=for html <a name="is_supported_by_number"></a>

=head2 static is_supported_by_number(string number) : boolean

Returns true if CC is supported.

=cut

sub is_supported_by_number {
    my($self, $number) = @_;
    return $_SUPPORTED_CARDS->{$self->get_by_number($number)->get_name}
	? 1 : 0;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000-2002 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
