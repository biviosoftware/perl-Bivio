# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Align;
use strict;
use Bivio::Base 'Type.Enum';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
b_use('IO.Config')->register(my $_CFG = {
    css_mode => 1,
});
__PACKAGE__->compile([
    'N' => [
	1,
	'north',
	' valign="top" align="center"',
    ],
    'NE' => [
	2,
	'northeast',
	' valign="top" align="right"',
    ],
    'E' => [
	3,
	'east',
	' align="right"',
    ],
    'SE' => [
	4,
	'southeast',
	' valign="bottom" align="right"',
    ],
    'S' => [
	5,
	'south',
	' valign="bottom" align="center"',
    ],
    'SW' => [
	6,
	'southwest',
	' valign="bottom" align="left"',
    ],
    'W' => [
	7,
	'west',
	' align="left"',
    ],
    'NW' => [
	8,
	'northwest',
	' valign="top" align="left"',
    ],
    CENTER => [
	9,
	undef,
	' align="center"',
    ],
    LEFT => [
	10,
	undef,
	' align="left"',
    ],
    RIGHT => [
	11,
	undef,
	' align="right"',
    ],
    TOP => [
	12,
	undef,
	' valign="top"',
    ],
    BOTTOM => [
	13,
	undef,
	' valign="bottom"',
    ],
]);

sub as_html {
    my($proto, $thing) = @_;
    return ''
	unless $thing;
    return $proto->from_any($thing)->get_long_desc
	unless $_CFG->{css_mode};
    return ' class="b_align_' . lc($proto->from_any($thing)->get_name) . '"';
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

1;
