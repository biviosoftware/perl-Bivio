# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Bootstrap::Widget::ButtonGroup;
use strict;
use Bivio::Base 'XHTMLWidget.Tag';
b_use('UI.ViewLanguageAUTOLOAD');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub NEW_ARGS {
    return [qw(items)];
}

sub initialize {
    my($self) = @_;
    my($items) = $self->get('items');
    return shift->put(
	tag => 'div',
	value => ref($items) eq 'ARRAY' ? Join($items) : $items,
	class => $self->internal_with_additional_classes('btn-group'),
    );
}

1;
