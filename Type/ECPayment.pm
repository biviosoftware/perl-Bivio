# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Type::ECPayment;
use strict;
$Bivio::Type::ECPayment::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::ECPayment::VERSION;

=head1 NAME

Bivio::Type::ECPayment - list of possible payment types

=head1 SYNOPSIS

    use Bivio::Type::ECPayment;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::ECPayment::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::ECPayment> describes the possible payment methods
for a subscription-based service. The current choices are:

=over 4

=item SUBSCRIPTION

=item DONATION

=item MERCHANDISE

=back

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

__PACKAGE__->compile([
    SUBSCRIPTION => [
	1,
    ],
    DONATION => [
	2,
    ],
    MERCHANDISE => [
	3,
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
