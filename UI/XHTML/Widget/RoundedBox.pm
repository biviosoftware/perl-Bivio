# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::RoundedBox;
use strict;
use base 'Bivio::UI::Widget::Join';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub new {
    my($self) = shift->SUPER::new(@_);
    return $self->put(
        values => [
	    Tag(div => '', 'top_left'),
	    Tag(div => '', 'top_right'),
	    @{$self->get('values')},
	    Tag(div => '', 'bottom_left'),
	    Tag(div => '', 'bottom_right'),
	],
    );
}

1;
