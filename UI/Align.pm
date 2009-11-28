# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Align;
use strict;
use Bivio::Base 'Type.Enum';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
__PACKAGE__->compile_with_numbers([qw(
    N
    NE
    E
    SE
    S
    SW
    W
    NW
    CENTER
    LEFT
    RIGHT
    TOP
    BOTTOM
)]);

sub as_html {
    my($proto, $thing) = @_;
    return !$thing ? ''
	: ' class="b_align_' . lc($proto->from_any($thing)->get_name) . '"';
}

1;
