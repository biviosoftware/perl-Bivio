# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Type::UserState;
use strict;
$Bivio::Type::UserState::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::UserState::VERSION;

=head1 NAME

Bivio::Type::UserState - logged in, registered, just visitor

=head1 SYNOPSIS

    use Bivio::Type::UserState;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::UserState::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::UserState> identifies what type of user we have:

=over 4

=item JUST_VISITOR

Not a user as far as we know.

=item LOGGED_OUT

User is not logged in

=item LOGGED_IN

User is logged in

=back

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile([
    JUST_VISITOR => [1],
    LOGGED_OUT => [2],
    LOGGED_IN => [3],
# SUBSTITUTED_USER?
]);

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
