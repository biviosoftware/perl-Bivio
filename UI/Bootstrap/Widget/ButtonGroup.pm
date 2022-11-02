# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Bootstrap::Widget::ButtonGroup;
use strict;
use Bivio::Base 'XHTMLWidget.Tag';
b_use('UI.ViewLanguageAUTOLOAD');


sub NEW_ARGS {
    return [qw(items)];
}

sub initialize {
    my($self) = @_;
    my($items) = $self->get('items');
    return shift->put(
        tag => 'div',
        value => ref($items) eq 'ARRAY' ? Join($items) : $items,
        class => $self->internal_class_with_additional('btn-group'),
    );
}

1;
