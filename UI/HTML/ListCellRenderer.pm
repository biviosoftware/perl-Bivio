# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::ListCellRenderer;
use strict;
$Bivio::UI::HTML::ListCellRenderer::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::UI::HTML::ListCellRenderer - a list cell renderer

=head1 SYNOPSIS

    use Bivio::UI::HTML::ListCellRenderer;
    Bivio::UI::HTML::ListCellRenderer->new();

=cut

=head1 EXTENDS

L<Bivio::UI::Renderer>

=cut

use Bivio::UI::Renderer;
@Bivio::UI::HTML::ListCellRenderer::ISA = qw(Bivio::UI::Renderer);

=head1 DESCRIPTION

C<Bivio::UI::HTML::ListCellRenderer> renders an object within an HTML <td>
element.

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::IO::Config;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Renderer inner) : Bivio::UI::HTML::ListCellRenderer

Creates a List Cell element which wraps the specified renderer.

=head2 static new(Renderer inner, string attributes) : Bivio::UI::HTML::ListCellRenderer

Creates a List Cell element which wraps the specified renderer and includes
additional html cell attributes.

=cut

sub new {
    my($proto, $inner, $attributes) = @_;
    my($self) = &Bivio::UI::Renderer::new($proto);
    $self->{$_PACKAGE} = {
	inner => $inner,
	attributes => $attributes
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="render"></a>

=head2 render(ANY target, Request req)

Draws this cell and its inner renderer onto the request output stream.
The target is passed on to the inner renderer.

=cut

sub render {
    my($self, $target, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($str) = '<td';
    if ($fields->{attributes}) {
	$str .= ' '.$fields->{attributes};
    }
    $req->print($str.'><small>');
    $fields->{inner}->render($target, $req);
    $req->print('</small></td>');
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
