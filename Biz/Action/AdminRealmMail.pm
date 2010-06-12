# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::AdminRealmMail;
use strict;
use Bivio::Base 'Action.RealmMail';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub ALLOW_REPLY_TO {
    return 0;
}

sub EMAIL_LIST {
    return 'RealmAdminEmailList';
}

sub TASK_URI {
    return 'admin';
}

sub WANT_REALM_MAIL_CREATED {
    return 0;
}

1;
