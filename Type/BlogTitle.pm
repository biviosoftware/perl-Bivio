# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::BlogTitle;
use strict;
use base 'Bivio::Type::Line';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_BC) = Bivio::Type->get_instance('BlogContent');

sub from_content {
    my($self, $content) = @_;
    my($res) = $_BC->split($content);
    return ref($res) ? '(No Title)' : $res;
}

1;
