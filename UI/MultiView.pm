# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::MultiView;
use strict;

$Bivio::UI::MultiView::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::MultiView - A view which contains other views.

=head1 EXTENDS

L<Bivio::UI::View>

=cut

use Bivio::UI::View;
@Bivio::UI::MultiView::ISA = qw(Bivio::UI::View);

=head1 DESCRIPTION

C<Bivio::UI::MultiView> is an abstract html rendering view which
houses many other views. Only one view may be active at any time. Allows
drawing a menu bar which shows all the available views.

=cut

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(array views) : Bivio::UI::MultiView

Creates a new MultiView with the specified sub views.

=head2 static new(array views, Menu menu) : Bivio::UI::MultiView

Creates a MultiView with the specified sub views, and menu.

=cut

sub new {
    my($proto, $views, $menu) = @_;
    my($self) = &Bivio::UI::View::new($proto);
    $self->{$_PACKAGE} = {
	'views' => $views,
	'menu' => $menu,
	'active_view' => undef
    };
    my($view);
    foreach $view (@$views) {
	$view->set_parent($self);
    }
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_active_view"></a>

=head2 get_active_view() : View

Returns the active view. The active view is set by invoking
L<Bivio::UI::View/"activate"> method on a child view.

=cut

sub get_active_view {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{active_view};
}

=for html <a name="get_menu"></a>

=head2 get_menu() : Menu

Returns the menu of sub views. If no menu exists, then undef is returned.

=cut

sub get_menu {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{menu};
}

=for html <a name="get_views"></a>

=head2 get_views() : array

Returns an array of sub views. The array is copied and not the internal
value.

=cut

sub get_views {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    #copies into a new array
    my(@result) = @{$fields->{views}};
    return \@result;
}

=for html <a name="set_active_view"></a>

=head2 set_active_view(View v) : MultiView

Sets the specified child view as active. Returns the root of the view
tree. This method is used internally during view activation and should
not be called directly - see L<Bivio::UI::View/"activate">.

=cut

sub set_active_view {
    my($self, $view) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{active_view} = $view;
    return $self->activate();
}


#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
