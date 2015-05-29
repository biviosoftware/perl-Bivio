# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::MailVisibility;
use strict;
use Bivio::Base 'Type.Enum';

__PACKAGE__->compile([
    UNKNOWN => [0, 'Select who can see mail'],
    ALWAYS_IS_PRIVATE => [1, 'Guests and members can see mail'],
    ALWAYS_IS_PUBLIC => [2, 'Anybody (even non-users) can see mail'],
    ALLOW_IS_PUBLIC => [3, 'Adminstrators can set visibility on each message'],
]);

sub ROW_TAG_KEY {
    return 'MAIL_VISIBILITY';
}

sub get_default {
    return shift->ALWAYS_IS_PRIVATE;
}

1;
