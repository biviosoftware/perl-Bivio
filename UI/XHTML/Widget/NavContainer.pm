# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::NavContainer;
use strict;
use Bivio::Base 'Widget.Simple';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub NEW_ARGS {
    return [qw(header collapse_items)];
}

sub initialize {
    my($self) = @_;
    my($id) = JavaScript()->unique_html_id;
    return shift->put_unless_exists(value => NAV(DIV_container(Join([
	DIV(Join([
	    BUTTON(Join([
		SPAN('Toggle navigation', 'sr-only'),
		SPAN('', 'icon-bar'),
		SPAN('', 'icon-bar'),
		SPAN('', 'icon-bar'),
	    ]), {
		class => 'navbar-toggle',
		TYPE => 'button',
		'DATA-TOGGLE' => 'collapse',
		'DATA-TARGET' => '#' . $id,
	    }),
	    $self->get('header')->put(class => 'navbar-brand'),
	]), 'navbar-header'),
	DIV($self->get('collapse_items'), 'collapse navbar-collapse', {
	    ID => $id,
	}),
    ])), 'navbar navbar-default navbar-fixed-top'))->SUPER::initialize(@_);
}

1;