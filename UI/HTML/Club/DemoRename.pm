# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::DemoRename;
use strict;
$Bivio::UI::HTML::Club::DemoRename::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::DemoRename - not allowed to rename demo_club

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::DemoRename;
    Bivio::UI::HTML::Club::DemoRename->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget::Join>

=cut

use Bivio::UI::HTML::PageError;
@Bivio::UI::HTML::Club::DemoRename::ISA = ('Bivio::UI::HTML::PageError');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::DemoRename> renders a "we're sorry"
message if user tries to rename demo_club.

=cut

#=IMPORTS

#=VARIABLES
my($_P) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="create_error_content"></a>

=head2 create_error_content()

Create the message.

=cut

sub create_error_content {
    return (
        "You are not allowed to rename your demo club.  If you would like to ",
	$_P->link('create a new club', 'CLUB_CREATE'),
        " with are another name, you are more than welcome to do so.\n",
    );
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
