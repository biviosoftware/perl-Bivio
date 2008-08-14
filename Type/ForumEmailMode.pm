# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::ForumEmailMode;
use strict;
use Bivio::Base 'Type.Enum';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

__PACKAGE__->compile([
    UNKNOWN => [0, 'Select Option'],
    DEFAULT => [1, 'Forum Members'],
    ADMIN_ONLY_FORUM_EMAIL => [2, 'Forum Administrators'],
    SYSTEM_USER_FORUM_EMAIL => [3, 'Any User'],
    PUBLIC_FORUM_EMAIL => [4, 'Anyone'],
]);

sub OPTIONAL_MODES {
    return qw(admin_only_forum_email system_user_forum_email
	      public_forum_email);
}

1;
