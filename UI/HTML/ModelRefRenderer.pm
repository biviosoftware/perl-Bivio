# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::ModelRefRenderer;
use strict;
$Bivio::UI::HTML::ModelRefRenderer::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::UI::HTML::ModelRefRenderer - renders MODEL_REF types

=head1 SYNOPSIS

    use Bivio::UI::HTML::ModelRefRenderer;
    Bivio::UI::HTML::ModelRefRenderer->new();

=cut

=head1 EXTENDS

L<Bivio::UI::Renderer>

=cut

use Bivio::UI::Renderer;
@Bivio::UI::HTML::ModelRefRenderer::ISA = qw(Bivio::UI::Renderer);

=head1 DESCRIPTION

C<Bivio::UI::HTML::ModelRefRenderer>

=cut

=head1 CONSTANTS

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

=head2 static new(string view_name) : Bivio::UI::HTML::ModelRefRenderer

Creates a new model reference renderer.

=cut

sub new {
    my($proto, $view_name) = @_;
    my($self) = &Bivio::UI::Renderer::new($proto);
    $self->{$_PACKAGE} = {
	view_name => $view_name
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="render"></a>

=head2 render(array model_ref, Request req)

Draws the model ref onto the request's output stream.

=cut

sub render {
    my($self, $model_ref, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    #HACK: must do this better
    my($id) = $model_ref->[0];
    my($text) = $model_ref->[1];

    # <a href="/naic/messages/04697">Re: YahooClubs</a>

    $req->print('<a href="/'.$req->get_target_name()
	    .'/'.$req->get_controller_name()
	    .'/'.$fields->{view_name}
	    .'/?'.$id.'">'.$text.'</a>');
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
