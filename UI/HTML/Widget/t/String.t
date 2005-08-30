# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test::Widget;
use Bivio::UI::HTML::Widget::Tag;
Bivio::Test::Widget->unit(
    'Bivio::UI::HTML::Widget::String',
    [
	['s'] => 's',
	['s', 'page_text'] => '<font face="arial,sans-serif">s</font>',
	[_t('p', 's')] => '<p>s</p>',
	[_t('p', 's'), 'string_test1'] => '<font class="string_test1"><p>s</p></font>',
    ],
);
sub _t {
    return Bivio::UI::HTML::Widget::Tag->new(@_);
}

