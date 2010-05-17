# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::DropDown;
use strict;
use Bivio::Base 'Widget.Join';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
        values => [
            Script('common'),
            Script('b_drop_down'),
            A(Join([
                $self->get('label'),
                SPAN_dd_arrow(vs_text_as_prose('drop_down_arrow')),
            ]), {
                HREF => '#',
                class => $self->get('class'),
            }),
            $self->get('widget')->put_unless_exists(class => 'b_dd_menu b_hide'),
        ]);
    return shift->SUPER::initialize(@_);
}

sub internal_new_args {
    my(undef, $label, $widget, $attributes) = @_;
    return {
	label => $label,
	widget => $widget,
        class => 'b_dd_link',
	($attributes ? %$attributes : ()),
    };
}

1;
