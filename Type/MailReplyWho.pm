# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::MailReplyWho;
use strict;
use Bivio::Base 'Type.Enum';


__PACKAGE__->compile([
    AUTHOR => 1,
    ALL => 2,
    REALM => 3,
]);

1;
