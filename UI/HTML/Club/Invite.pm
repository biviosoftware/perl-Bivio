# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::Invite;
use strict;
$Bivio::UI::HTML::Club::Invite::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::Invite - invites a new user to the club

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::Invite;
    Bivio::UI::HTML::Club::Invite->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::PageForm;
@Bivio::UI::HTML::Club::Invite::ISA = ('Bivio::UI::HTML::PageForm');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::Invite> invite a new user to a club.

=cut

#=IMPORTS
use Bivio::Biz::Model::ClubInviteForm;
use Bivio::Biz::Model::RealmUser;
use Bivio::Type::ClubUserTitle;
use Bivio::TypeValue;
use Bivio::UI::HTML::Club::Page;
use Bivio::UI::HTML::Page;
use Bivio::UI::HTML::PageForm;
use Bivio::UI::HTML::Widget::Select;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="create_fields"></a>

=head2 create_fields() : array_ref

Create Grid I<values> for this form.

=cut

sub create_fields {
    my($self) = @_;
    return [
	[$self->add_field('RealmInvite.email', 'email', 30)],
	[$self->add_field('title', 'Privileges',
		Bivio::UI::HTML::Widget::Select->new({
		    field => 'title',
		    choices => 'Bivio::Type::ClubUserTitle',
		}))],
    ];
}

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Sets attributes on I<req> and calls
L<Bivio::UI::HTML::Club::Page::execute|Bivio::UI::HTML::Club::Page/"execute">.

=cut

sub execute {
    my($self, $req) = @_;
    $req->put(page_heading => 'Invite User',
	    page_subtopic => 'Invite User',
	    page_content => $self);
    Bivio::UI::HTML::Club::Page->execute($req);
    return;
}

=for html <a name="initialize"></a>

=head2 initialize()

Sets attributes on self used by SUPER.

=cut

sub initialize {
    my($self) = @_;
    $self->put(form_model => ['Bivio::Biz::Model::ClubInviteForm']);
    $self->SUPER::initialize;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
