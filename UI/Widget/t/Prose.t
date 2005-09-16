# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test::Widget;
Bivio::Test::Widget->unit(
    'Bivio::UI::Widget::Prose',
    [
	[''] => '',
	['a'] => 'a',
	[q{a-Join(['b']);-c}] => 'a-b-c',
    ],
);
