# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::General::SubstituteUser;
use strict;
$Bivio::UI::HTML::General::SubstituteUser::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::General::SubstituteUser - authenticate a user

=head1 SYNOPSIS

    use Bivio::UI::HTML::General::SubstituteUser;
    Bivio::UI::HTML::General::SubstituteUser->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::PageForm;
@Bivio::UI::HTML::General::SubstituteUser::ISA = ('Bivio::UI::HTML::PageForm');

=head1 DESCRIPTION

C<Bivio::UI::HTML::General::SubstituteUser> allows you to login
to another user without a password.

=cut

#=IMPORTS
use Bivio::Biz::Model::SubstituteUserForm;
use Bivio::UI::HTML::General::Page;
use Bivio::Util;

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
	[$self->add_field('login', 'User', 20)],
    ];
}

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Sets attributes on I<req> and calls
L<Bivio::UI::HTML::General::Page::execute|Bivio::UI::HTML::User::General/"execute">.

=cut

sub execute {
    my($self, $req) = @_;
    $req->put(page_topic => 'Substitute User', page_content => $self);
    Bivio::UI::HTML::General::Page->execute($req);
    return;
}

=for html <a name="initialize"></a>

=head2 initialize()

Sets attributes on self used by SUPER.

=cut

sub initialize {
    my($self) = @_;
    $self->put(form_model => ['Bivio::Biz::Model::SubstituteUserForm']);
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
