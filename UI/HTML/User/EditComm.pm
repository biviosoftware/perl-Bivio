# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::User::EditComm;
use strict;
$Bivio::UI::HTML::User::EditComm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::User::EditComm - allows the user to update communications info

=head1 SYNOPSIS

    use Bivio::UI::HTML::User::EditComm;
    Bivio::UI::HTML::User::EditComm->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::PageForm;
@Bivio::UI::HTML::User::EditComm::ISA = ('Bivio::UI::HTML::PageForm');

=head1 DESCRIPTION

C<Bivio::UI::HTML::User::EditComm> allows user to update communications info

=cut

#=IMPORTS
use Bivio::UI::HTML::Page;
use Bivio::UI::HTML::PageForm;
use Bivio::Biz::Model::CommForm;
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
	# Keep same order as in AdminInfo
	[$self->add_field('Email.email', 'Email', 30)],
	[$self->add_field('Phone.phone', 'Phone', 30)],
    ];
}

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Sets attributes on I<req> and calls
L<Bivio::UI::HTML::User::Page::execute|Bivio::UI::HTML::User::Page/"execute">.

=cut

sub execute {
    my($self, $req) = @_;
    $req->put(page_heading => 'Change Phone & Email',
	    page_subtopic => 'Change Phone & Email',
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
    $self->put(form_model => ['Bivio::Biz::Model::CommForm']);
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
