# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::General::InviteNotFound;
use strict;
$Bivio::UI::HTML::General::InviteNotFound::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::General::InviteNotFound - realm invite not found

=head1 SYNOPSIS

    use Bivio::UI::HTML::General::InviteNotFound;
    Bivio::UI::HTML::General::InviteNotFound->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget::Join>

=cut

use Bivio::UI::HTML::PageError;
@Bivio::UI::HTML::General::InviteNotFound::ISA = ('Bivio::UI::HTML::PageError');

=head1 DESCRIPTION

C<Bivio::UI::HTML::General::InviteNotFound> renders a "we're sorry"
message when the realm invite isn't found.

=cut

#=IMPORTS

#=VARIABLES


=head1 METHODS

=cut

=for html <a name="create_error_content"></a>

=head2 create_error_content()

Create the message.

=cut

sub create_error_content {
#TODO: Generate 7 days from common configuration.
    return (<<'EOF');
You have responded to an invitation to join a bivio investment club.
Unfortunately, the invitation was not found.  Invitations expire
after 7 days.  It may be that your invitation has expired.
EOF
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
