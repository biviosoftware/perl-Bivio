# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::Setup::Finish;
use strict;
$Bivio::UI::Setup::Finish::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::Setup::Finish - setup finish view

=head1 EXTENDS

L<Bivio::UI::View>

=cut

use Bivio::UI::View;
@Bivio::UI::Setup::Finish::ISA = qw(Bivio::UI::View);

=head1 DESCRIPTION

C<Bivio::UI::Setup::Finish> a congratulatory view of club creation.

=cut

#=IMPORTS
use Bivio::Agent::TaskId;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::AgentRequest req)

=cut

sub execute {
    my($self, $req) = @_;
    $self->activate->render(
	    $req->get('Bivio::Biz::Model::RealmOwner'), $req);
    return;
}

=for html <a name="render"></a>

=head2 render(undef, Request req)

Shows the congratulatory view.

=cut

sub render {
    my($self, $realm_owner, $req) = @_;
    my($reply) = $req->get_reply();

    $reply->print('<table border=0><tr><td>');

    # Club created.  Need to switch realms.
    my($realm) = Bivio::Auth::Realm::Club->new($realm_owner);
    $reply->print('<form action='
	    .$req->format_uri(Bivio::Agent::TaskId::CLUB_MEMBER_LIST,
		   undef, $realm)
	    .' method="post">');

    $reply->print('Congratulations, club setup is completed. After '
	    .'pressing "next", enter your user name and password and you '
	    .'will be directed to the club user list screen. From there '
	    .'you can add additional club members.<p>'
	    .'<img src="/i/test/painted.gif">');
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
