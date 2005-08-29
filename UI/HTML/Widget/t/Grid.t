# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test::Widget;
use Bivio::UI::Widget::Join;
Bivio::Test::Widget->unit(
    'Bivio::UI::HTML::Widget::Grid',
    [
	[[['x']]] => qq{<table border=0 cellpadding=0 cellspacing=0><tr>\n<td>x</td>\n</tr></table>},
	[[['x']], {pad => 2}] => qq{<table border=0 cellpadding=2 cellspacing=0><tr>\n<td>x</td>\n</tr></table>},
	[[['x']], {space => 3}] => qq{<table border=0 cellpadding=0 cellspacing=3><tr>\n<td>x</td>\n</tr></table>},
	[[['x']], {expand => 1}] => qq{<table border=0 cellpadding=0 cellspacing=0 width="100%"><tr>\n<td>x</td>\n</tr></table>},
	[[['x']], {width => 94}] => qq{<table border=0 cellpadding=0 cellspacing=0 width="94"><tr>\n<td>x</td>\n</tr></table>},
	[[['x']], {width => [sub {99}]}] => qq{<table border=0 cellpadding=0 cellspacing=0 width="99"><tr>\n<td>x</td>\n</tr></table>},
	[[['x']], {height => 33}] => qq{<table border=0 cellpadding=0 cellspacing=0 height="33"><tr>\n<td>x</td>\n</tr></table>},
	[[['x']], {style => 'fancy&'}] => qq{<table border=0 cellpadding=0 cellspacing=0 style="fancy&amp;"><tr>\n<td>x</td>\n</tr></table>},
	[[['x']], {id => 'ego'}] => qq{<table border=0 cellpadding=0 cellspacing=0 id="ego"><tr>\n<td>x</td>\n</tr></table>},
	[[['x']], {align => 'N'}] => qq{<table border=0 cellpadding=0 cellspacing=0 valign=top align=center><tr>\n<td>x</td>\n</tr></table>},
	[[['x']], {bgcolor => 'error'}] => qq{<table border=0 cellpadding=0 cellspacing=0 bgcolor="#993300"><tr>\n<td>x</td>\n</tr></table>},
	[[['x']], {background => 'iguana'}] => qq{<table border=0 cellpadding=0 cellspacing=0 background="/i/iguana.gif"><tr>\n<td>x</td>\n</tr></table>},
	[[['x']], {start_tag => 1}] => qq{<table border=0 cellpadding=0 cellspacing=0><tr>\n<td>x</td>\n</tr></table>},
	[[['x']], {start_tag => 1}] => qq{<table border=0 cellpadding=0 cellspacing=0><tr>\n<td>x</td>\n</tr></table>},
	[[['x']], {end_tag => 1}] => qq{<table border=0 cellpadding=0 cellspacing=0><tr>\n<td>x</td>\n</tr></table>},
	[[['x']], {start_tag => 0}] => qq{<tr>\n<td>x</td>\n</tr></table>},
	[[['x']], {end_tag => 0}] => qq{<table border=0 cellpadding=0 cellspacing=0><tr>\n<td>x</td>\n</tr>},
    ],
);

sub _j {
    return Bivio::UI::Widget::Join->new([@_]);
}
