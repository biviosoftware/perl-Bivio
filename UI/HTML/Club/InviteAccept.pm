# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::InviteAccept;
use strict;
$Bivio::UI::HTML::Club::InviteAccept::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::InviteAccept - user accepts invite to club

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::InviteAccept;
    Bivio::UI::HTML::Club::InviteAccept->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::PageForm;
@Bivio::UI::HTML::Club::InviteAccept::ISA = ('Bivio::UI::HTML::PageForm');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::InviteAccept> allows user to accept
invitation to join this club.

=cut

#=IMPORTS
use Bivio::Biz::Model::ClubInviteAcceptForm;
use Bivio::UI::HTML::Club::Page;
use Bivio::UI::HTML::Page;
use Bivio::UI::HTML::PageForm;
use Bivio::UI::HTML::Widget::String;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="create_fields"></a>

=head2 create_fields() : array_ref

Create Grid I<values> for this form.

=cut

sub create_fields {
    return [],
}

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Sets attributes on I<req> and calls
L<Bivio::UI::HTML::Club::Page::execute|Bivio::UI::HTML::Club::Page/"execute">.

=cut

sub execute {
    my($self, $req) = @_;
    $req->put(page_heading => 'Accept Invitation',
	    page_subtopic => 'Accept Invitation',
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
    $self->put(form_model => ['Bivio::Biz::Model::ClubInviteAcceptForm']);
    my($join) = $self->get('value')->get('values');
    unshift(@$join, 'You have been invited to join ',
	    Bivio::UI::HTML::Widget::String->new({
		value => ['auth_realm', 'owner', 'display_name'],
	    }),
	    '<p>Do you accept this invitation?<p>');
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
