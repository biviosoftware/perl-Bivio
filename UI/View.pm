# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::View;
use strict;

$Bivio::UI::View::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::View - Abstract base class of model renderers.

=head1 SYNOPSIS

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

#=IMPORTS
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::View

Creates a view with the specified name.

=cut

sub new {
    my($proto) = @_;
    my($self) = &Bivio::UI::Renderer::new($proto);
    $self->{$_PACKAGE} = {
        'parent' => undef
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
	&_trace('activating parent of ',  $self) if $_TRACE;
	return $parent->set_active_view($self);
    }
    &_trace('activating ',  $self) if $_TRACE;
    return $self;
}

=for html <a name="execute"></a>

=head2 abstract execute(Bivio::Agent::Request req)

Executes the request which involves creating the necessary models,
activating, and rendering through parents.

=cut

sub execute {
    die('abstract method');
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
    die('view already parented') if $fields->{parent};
    &_trace($self, '->parent = ', $parent) if $_TRACE;
    $fields->{parent} = $parent;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
