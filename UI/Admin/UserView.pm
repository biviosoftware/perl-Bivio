# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::Admin::UserView;
use strict;
$Bivio::UI::Admin::UserView::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::UI::Admin::UserView - a user editing view

=head1 SYNOPSIS

    use Bivio::UI::Admin::UserView;
    Bivio::UI::Admin::UserView->new();

=cut

=head1 EXTENDS

L<Bivio::UI::View>

=cut

use Bivio::UI::View;
@Bivio::UI::Admin::UserView::ISA = qw(Bivio::UI::View);

=head1 DESCRIPTION

C<Bivio::UI::Admin::UserView>

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Biz::User;
use Bivio::Biz::UserDemographics;
use Bivio::IO::Trace;
use Bivio::UI::HTML::FieldUtil;
use Data::Dumper;

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
    $self->{$_PACKAGE} = {};
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

Creates a form for editing the specified model.

=cut

sub render {
    my($self, $user, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($action);
    my($demographics);
    if ($user->get('id')) {
	$demographics = $user->get_demographics();
	$action = 'update';
    }
    else {
	$demographics = Bivio::Biz::UserDemographics->new();
	$action = 'add';
    }

    $req->print('<table border=0><tr><td>');
    $req->print('<table border=0 cellpadding=0 cellspacing=0>');

    $req->print('<form action='.'/'.$req->get_target_name().'/'
	    .$req->get_controller_name().'/'.$self->get_name().'>');

    $req->print('<input type="hidden" name="ma" value='.$action.'>');
    $req->print('<tr><td rowspan=100 width=15></td></tr>');
    Bivio::UI::HTML::FieldUtil->entry_field($user, 'name', $req, 1);
    Bivio::UI::HTML::FieldUtil->entry_field($user, 'password', $req, 1);

    $req->print('<tr><td>&nbsp;</td></tr>');

    Bivio::UI::HTML::FieldUtil->entry_field($demographics, 'first_name', $req);
    Bivio::UI::HTML::FieldUtil->entry_field($demographics, 'middle_name',$req);
    Bivio::UI::HTML::FieldUtil->entry_field($demographics, 'last_name', $req);
    Bivio::UI::HTML::FieldUtil->entry_field($demographics, 'age', $req);
    Bivio::UI::HTML::FieldUtil->entry_field($demographics, 'gender', $req);

    $req->print('<tr><td>&nbsp;</td></tr>');
    $req->print('<tr><td colspan=2 align=center>'
	    .'<input type="submit" value="OK">&nbsp'
	    .'<input type="submit" value="Cancel">'
	    .'</td></tr>');

    $req->print('</table></form>');
    $req->print('</td></tr></table>');
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
