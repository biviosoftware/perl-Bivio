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
@Bivio::UI::Admin::UserView::ISA = qw(Bivio::UI::View);

=head1 DESCRIPTION

C<Bivio::UI::Admin::UserView> allows editing a L<Bivio::Biz::User> model.

=cut

#=IMPORTS
use Bivio::Biz::ClubUser;
use Bivio::Biz::User;
use Bivio::Biz::UserDemographics;
use Bivio::IO::Trace;
use Bivio::UI::HTML::FieldUtil;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::Admin::UserView

Creates a user editing view.

=cut

sub new {
    my($proto) = @_;
    my($self) = &Bivio::UI::View::new($proto, 'user');
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_default_model"></a>

=head2 get_default_model() : Model

Returns an instance of the User model.

=cut

sub get_default_model {
    return Bivio::Biz::User->new();
}

=for html <a name="render"></a>

=head2 render(User user, Request req)

Creates a form for editing the L<Bivio::Biz::User> model.

=cut

sub render {
    my($self, $user, $req) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($reply) = $req->get_reply();

#TODO: handle update as well
    my($action) = 'add';
    my($demographics) = Bivio::Biz::UserDemographics->new();
    my($email) = Bivio::Biz::UserEmail->new();
    my($club_user) = Bivio::Biz::ClubUser->new();

    $reply->print('<table border=0><tr><td>');
    $reply->print('<table border=0 cellpadding=0 cellspacing=0>');

    $reply->print('Enter user information below. Required fields are'
	    .' indicated with a *.<p>');

    if (! $user->get_status()->is_ok() ) {
	$reply->print('<font color="#FF0000">');
	my($errors) = $user->get_status()->get_errors();
	foreach (@$errors) {
	    $reply->print($_->get_message().'<br>');
	}
	$reply->print('</font>');
    }

    $reply->print('<form action='.$req->make_path().' method="post">');

    $reply->print('<input type="hidden" name="ma" value='.$action.'>');
    $reply->print('<tr><td rowspan=100 width=15></td></tr>');

    Bivio::UI::HTML::FieldUtil->entry_field($user, 'name', $req, 1);
    Bivio::UI::HTML::FieldUtil->entry_field($user, 'password', $req, 1);
    Bivio::UI::HTML::FieldUtil->entry_field($email, 'email', $req, 1);

    $reply->print('<tr><td>&nbsp;</td></tr>');

    Bivio::UI::HTML::FieldUtil->entry_field($demographics, 'first_name', $req);
    Bivio::UI::HTML::FieldUtil->entry_field($demographics, 'middle_name',$req);
    Bivio::UI::HTML::FieldUtil->entry_field($demographics, 'last_name', $req);
    Bivio::UI::HTML::FieldUtil->entry_field($demographics, 'age', $req);
    $reply->print('<tr><td>&nbsp;</td></tr>');
    Bivio::UI::HTML::FieldUtil->entry_field($demographics, 'gender', $req);
    $reply->print('<tr><td>&nbsp;</td></tr>');
    $reply->print('<tr><td>Role</td></tr>');
    Bivio::UI::HTML::FieldUtil->entry_field($club_user, 'role', $req);

    $reply->print('<tr><td>&nbsp;</td></tr>');
    $reply->print('<tr><td colspan=2 align=center>'
	    .'<input type="submit" value="OK">&nbsp'
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
