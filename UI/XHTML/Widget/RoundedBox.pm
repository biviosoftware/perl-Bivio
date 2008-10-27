# Copyright (c) 2006-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::RoundedBox;
use strict;
use Bivio::Base 'XHTMLWidget.Tag';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub NEW_ARGS {
    return [qw(value ?class)];
}

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(tag => 'div');
    $self->put_unless_exists(
	class => 'b_rounded_box',
    )->put(
        value => Join([
	    map(EmptyTag(span => "b_rounded_box_body b_rounded_box_$_"), 1..4),
	    Tag('div', $self->get('value'), 'b_rounded_box_body'),
	    map(EmptyTag(span => "b_rounded_box_body b_rounded_box_$_"), reverse(1..4)),
	]),
    );
    return shift->SUPER::initialize(@_);
}

1;

