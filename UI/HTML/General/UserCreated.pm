# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::General::UserCreated;
use strict;
$Bivio::UI::HTML::General::UserCreated::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::General::UserCreated - acknowledge user registration

=head1 SYNOPSIS

    use Bivio::UI::HTML::General::UserCreated;
    Bivio::UI::HTML::General::UserCreated->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::DescriptivePage>

=cut

use Bivio::UI::HTML::DescriptivePage;
@Bivio::UI::HTML::General::UserCreated::ISA = ('Bivio::UI::HTML::DescriptivePage');

=head1 DESCRIPTION

C<Bivio::UI::HTML::General::UserCreated> acknowledges the registration
and (possibly) implicit acceptance of a club invitation.

=cut


=head1 CONSTANTS

=cut

=for html <a name="PAGE_TOPIC"></a>

=head2 PAGE_TOPIC : string

Returns 'Congratulations'.

=cut

sub PAGE_TOPIC {
    return 'Congratulations';
}

#=IMPORTS
use Bivio::Societas::Biz::Model::RealmInvite;
use Bivio::UI::Widget::Director;
use Bivio::Auth::RealmType;
use Bivio::UI::HTML::Widget::Link;
use Bivio::UI::HTML::ViewShortcuts;

#=VARIABLES
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

=head1 METHODS

=cut

=for html <a name="create_content"></a>

=head2 create_content() : Bivio::UI::Widget::Director

Returns widget which renders this page.

=cut

sub create_content {
    return Bivio::UI::Widget::Director->new({
	control => ['auth_realm', 'type'],
	values => {
	    Bivio::Auth::RealmType::CLUB() => _page_club(),
	},
	default_value => _page_no_club(),
    });
}

#=PRIVATE METHODS

# _page_club() : Bivio::UI::Widget::Join
#
# New user and member of club
#
sub _page_club {
    return $_VS->vs_join([
	_part_congrats(),
    ]);
}

# _page_no_club() : Bivio::UI::Widget::Join
#
# New user, not connected with a club.
#
sub _page_no_club {
    return $_VS->vs_join([
	_part_congrats(),
    ]);
}

# _part_congrats(Bivio::Agent::Request req)
#
# Renders congratulation text.
#
sub _part_congrats {
    return $_VS->vs_join([
	'Congratulations, you are now a bivio user with User ID',
	$_VS->vs_highlight(['auth_user', 'name']),
	".\n<p>A confirmation email has been sent to your email address.\n"
	."<p>People can email you at ",
	$_VS->vs_link($_VS->vs_highlight(['auth_user', '->format_email']),
		['auth_user', '->format_mailto']),
	".\n<p>",
    ]);
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
