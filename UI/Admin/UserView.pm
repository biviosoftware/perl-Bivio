# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::Admin::UserView;
use strict;
$Bivio::UI::Admin::UserView::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::Admin::UserView - a user editing view

=head1 EXTENDS

L<Bivio::UI::View>

=cut

use Bivio::UI::View;
@Bivio::UI::Admin::UserView::ISA = ('Bivio::UI::View');

=head1 DESCRIPTION

C<Bivio::UI::Admin::UserView> allows editing a L<Bivio::Biz::Model::User> model.

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::Biz::Model::ClubUser;
use Bivio::Biz::Model::User;
use Bivio::UI::HTML::FieldUtil;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

=cut

sub execute {
    my($self, $req) = @_;
#TODO: Need to do load_from_request allowing for not found.
    $self->activate->render(Bivio::Biz::Model::RealmOwner->new($req), $req);
    return;
}

=for html <a name="render"></a>

=head2 render(undef, Request req)

Creates a form for editing the L<Bivio::Biz::Model::User> model.

=cut

sub render {
    my($self, $realm_owner, $req) = @_;
    my($reply) = $req->get_reply();

#TODO: handle update as well
    my($user) = Bivio::Biz::Model::User->new($req);
    my($email) = Bivio::Biz::Model::UserEmail->new($req);
    my($realm_user) = Bivio::Biz::Model::RealmUser->new($req);

    $reply->print('<table border=0><tr><td>');
    $reply->print('<table border=0 cellpadding=0 cellspacing=0>');

    $reply->print('Enter user information below. Required fields are'
	    .' indicated with a *.<p>');

#TODO: This has to be ok, because we got to the form.
    $reply->print('<form action='
	    .$req->format_uri(Bivio::Agent::TaskId::CLUB_MEMBER_ADD)
	    .' method="post">');

    $reply->print('<tr><td rowspan=100 width=15></td></tr>');

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
    $reply->print('<tr><td>Role</td></tr>');
    Bivio::UI::HTML::FieldUtil->entry_field($realm_user, 'role', $req);

    $reply->print('<tr><td>&nbsp;</td></tr>');
    $reply->print('<tr><td colspan=2 align=center>'
	    .'<input type="submit" value="OK">&nbsp'
#TODO: Cancel button needs to be implemented
#	    .'<input type="submit" value="Cancel">'
	    .'</td></tr>');

    $reply->print('</table></form>');
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
