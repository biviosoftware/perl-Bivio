# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::Renderer;
use strict;
use Bivio::UNIVERSAL;
$Bivio::UI::Renderer::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::UI::Renderer - abstract renderer

=cut

@Bivio::UI::Renderer::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::UI::Renderer> is the parent interface of all output renderers.

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::Renderer

=cut

sub new {
    return &Bivio::UNIVERSAL::new(@_);
}

=head1 METHODS

=cut

=for html <a name="render"></a>

=head2 abstract render(ANY target, Request req)

Renders the target onto the Request's print stream. The 'target' parameter
may be a scalar, reference or array type.

=cut

sub render {
    die("abstract method Renderer::render invoked!\n");
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
