# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::DateRenderer;
use strict;
$Bivio::UI::DateRenderer::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::DateRenderer - a date string renderer

=head1 SYNOPSIS

    use Bivio::UI::DateRenderer;
    my($renderer) = Bivio::UI::DateRenderer->new();
    $renderer->render('01/25/1999', $req);   # prints '1/25/99'

=cut

=head1 EXTENDS

L<Bivio::UI::Renderer>

=cut

use Bivio::UI::Renderer;
@Bivio::UI::DateRenderer::ISA = qw(Bivio::UI::Renderer);

=head1 DESCRIPTION

C<Bivio::UI::DateRenderer> takes a date in MM/DD/YYYY and renderers it
as MM/DD/YY without leading 0s.

=cut

#=IMPORTS
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::DateRenderer

Creates a new Date renderer.

=cut

sub new {
    my($self) = &Bivio::UI::Renderer::new(@_);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="render"></a>

=head2 render(string date, Request req)

Writes the date as MM/DD/YY with no leading zeros.

=cut

sub render {
    my($self, $date, $req) = @_;
    my($d, $m, $y) = (gmtime($date))[3,4,5];
    $req->print(sprintf('%02d/%02d/%02d', ++$m, $d, $y));
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
