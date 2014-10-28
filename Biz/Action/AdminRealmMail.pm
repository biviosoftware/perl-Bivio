# Copyright (c) 2010-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::AdminRealmMail;
use strict;
use Bivio::Base 'Action.RealmMail';


sub EMAIL_LIST {
    return 'RealmAdminEmailList';
}

sub TASK_URI {
    return 'admin';
}

sub want_realm_mail_created {
    return 0;
}

sub want_reply_to {
    return 0;
}

1;
