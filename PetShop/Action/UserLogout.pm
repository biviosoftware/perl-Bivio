# Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.
# $Id$
package Bivio::PetShop::Action::UserLogout;
use strict;
$Bivio::PetShop::Action::UserLogout::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Action::UserLogout::VERSION;

=head1 NAME

Bivio::PetShop::Action::UserLogout - logs the user out

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Action::UserLogout;

=cut

=head1 EXTENDS

L<Bivio::Biz::Action::UserLogout>

=cut

use Bivio::Biz::Action::UserLogout;
@Bivio::PetShop::Action::UserLogout::ISA = ('Bivio::Biz::Action::UserLogout');

=head1 DESCRIPTION

C<Bivio::PetShop::Action::UserLogout> clears the user on the request
and in the cookie.

=cut

#=IMPORTS
use Bivio::Biz::Model;
use Bivio::Die;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute_clear_cart_and_logout"></a>

=head2 execute_clear_cart_and_logout(Bivio::Agent::Request req)

Clears the current cart and logs out the user.

=cut

sub execute_clear_cart_and_logout {
    my($proto, $req) = @_;

    # catch exceptions
    # Postgres has a bug which doesn't allow a row to be added
    # and then deleted in the same transaction
    Bivio::Die->catch(sub {
        Bivio::Biz::Model->new($req, 'Cart')->load_from_cookie->cascade_delete;
    });
    $proto->execute($req);
    return 0;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.

=head1 VERSION

$Id$

=cut

1;
