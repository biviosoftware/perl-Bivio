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
use Bivio::Biz::UserDemographics;
use Bivio::Biz::UserEmail;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::Setup::Admin

Creates a administrator user creation view.

=cut

sub new {
    my($proto) = @_;
    my($self) = &Bivio::UI::View::new($proto, 'admin');
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

Creates a form for editing the club administrator's User model.

=cut

sub render {
    my($self, $user, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    # used for type information only
    my($demographics) = Bivio::Biz::UserDemographics->new();
    my($email) = Bivio::Biz::UserEmail->new();

    $req->print('<table border=0><tr><td>');
    $req->print('<table border=0 cellpadding=0 cellspacing=0>');

    $req->print('First, let\'s get some information about the club '
	    .'administrator. Required fields are indicated with a *.<p>');

    # print any errors if present

    if (! $user->get_status()->is_ok() ) {
	$req->print('<font color="#FF0000">');
	my($errors) = $user->get_status()->get_errors();
	foreach (@$errors) {
	    $req->print($_->get_message().'<br>');
	}
	$req->print('</font>');
    }

    $req->print('<form action='.$req->make_path().' method="post">');

    $req->print('<input type="hidden" name="ma" value=add>');
    $req->print('<tr><td rowspan=100 width=15></td></tr>');

    # render all the entry fields - values are from the model or
    # the request.

    Bivio::UI::HTML::FieldUtil->entry_field($user, 'name', $req, 1);
    Bivio::UI::HTML::FieldUtil->entry_field($user, 'password', $req, 1);
    Bivio::UI::HTML::FieldUtil->entry_field($email, 'email', $req, 1);

    $req->print('<tr><td>&nbsp;</td></tr>');

    Bivio::UI::HTML::FieldUtil->entry_field($demographics, 'first_name', $req);
    Bivio::UI::HTML::FieldUtil->entry_field($demographics, 'middle_name',$req);
    Bivio::UI::HTML::FieldUtil->entry_field($demographics, 'last_name', $req);
    Bivio::UI::HTML::FieldUtil->entry_field($demographics, 'age', $req);
    $req->print('<tr><td>&nbsp;</td></tr>');
    Bivio::UI::HTML::FieldUtil->entry_field($demographics, 'gender', $req);

    $req->print('<tr><td>&nbsp;</td></tr>');
    $req->print('<tr><td>'
	    .'<input type="submit" value="Next">'
	    .'</td></tr>');

    $req->print('</form></table>');
    $req->print('</td></tr></table>');
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
