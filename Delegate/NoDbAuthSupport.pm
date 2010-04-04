# Copyright (c) 2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Delegate::NoDbAuthSupport;
use strict;
use Bivio::Base 'Bivio::Delegate';

# C<Bivio::Delegate::NoDbAuthSupport> provides support for authenication
# without a database.  Always grants permissions to the user.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub load_permissions {
    # (self) : Auth.PermissionSet
    # All permissions are true.
    return Bivio::Auth::PermissionSet->get_max;
}

sub task_permission_ok {
    # (self) : boolean
    # Returns true always.
    return 1;
}

sub unsafe_get_user_pref {
    # (proto) : boolean
    # No database, so no preferences.
    return 0;
}

1;
