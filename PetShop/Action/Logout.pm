# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Action::Logout;
use strict;
$Bivio::PetShop::Action::Logout::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Action::Logout::VERSION;

=head1 NAME

Bivio::PetShop::Action::Logout - logs the user out

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Action::Logout;

=cut

use Bivio::UNIVERSAL;
@Bivio::PetShop::Action::Logout::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::PetShop::Action::Logout> clears the user on the request
and in the cookie.

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 static execute(Bivio::Agent::Request req) : boolean

Calls the I<Model.LoginForm> to clear the user.

=cut

sub execute {
    my(undef, $req) = @_;
    Bivio::Biz::Model->get_instance('LoginForm')->execute($req,
	    {realm_owner => undef});
    return 0;
}

=for html <a name="execute_clear_cart_and_logout"></a>

=head2 execute_clear_cart_and_logout(Bivio::Agent::Request req)

Clears the current cart and logs out the user.

=cut

sub execute_clear_cart_and_logout {
    my($proto, $req) = @_;
    my($cart) = Bivio::Biz::Model->new($req, 'Cart');
    $cart->cascade_delete
	    if $cart->unsafe_load({cart_id => $req->get('cart_id')});
    $proto->execute($req);
    return 0;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
