# Copyright (c) 2002 bivio Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::ECRenewalState;
use strict;
$Bivio::Type::ECRenewalState::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::ECRenewalState::VERSION;

=head1 NAME

Bivio::Type::ECRenewalState - subscription renewal states

=head1 RELEASE SCOPE

Societas

=head1 SYNOPSIS

    use Bivio::Type::ECRenewalState;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::ECRenewalState::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::ECRenewalState>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

__PACKAGE__->compile([
    UNKNOWN => [0],
    OK => [1],
    FIRST_NOTICE => [2],
    SECOND_NOTICE => [3],
    EXPIRED => [4],
]);

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2002 bivio Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
