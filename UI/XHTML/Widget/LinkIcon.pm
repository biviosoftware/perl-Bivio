# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::LinkIcon;
use strict;
use Bivio::Base 'Widget.Simple';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub NEW_ARGS {
    return ['icon'];
}

sub initialize {
    my($self) = @_;
    return $self->put_unless_exists(value => If(
	[[qw(UI.Facade Text)], '->unsafe_get_value',
	    'icon.' . $self->get('icon')],
	Join([
	    SPAN(
		'',
		Join([
		    'glyphicon ',
		    vs_text('icon.' . $self->get('icon')),
		]),
	    ),
	    ' ',
	]),
    ))->SUPER::initialize(@_);
}

1;
