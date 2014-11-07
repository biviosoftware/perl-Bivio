# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::RoundedBox;
use strict;
use Bivio::Base 'XHTMLWidget.Tag';
use Bivio::UI::ViewLanguageAUTOLOAD;

sub NEW_ARGS {
    return [qw(value ?class)];
}

sub initialize {
    my($self) = @_;
    return if $self->unsafe_get('tag');
    $self->put(
        tag => 'div',
        class => $self->unsafe_get('class')
            ? Join([$self->get('class'), 'b_rounded_box'], ' ')
            : 'b_rounded_box'
        );
    return shift->SUPER::initialize(@_);
}

1;

