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
Enter the member's full name.
EOF
	    ['RealmInvite.email', 'Email', <<'EOF', 'bob747@aol.com'],
Optionally, enter the member's email.
EOF
    ],
    {
	header => 'Use this form to add a new club member.',
    });
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
