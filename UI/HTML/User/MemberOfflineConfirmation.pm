# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::User::MemberOfflineConfirmation;
use strict;
$Bivio::UI::HTML::User::MemberOfflineConfirmation::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::User::MemberOfflineConfirmation::VERSION;

=head1 NAME

Bivio::UI::HTML::User::MemberOfflineConfirmation - Displays confirmation

=head1 SYNOPSIS

    use Bivio::UI::HTML::User::MemberOfflineConfirmation;

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::DescriptivePage>

=cut

use Bivio::UI::HTML::DescriptivePage;
@Bivio::UI::HTML::User::MemberOfflineConfirmation::ISA = ('Bivio::UI::HTML::DescriptivePage');

=head1 DESCRIPTION

C<Bivio::UI::HTML::User::MemberOfflineConfirmation> explains that the user
has taken him/herself offline from a club and links to help topics about how to
get back on.

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="create_content"></a>

=head2 create_content() : BIVIO::UI::HTML::Widget::Director

Displays confirmation that user took self offline.

=cut

sub create_content {
    my($self) = @_;
    $self->put_heading('MEMBER_OFFLINE_CONFIRMATION');
    return $self->template_as_string(<<'EOF', 'page_text');
<p>
You have successfully taken yourself offline for this club.
EOF
}

#=PRIVATE METHODS


=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 Version

$Id$

=cut

1;
