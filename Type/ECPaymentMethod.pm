# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Type::ECPaymentMethod;
use strict;
$Bivio::Type::ECPaymentMethod::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::ECPaymentMethod::VERSION;

=head1 NAME

Bivio::Type::ECPaymentMethod - list of possible payment methods

=head1 SYNOPSIS

    use Bivio::Type::ECPaymentMethod;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::ECPaymentMethod::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::ECPaymentMethod> describes the possible payment methods.
The current choices are:

=over 4

=item CREDIT_CARD

=item BANK_CHECK

=item NO_PAYMENT

=back

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

__PACKAGE__->compile([
    CREDIT_CARD => [
	1,
        'Credit Card',
    ],
    BANK_CHECK => [
	2,
        'Check',
    ],
    NO_PAYMENT => [
	3,
	'No Payment',
    ],
]);

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
