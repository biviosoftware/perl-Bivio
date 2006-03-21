# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::RoundedBox;
use strict;
use base 'Bivio::UI::HTML::Widget::Tag';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
	class => 'rounded_box',
    )->put(
        value => Join([
	    Tag(div => '', 'top_left'),
	    Tag(div => '', 'top_right'),
	    Tag(div => $self->get('value'), 'body'),
	    Tag(div => '', 'bottom_left'),
	    Tag(div => '', 'bottom_right'),
	]),
    );
    return shift->SUPER::initialize(@_);
}


sub internal_new_args {
    return shift->SUPER::internal_new_args(div => @_);
}

1;

