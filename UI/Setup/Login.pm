# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::Setup::Login;
use strict;
$Bivio::UI::Setup::Login::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::Setup::Login - tell the user to login

=head1 EXTENDS

L<Bivio::UI::View>

=cut

use Bivio::UI::View;
use Bivio::Agent::TaskId;
@Bivio::UI::Setup::Login::ISA = qw(Bivio::UI::View);

=head1 DESCRIPTION

C<Bivio::UI::Setup::Login> tells the user to login.

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::AgentRequest req)

=cut

sub execute {
    my($self, $req) = @_;
#TODO: Need to allow for no model in rendering code
    $self->activate->render(
	    Bivio::Biz::Model::User->new($req), $req);
    return;
}

=for html <a name="render"></a>

=head2 render(undef, Request req)

Draws an Loginductary club setup view.

=cut

sub render {
    my($self, undef, $req) = @_;
    my($reply) = $req->get_reply();

    $reply->print('<table border=0><tr><td>');

#TODO: Need to have 'admin' be a constant somewhere.
    $reply->print('<form action='
	    .$req->format_uri(Bivio::Agent::TaskId::SETUP_CLUB_EDIT)
	    .' method="post">');

    $reply->print('You will now be asked to login.');
    $reply->print('<p><input type="submit" value="Next">');

    $reply->print('</form></td></tr></table>');
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
