# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::StringRenderer;
use strict;
$Bivio::UI::StringRenderer::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::UI::StringRenderer - simple string drawer

=head1 SYNOPSIS

    use Bivio::UI::StringRenderer;
    Bivio::UI::StringRenderer->new();

=cut

=head1 EXTENDS

L<Bivio::UI::Renderer>

=cut

@Bivio::UI::StringRenderer::ISA = qw(Bivio::UI::Renderer);

=head1 DESCRIPTION

C<Bivio::UI::StringRenderer>

=cut

=head1 CONSTANTS

=cut

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::StringRenderer

Creates a StringRenderer.

=cut

sub new {
    my($self) = &Bivio::UI::Renderer::new(@_);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="render"></a>

=head2 render(UNIVERSAL target, Request req)

Draws the target string onto the request output stream.

=cut

sub render {
    my($self, $str, $req) = @_;
    $req->print($str);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
