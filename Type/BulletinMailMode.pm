# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::BulletinMailMode;
use strict;
use Bivio::Base 'Type.Boolean';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub ROW_TAG_KEY {
    return 'BULLETIN_MAIL_MODE';
}

sub get_default {
    return 0;
}

1;
