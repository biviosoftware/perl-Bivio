# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::ModelRefRenderer;
use strict;
$Bivio::UI::HTML::ModelRefRenderer::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::ModelRefRenderer - renders MODEL_REF types

=head1 SYNOPSIS

    use Bivio::UI::HTML::ModelRefRenderer;
    my($fp) = Bivio::Biz::FindParams->new({id => 120});
    my($mr) = Bivio::UI::HTML::ModelRefRenderer->new();
    $mr->render([$fp->to_string(), 'To be or not to be...'], $req);

=cut

=head1 EXTENDS

L<Bivio::UI::Renderer>

=cut

use Bivio::UI::Renderer;
@Bivio::UI::HTML::ModelRefRenderer::ISA = qw(Bivio::UI::Renderer);

=head1 DESCRIPTION

C<Bivio::UI::HTML::ModelRefRenderer> is a model reference (id, text)
renderer.

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

=head2 static new() : Bivio::UI::HTML::ModelRefRenderer

Creates a new model reference renderer. The controller and view names
will be taken from the request at the time of rendering.

=head2 static new(string view_name) : Bivio::UI::HTML::ModelRefRenderer

Creates a new model reference renderer. The controller name will be taken
from the request at the time of rendering. The view will be the specified
value.

=head2 static new(string view_name, string controller_name) : Bivio::UI::HTML::ModelRefRenderer

Creates a new model reference renderer which will use the specified view
and controller names during rendering.

=cut

sub new {
    my($proto, $view_name, $controller_name) = @_;
    my($self) = &Bivio::UI::Renderer::new($proto);
    $self->{$_PACKAGE} = {
	view_name => $view_name,
	controller_name => $controller_name
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="render"></a>

=head2 render(array model_ref, Request req)

Draws the model ref (id, text) onto the request's output stream.

=cut

sub render {
    my($self, $model_ref, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($id) = $model_ref->[0];
    my($text) = $model_ref->[1];

    # view_name or controller_name fields may be null

    $req->print('<a href="'.$req->make_path($fields->{view_name},
	    $fields->{controller_name}).'?'.$id.'">'.$text.'</a>');
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
