# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::Setup::Admin;
use strict;
$Bivio::UI::Setup::Admin::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::Setup::Admin - initial administrator setup view

=head1 EXTENDS

L<Bivio::UI::View>

=cut

use Bivio::UI::View;
@Bivio::UI::Setup::Admin::ISA = qw(Bivio::UI::View);

=head1 DESCRIPTION

C<Bivio::UI::Setup::Admin> shows an admin creation screen.

=cut

#=IMPORTS
use Bivio::Biz::Model::User;
use Bivio::Biz::Model::UserEmail;
use Bivio::Agent::TaskId;

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
	    Bivio::Biz::Model::RealmOwner->new($req), $req);
    return;
}

=for html <a name="render"></a>

=head2 render(User user, Request req)

Creates a form for editing the club administrator's User model.

=cut

sub render {
    my($self, $realm_owner, $req) = @_;
    my($reply) = $req->get_reply();

    # used for type information only
    my($user) = Bivio::Biz::Model::User->new($req);
    my($email) = Bivio::Biz::Model::UserEmail->new($req);

#TODO: Put some line breaks so easier to read.  Don't call print so many times.
    $reply->print('<table border=0><tr><td>');
    $reply->print('<table border=0 cellpadding=0 cellspacing=0>');

    $reply->print('First, let\'s get some information about the club '
	    .'administrator. Required fields are indicated with a *.<p>');

    $reply->print('<form action='
	    .$req->format_uri(Bivio::Agent::TaskId::SETUP_USER_CREATE)
	    .' method="post">');

    $reply->print('<tr><td rowspan=100 width=15></td></tr>');

    # render all the entry fields - values are from the model or
    # the request.

    Bivio::UI::HTML::FieldUtil->entry_field($realm_owner, 'name', $req, 1);
    Bivio::UI::HTML::FieldUtil->entry_field($realm_owner, 'password', $req, 1);
    Bivio::UI::HTML::FieldUtil->entry_field($email, 'email', $req, 1);

    $reply->print('<tr><td>&nbsp;</td></tr>');

    Bivio::UI::HTML::FieldUtil->entry_field($user, 'first_name', $req);
    Bivio::UI::HTML::FieldUtil->entry_field($user, 'middle_name',$req);
    Bivio::UI::HTML::FieldUtil->entry_field($user, 'last_name', $req);
    Bivio::UI::HTML::FieldUtil->entry_field($user, 'age', $req);
    $reply->print('<tr><td>&nbsp;</td></tr>');
    Bivio::UI::HTML::FieldUtil->entry_field($user, 'gender', $req);

    $reply->print('<tr><td>&nbsp;</td></tr>');
    $reply->print('<tr><td>'
	    .'<input type="submit" value="Next">'
	    .'</td></tr>');

    $reply->print('</form></table>');
    $reply->print('</td></tr></table>');
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
