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

#TODO: This needs to be coupled with the actual task's uri, not the constant here
sub format_email_for_auth_realm {
    my($proto, $req) = @_;
    return $req->format_email(
	$proto->TASK_URI
        . '.'
	. $req->req(qw(auth_realm owner name)),
    );
}


1;
