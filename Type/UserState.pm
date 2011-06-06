# Copyright (c) 2000-2011 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::UserState;
use strict;
use Bivio::Base 'Type.Enum';

# Type.UserState identifies what type of user we have:
#
# JUST_VISITOR
#
# Not a user as far as we know.
#
# LOGGED_OUT
#
# User is not logged in
#
# LOGGED_IN
#
# User is logged in

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
__PACKAGE__->compile([
    JUST_VISITOR => [1],
    LOGGED_OUT => [2],
    LOGGED_IN => [3],
]);

1;
