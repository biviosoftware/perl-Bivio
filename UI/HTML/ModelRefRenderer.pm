# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::ModelRefRenderer;
use strict;
$Bivio::UI::HTML::ModelRefRenderer::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::ModelRefRenderer - renders MODEL_REF types

=head1 SYNOPSIS

    use Bivio::UI::HTML::ModelRefRenderer;
    my($mr) = Bivio::UI::HTML::ModelRefRenderer->new($task_id);
    $mr->render([$id, 'To be or not to be...'], $req);

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

Creates a new model reference renderer. The task_id
will be taken from the request at the time of rendering.

=head2 static new(Bivio::Agent::TaskId task_id) : Bivio::UI::HTML::ModelRefRenderer

Creates a new model reference renderer. The task_id will be the specified
value.

=cut

sub new {
    my($proto, $task_id) = @_;
    my($self) = &Bivio::UI::Renderer::new($proto);
#TODO: Should $path be an array?
    $self->{$_PACKAGE} = {
	task_id => $task_id,
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

    my($query) = $model_ref->[0];
    my($text) = $model_ref->[1];
#TODO: HACK.  Set in Model::MailMessageList.  Needs to be passed in elsewhere
    my($task_id) = $query->{task_id};
    delete $query->{task_id};

    # view_name or controller_name fields may be null

    $req->get_reply()->print('<a href="'
	    .$req->format_uri($task_id, $query)
	    .'">'.$text.'</a>');
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
