# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::BulletinBodyTemplate;
use strict;
use Bivio::Base 'Type.Boolean';


sub ROW_TAG_KEY {
    return 'BULLETIN_BODY_TEMPLATE';
}

sub get_default {
    return 0;
}

1;
