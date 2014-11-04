# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Bootstrap::Widget::DropDown;
use strict;
use Bivio::Base 'XHTMLWidget.Tag';
use Bivio::UI::ViewLanguageAUTOLOAD;


sub NEW_ARGS {
    return [qw(label widget)];
}

sub initialize {
    my($self) = @_;
    return shift->put_unless_exists(
	class => 'dropdown',
	tag => 'li',
	value => Join([
	    A(Join([
		$self->get('label'),
		$self->unsafe_get('no_arrow')
		    ? ()
		    : (' ', B('', 'caret')),
	    ]), {
		class => $self->unsafe_get('toggle_class') || 'dropdown-toggle',
		HREF => '#',
		'DATA-TOGGLE' => 'dropdown',
	    }),
	    $self->get_nested('widget')->put(
		tag => 'ul',
		class => 'dropdown-menu',
	    ),
	]),
    )->SUPER::initialize(@_);
}

sub new {
    return shift->SUPER::new(@_)->put_unless_exists(
	task_menu_no_wrap => 1,
    );
}

1;
