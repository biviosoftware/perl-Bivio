# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Type::ECPaymentStatus;
use strict;
$Bivio::Type::ECPaymentStatus::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::ECPaymentStatus::VERSION;

=head1 NAME

Bivio::Type::ECPaymentStatus - list of payment statuses

=head1 SYNOPSIS

    use Bivio::Type::ECPaymentStatus;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::ECPaymentStatus::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::ECPaymentStatus> describes the possible states
a payment can be associated with. The current choices are:

=over 4

=item PROCESSING

=item FAILED

=item CAPTURED

=item REFUND

=item VOID

=back

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

__PACKAGE__->compile([
    PROCESSING => [
	1,
    ],
    FAILED => [
	2,
    ],
    CAPTURED => [
	3,
    ],
    REFUND => [
	4,
    ],
    VOID => [
	5,
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
