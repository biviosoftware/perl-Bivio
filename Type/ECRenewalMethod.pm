# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Type::ECRenewalMethod;
use strict;
$Bivio::Type::ECRenewalMethod::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::ECRenewalMethod::VERSION;

=head1 NAME

Bivio::Type::ECRenewalMethod - list of possible renewal methods

=head1 SYNOPSIS

    use Bivio::Type::ECRenewalMethod;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::ECRenewalMethod::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::ECRenewalMethod> describes the possible renewal methods
for a subscription. The current choices are:

=over 4

=item NONE

=item AUTOMATIC

=item REMINDER

=back

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

__PACKAGE__->compile([
    NONE => [
	1,
        'Do not renew',
    ],
    AUTOMATIC => [
	2,
        'Renew automatically',
    ],
    REMINDER => [
	3,
        'Send reminder',
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
