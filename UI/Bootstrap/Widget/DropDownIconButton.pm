# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Bootstrap::Widget::DropDownIconButton;
use strict;
use Bivio::Base 'XHTMLWidget.Join';
b_use('UI.ViewLanguageAUTOLOAD');


sub initialize {
    my($self) = @_;
    my($items) = $self->get('items');
    return shift->put_unless_exists(values => [
        IconButton(
            $self->get('icon'),
            $self->get('title'),
            {
                $self->unsafe_get('data_edit')
                    ? (data_edit => $self->get('data_edit')) : (),
                additional_value => SPAN_caret(),
                additional_classes => 'btn-dropdown dropdown-toggle',
                'DATA-TOGGLE' => 'dropdown',
            },
        ),
        ref($items) eq 'ARRAY'
            ? UL(
                Join([
                    map(
                        LI($_),
                        @$items,
                    ),
                ]),
                {
                    class => 'dropdown-menu',
                },
            )
            : $items,
    ])->SUPER::initialize(@_);
}

sub internal_new_args {
    my(undef, $icon, $title, $items, $attributes) = @_;
    return {
        icon => $icon,
        title => $title,
        items => $items,
        ($attributes ? %$attributes : ()),
    };
}

1;
