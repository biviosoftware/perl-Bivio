# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::General::NoResources;
use strict;
$Bivio::UI::HTML::General::NoResources::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::General::NoResources - NoResources access

=head1 SYNOPSIS

    use Bivio::UI::HTML::General::NoResources;
    Bivio::UI::HTML::General::NoResources->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget::Join>

=cut

use Bivio::UI::HTML::PageError;
@Bivio::UI::HTML::General::NoResources::ISA = ('Bivio::UI::HTML::PageError');

=head1 DESCRIPTION

C<Bivio::UI::HTML::General::NoResources> renders a "we're sorry"
message when the page is NoResources.

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
    return (<<'EOF');
We're sorry, but you have reached your file storage limit.
EOF
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
