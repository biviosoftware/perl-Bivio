# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::General::Forbidden;
use strict;
$Bivio::UI::HTML::General::Forbidden::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::General::Forbidden - forbidden access

=head1 SYNOPSIS

    use Bivio::UI::HTML::General::Forbidden;
    Bivio::UI::HTML::General::Forbidden->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget::Join>

=cut

use Bivio::UI::HTML::PageError;
@Bivio::UI::HTML::General::Forbidden::ISA = ('Bivio::UI::HTML::PageError');

=head1 DESCRIPTION

C<Bivio::UI::HTML::General::Forbidden> renders a "we're sorry"
message when the page is forbidden.

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
We're sorry, but you do not have privileges to access
this page.  Perhaps you are logged in as the wrong
user?
EOF
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
