# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Align;
use strict;
use Bivio::Base 'Type.Enum';

b_use('IO.Config')->register(my $_CFG = {
    css_mode => 1,
});
my($_MAP) = _init();

sub as_html {
    my($proto, $thing) = @_;
    return ''
	unless $thing;
    my($name) = $proto->from_any($thing)->get_name;
    return $_CFG->{css_mode}
	? (' class="b_align_' . lc($name) . '"')
	: $_MAP->{$name}->{no_css};
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub _init {
    my($map) = {};
    __PACKAGE__->compile([map(
	{
	    $map->{$_->[0]} = {
		no_css => $_->[3],
	    };
	    ($_->[0], => [$_->[1], $_->[2]]);
	}
	[N => 1, 'north', ' valign="top" align="center"'],
	[NE => 2, 'northeast', ' valign="top" align="right"'],
	[E => 3, 'east', ' align="right"'],
	[SE => 4, 'southeast', ' valign="bottom" align="right"'],
	[S => 5, 'south', ' valign="bottom" align="center"'],
	[SW => 6, 'southwest', ' valign="bottom" align="left"'],
	[W => 7, 'west', ' align="left"'],
	[NW => 8, 'northwest', ' valign="top" align="left"'],
	[CENTER => 9, 'center', ' align="center"'],
	[LEFT => 10, 'left', ' align="left"'],
	[RIGHT => 11, 'right', ' align="right"'],
	[TOP => 12, 'top', ' valign="top"'],
	[BOTTOM => 13, 'bottom', ' valign="bottom"'],
    )]);
    return $map;
}

1;
