# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::User::EditAddress;
use strict;
$Bivio::UI::HTML::User::EditAddress::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::User::EditAddress - allows the user to update address.

=head1 SYNOPSIS

    use Bivio::UI::HTML::User::EditAddress;
    Bivio::UI::HTML::User::EditAddress->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::PageForm;
@Bivio::UI::HTML::User::EditAddress::ISA = ('Bivio::UI::HTML::PageForm');

=head1 DESCRIPTION

C<Bivio::UI::HTML::User::EditAddress> allows user to update address.

=cut

#=IMPORTS
use Bivio::UI::HTML::Page;
use Bivio::UI::HTML::PageForm;
use Bivio::Biz::Model::AddressForm;
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
	[$self->add_field('Address.street1', 'Street1', 30)],
	[$self->add_field('Address.street2', 'Street2', 30)],
	[$self->add_field('Address.city', 'City', 30)],
	[$self->add_field('Address.state', 'State', 2)],
	[$self->add_field('Address.zip', 'Zip', 15)],
	[$self->add_field('Address.country', 'Country', 2)],
    ];
}

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Sets attributes on I<req> and calls
L<Bivio::UI::HTML::User::Page::execute|Bivio::UI::HTML::User::Page/"execute">.

=cut

sub execute {
    my($self, $req) = @_;
    $req->put(page_heading => 'Change Address',
	    page_subtopic => 'Change Address',
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
    $self->put(form_model => ['Bivio::Biz::Model::AddressForm']);
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
