# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::ImportedMemberInvite;
use strict;
$Bivio::UI::HTML::Club::ImportedMemberInvite::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::ImportedMemberInvite - invite imported shadow members

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::ImportedMemberInvite;
    Bivio::UI::HTML::Club::ImportedMemberInvite->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::DescriptivePage>

=cut

use Bivio::UI::HTML::DescriptivePage;
@Bivio::UI::HTML::Club::ImportedMemberInvite::ISA = ('Bivio::UI::HTML::DescriptivePage');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::ImportedMemberInvite> invite imported shadow members

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="create_content"></a>

=head2 create_content() : Bivio::UI::HTML::Widget

Returns content widget.

=cut

sub create_content {
    my($self) = @_;
    $self->put_heading('CLUB_LEGACY_INVITE');
    return $self->form('ImportedMemberInviteForm', [], [
	'RealmOwner.display_name',
	['invite_email', 'Email', <<'EOF'],
Fill in this field to bring your members on-line.  We will email
the identified members an invitation to join your club on bivio.
The message will identify you as the author of the invitation.
You will receive a confirmation message each time a member
accept an invitation.
<p>
If you leave this field blank, no invitation will be sent.
You can come back to this page at any time.
EOF
    ],
    {
	header => $self->join(<<'EOF'),
This is the last part of the legacy import process.
<p>
Use this form to bring your off-line members to bivio.
EOF
	footer => $self->join('Send the invitations?'),
    }
    );
}


#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
