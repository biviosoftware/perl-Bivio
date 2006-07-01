# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::BlogBody;
use strict;
use base 'Bivio::Type::BlogContent';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_BT) = Bivio::Type->get_instance('BlogTitle');

sub get_width {
    my($proto) = shift;
    return $proto->SUPER::get_width(@_)
	- $_BT->get_width
	- length($proto->TITLE_PREFIX)
	- 2;
}

1;
