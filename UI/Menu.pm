# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::Menu;
use strict;

$Bivio::UI::Menu::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::Menu - a menu holder

=head1 SYNOPSIS

    use Bivio::UI::Menu;
    my($menu) = Bivio::UI::Menu->new(1,
	    ['human', 'Human',
	     'cat', 'Cat',
	     'dog', 'Dog']);
    $menu->set_selected('cat');

=cut

use Bivio::UNIVERSAL;
@Bivio::UI::Menu::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::UI::Menu> contains a list of menu names and display names. It
tracks which menu item is currently selected. Menus may either be top-level
or sub menus.

=cut

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(boolean top, array items) : Bivio::UI::Menu

Creates a new menu from an array of (name, display_name) pairs. If top
is true, then it is a top-level menu, otherwise it is a sub menu.

=cut

sub new {
    my($proto, $top, $items) = @_;
    my($self) = &Bivio::UNIVERSAL::new($proto);
    $self->{$_PACKAGE} = {
	'top' => $top,
	'items' => $items,
	'selected' => undef
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_display_names"></a>

=head2 get_display_names() : array

Returns the display names of all the items.

=cut

sub get_display_names {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my(@result);
    my($items) = $fields->{items};

    for (my($i) = 1; $i < int(@$items); $i += 2 ) {
	push(@result, $items->[$i]);
    }
    return \@result;
}

=for html <a name="get_names"></a>

=head2 get_names() : array

Returns the names of all the items.

=cut

sub get_names {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my(@result);
    my($items) = $fields->{items};

    for (my($i) = 0; $i < int(@$items); $i += 2 ) {
	push(@result, $items->[$i]);
    }
    return \@result;
}

=for html <a name="get_selected"></a>

=head2 get_selected() : string

Returns the name of the selected item.

=cut

sub get_selected {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{selected};
}

=for html <a name="is_top"></a>

=head2 is_top() : boolean

Returns whether the menu is top level, or a submenu.

=cut

sub is_top {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{top};
}

=for html <a name="set_selected"></a>

=head2 set_selected(string name)

Sets the currently selected item.

=cut

sub set_selected {
    my($self, $name) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{selected} = $name;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
