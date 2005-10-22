# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test::Widget;
use Bivio::UI::Widget::Join;
Bivio::Test::Widget->unit(
    'Bivio::UI::HTML::Widget::Tag',
    [
	['p', '&'] => '<p>&</p>',
	['p', _j('&amp;')] => '<p>&amp;</p>',
	['p', 'x', 'foo'] => '<p class="foo">x</p>',
    ],
);

sub _j {
    return Bivio::UI::Widget::Join->new([@_]);
}
