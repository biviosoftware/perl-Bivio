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
	    ['RealmInvite.email', undef, <<'EOF',
Enter the email address of the Guest you would like to invite.
This person will receive an invitation via email to join your club
as a Guest.  The message will contain a link (URL) to click
on.  The Guest must register as a bivio user, if they aren't one
already.
EOF
		     'betsy@myisp.com, johnqpublic@aol.com'],
    ],
    {
	header => $self->join(<<'EOF',
Use this form to invite a Guest to your club.  A Guest is not
a legal partner of your club.  If the person you would like
to add is a partner,
EOF
		$self->link('use the Add Member form instead',
			'CLUB_ADMIN_ADD_MEMBER'),
		".\n",
		<<'EOF',
<p>
Guests have limited privileges.  They can
view the club's data and member personal data (except social security
numbers), but they
cannot upload files and they do not receive messages sent to
your club.  Guests cannot buy units in your club.
EOF
		       ),
    });
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
