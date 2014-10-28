# Copyright (c) 2001-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Delegate::NoDbAuthSupport;
use strict;
use Bivio::Base 'Type.EnumDelegate';


sub clear_model_cache {
    return;
}

sub load_permissions {
    return Bivio::Auth::PermissionSet->get_max;
}

sub task_permission_ok {
    return 1;
}

1;
