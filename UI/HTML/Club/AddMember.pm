# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::AddMember;
use strict;
$Bivio::UI::HTML::Club::AddMember::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::AddMember - UI for adding/inviting a member

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::AddMember;
    Bivio::UI::HTML::Club::AddMember->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::DescriptivePage>

=cut

use Bivio::UI::HTML::DescriptivePage;
@Bivio::UI::HTML::Club::AddMember::ISA = ('Bivio::UI::HTML::DescriptivePage');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::AddMember> UI for adding/inviting a member

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
    $self->put_heading('CLUB_ADMIN_ADD_MEMBER');
    return $self->form('AddMemberForm', [
	    ['RealmOwner.display_name', 'Name', <<'EOF', 'Bob Smith'],
Enter the member's full name.  This name will appear in your Roster
and Accounting.  You can update it at any time.
EOF
	    ['RealmInvite.email', 'Email', <<'EOF', 'bob747@aol.com'],
Enter the email for the on-line member.
This person will receive an invitation via email to join your club
as a Member.  The message will contain a link (URL) to click
on.  The Member must register as a bivio user, if they aren't one
already.
EOF
    ],
    {
	header => $self->join(<<'EOF',
Use this form to add a Member to your club.  A member is a
legal partner of your club.
If the person you are inviting
is not a partner,
EOF
		$self->link('use the Invite Guest form instead',
			'CLUB_ADMIN_INVITE_GUEST'),
		".\n",
		<<'EOF',
<p>
There are
two types of members: on-line and off-line.
On-line members have email addresses, can log into bivio
to view the club's books, and receive mail sent to the club's
address.
Off-line members do not have email addresses, cannot
access club data, and cannot be listed as officers.
<p>
Officers can update personal data of all members.  Officers are
responsible for having correct information for members
on club tax forms.
EOF
	   ),
	footer => $self->join(<<'EOF'),
If this is an on-line Member, the next screen will show you that
the Member was invited.
<p>
If this is an off-line Member, the next screen will allow you to
edit the Member's personal data.
EOF
    });
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
