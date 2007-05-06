# Copyright (c) 1999-2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Align;
use strict;
use Bivio::Base 'Bivio::Type::Enum';

# C<Bivio::UI::Align> is a enum of alignment names to html alignment
# values (via C<get_long_desc>).
#
# The alignments and their values are:
#
#
# N (north, top): valign=top align=center
#
# NE (northeast): valign=top align=right
#
# E (east, right): align=right
#
# SE (southeast): valign=bottom align=right
#
# S (south, bottom): valign=bottom align=center
#
# SW (southwest): valign=bottom align=left
#
# W (west, left):
#
# NW (northwest): valign=top align=left
#
# CENTER: align=center
#
# LEFT: align=left
#
# RIGHT: align=right
#
# TOP:  valign=top align=center
#
# BOTTOM: valign=bottom align=center

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
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
    # Returns the alignment in html as C<VALIGN> and C<ALIGN> attributes
    # of C<TD> tag.  Prefixed with leading space.
    #
    # If I<thing> returns false (zero or C<undef>), returns two empty
    # strings.
    return $thing ? $proto->from_any($thing)->get_long_desc : '';
}

1;
