# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Type::ECSubscription;
use strict;
$Bivio::Type::ECSubscription::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::ECSubscription::VERSION;

=head1 NAME

Bivio::Type::ECSubscription - list of premium services

=head1 SYNOPSIS

    use Bivio::Type::ECSubscription;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::ECSubscription::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::ECSubscription> describes the premium services
a realm can be subscribed to. The current choices are:

=over 4

=item ACCOUNT_SYNC

=item ACCOUNT_FULL

=item PROFESSIONAL_FUNDS

=back

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

__PACKAGE__->compile([
    ACCOUNT_SYNC => [
	1,
        'Account Sync',
    ],
    ACCOUNT_KEEPER => [
	2,
        'Account Keeper',
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
