# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::StringRenderer;
use strict;
$Bivio::UI::StringRenderer::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::StringRenderer - simple text value printer

=head1 SYNOPSIS

    use Bivio::UI::StringRenderer;
    my($renderer) = Bivio::UI::StringRenderer->new();
    $renderer->render('a string', $req);
    $renderer->render(['an', 'array', 'of', 'strings'], $req);

=cut

=head1 EXTENDS

L<Bivio::UI::Renderer>

=cut

@Bivio::UI::StringRenderer::ISA = qw(Bivio::UI::Renderer);

=head1 DESCRIPTION

C<Bivio::UI::StringRenderer> can render simple or compound values as
text onto the request's output stream.

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

=head2 render(scalar target, Request req)

Draws the target scalar or array ref onto the request output stream.

=cut

sub render {
    my($self, $target, $req) = @_;

    my($str);
    if (ref($target) eq 'ARRAY') {

	# print the values separated by ' '
	# can't use split because values may be undef

	$str = '';
	foreach (@$target) {
	    $str .= $_.' ' if defined($_);
	}
	# remove the ' ' if present
	chop($str);
    }
    else {
	$str = $target;
    }
    $req->print($str);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
