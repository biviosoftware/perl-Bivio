# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::User::Password;
use strict;
$Bivio::UI::HTML::User::Password::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::User::Password - allows the user to update password

=head1 SYNOPSIS

    use Bivio::UI::HTML::User::Password;
    Bivio::UI::HTML::User::Password->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::PageForm;
@Bivio::UI::HTML::User::Password::ISA = ('Bivio::UI::HTML::PageForm');

=head1 DESCRIPTION

C<Bivio::UI::HTML::User::Password> allows user to update password

=cut

#=IMPORTS
use Bivio::UI::HTML::Page;
use Bivio::UI::HTML::PageForm;
use Bivio::Biz::Model::PasswordForm;
use Bivio::UI::HTML::User::Page;

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
	[$self->add_field('old_password', 'Old Password', 30)],
	[$self->add_field('new_password', 'New Password', 30)],
	[$self->add_field('confirm_new_password', 'Confirm New', 30)],
    ];
}

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Sets attributes on I<req> and calls
L<Bivio::UI::HTML::User::Page::execute|Bivio::UI::HTML::User::Page/"execute">.

=cut

sub execute {
    my($self, $req) = @_;
    $req->put(page_heading => 'Change Password',
	    page_subtopic => 'Change Password',
	    page_topic => 'Admin',
	    page_content => $self);
    Bivio::UI::HTML::User::Page->execute($req);
    return;
}

=for html <a name="initialize"></a>

=head2 initialize()

Sets attributes on self used by SUPER.

=cut

sub initialize {
    my($self) = @_;
    $self->put(form_model => ['Bivio::Biz::Model::PasswordForm']);
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
