# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::InviteGuest;
use strict;
$Bivio::UI::HTML::Club::InviteGuest::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::InviteGuest - invite a guest

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::InviteGuest;
    Bivio::UI::HTML::Club::InviteGuest->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::DescriptivePage>

=cut

use Bivio::UI::HTML::DescriptivePage;
@Bivio::UI::HTML::Club::InviteGuest::ISA = ('Bivio::UI::HTML::DescriptivePage');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::InviteGuest> invite a guest

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="create_content"></a>

=head2 create_content()

Returns the form.

=cut

sub create_content {
    my($self) = @_;
    $self->put_heading('CLUB_ADMIN_INVITE_GUEST');
    return $self->form('InviteGuestForm', [
	    ['RealmInvite.email', 'Email', <<'EOF', 'bob747@aol.com'],
Enter the email address of the guest.
EOF
    ],
    {
	header => 'Use this form to invite a guest user to the club.',
    });
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
