# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::BulletinMailMode;
use strict;
use Bivio::Base 'Type.Boolean';


sub ROW_TAG_KEY {
    return 'BULLETIN_MAIL_MODE';
}

sub get_default {
    return 0;
}

sub should_leave_realm {
    return shift->row_tag_get(@_);
}

1;
