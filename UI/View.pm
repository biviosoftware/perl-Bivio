# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::View;
use strict;

$Bivio::UI::View::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::View - Abstract base class of model renderers.

=head1 SYNOPSIS

    # get a model from a view
    my($model) = $view->get_default_model();

    # do something with the model
    $model->get_action($req->get_action_name())->execute($model, $req);

    # brings a view to the front and renders a model
    $view->activate()->render($model, $req);

=cut

=head1 EXTENDS

L<Bivio::UI::Renderer>

=cut

use Bivio::UI::Renderer;
@Bivio::UI::View::ISA = qw(Bivio::UI::Renderer);

=head1 DESCRIPTION

C<Bivio::UI::View> is a model renderer. They are responsible for drawing
a model's state in an intelligent manner. A view is not specific to HTML,
it could apply to text or image output as well. Views may be nested within
other views (L<Bivio::UI::MultiView>). Views have a name which is used
for lookup by L<Bivio::Agent::Controller>s.

=cut

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string name) : Bivio::UI::View

Creates a view with the specified name.

=cut

sub new {
    my($proto, $name) = @_;
    my($self) = &Bivio::UI::Renderer::new($proto);

    $self->{$_PACKAGE} = {
        name => $name,
        parent => undef
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="activate"></a>

=head2 activate() : View

Prepares this view for renderering by bringing it and its parent view
to the top layer. Returns the root of the view tree.

=cut

sub activate {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($parent) = $fields->{parent};
    if (defined($parent)) {
	return $parent->set_active_view($self);
    }
    return $self;
}

=for html <a name="get_default_model"></a>

=head2 get_default_model() : Model

Returns the model to use if none has been specified. By default, this
method returns undef, indicating no default model exists.

=cut

sub get_default_model {
    return undef;
}

=for html <a name="get_name"></a>

=head2 get_name() : string

Returns this view's name.

=cut

sub get_name {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{name};
}

=for html <a name="set_parent"></a>

=head2 set_parent(MultiView parent)

Sets the parent view of this one. Don't call this method directory, it
is called when you create a container for this view. A view may only
have one parent. see L<Bivio::UI::MultiView>.

=cut

sub set_parent {
    my($self, $parent) = @_;
    my($fields) = $self->{$_PACKAGE};

    if ($fields->{parent}) {
	die('view '.$self->get_name().' already parented');
    }
    $fields->{parent} = $parent;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
