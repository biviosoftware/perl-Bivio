# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::Admin::UserListView;
use strict;
$Bivio::UI::Admin::UserListView::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::Admin::UserListView - a list of users

=head1 EXTENDS

L<Bivio::UI::HTML::ListView>

=cut

use Bivio::UI::HTML::ListView;
@Bivio::UI::Admin::UserListView::ISA = qw(Bivio::UI::HTML::ListView);

=head1 DESCRIPTION

C<Bivio::UI::Admin::UserListView> is a view for the
L<Bivio::Biz::UserList> model showing all the members of a club. It exports
one action link to add a new user.

=cut

#=IMPORTS
use Bivio::Biz::UserList;
use Bivio::UI::HTML::Link;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_ADD_LINK) = Bivio::UI::HTML::Link->new( 'add',
	'"/i/new.gif" border=0',
	'', 'Add User', 'Add a new user to the club');
my($_ACTION_LINKS) = [$_ADD_LINK];

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::Admin::UserListView

Creates a user list view.

=cut

sub new {
    my($proto) = @_;
    my($self) = &Bivio::UI::HTML::ListView::new($proto, 'users');
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_action_links"></a>

=head2 get_action_links(Model model, Request req)

Returns the add-user link. This is part of the
L<Bivio::UI::HTML::LinkSupport> interface and is used by the parent
presentation when rendering.

=cut

sub get_action_links {
    my($self, $model, $req) = @_;

    $_ADD_LINK->set_url($req->make_path('user'));

    return $_ACTION_LINKS;
}

=for html <a name="get_default_model"></a>

=head2 get_default_model() : UserList

Returns an instance of the UserList model.

=cut

sub get_default_model {
    return Bivio::Biz::UserList->new();
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
