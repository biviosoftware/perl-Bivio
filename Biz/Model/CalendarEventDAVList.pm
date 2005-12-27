# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CalendarEventDAVList;
use strict;
use base 'Bivio::Biz::Model::AnyTaskDAVList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub LOAD_ALL_SIZE {
    return 5000;
}

sub dav_is_read_only {
    return 0;
}

1;
