# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Bootstrap::Widget::IconButton;
use strict;
use Bivio::Base 'XHTMLWidget.Tag';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_AVAILABLE_ICONS) = [
    qw(
        align_center
        align_justify
        align_left
        align_right
        arrow_ccw
        arrow_circle
        arrow_cw
        arrow_left
        arrow_right
        bold
        briefcase
        calendar
        chevron_left
        chevron_right
        cog
        comment
        envelope
        file
        folder_open
        font
        indent
        italic
        link
        list_ol
        list_th
        list_ul
        login
        logout
        megaphone
        outdent
        paperclip
        picture
        search
        strike
        tags
        tasks
        text_height
        thumbs_up
        underline
        unlink
        user
    ),
];

sub NEW_ARGS {
    return [qw(icon title)];
}

sub initialize {
    my($self) = @_;
    return shift->put(
        tag => 'button',
        TYPE => 'button',
        value => SPAN($self->unsafe_get('additional_value') || '', {
            class => 'b_icon_' . _validate_icon($self->get('icon')),
        }),
        class => $self->internal_class_with_additional('btn btn-default'),
        TITLE => $self->get('title'),
        $self->unsafe_get('data_edit')
            ? ('DATA-EDIT' => $self->get('data_edit')) : (),
        UNSELECTABLE => 'on',
    )->SUPER::initialize(@_);
}

sub _validate_icon {
    my($icon) = @_;
    return grep($_ eq $icon, @$_AVAILABLE_ICONS)
        ? $icon : b_die($icon, ': unsupported icon');
}

1;
