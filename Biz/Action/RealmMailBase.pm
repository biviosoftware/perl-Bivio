# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::RealmMailBase;
use strict;
use Bivio::Base 'Biz.Action';

my($_M) = b_use('Biz.Model');

sub format_email_for_realm {
    my($proto, $req_or_realm) = @_;
    my($realm, $req) = $_M->is_blesser_of($req_or_realm)
	? ($req_or_realm, $req_or_realm->req)
	: ($req_or_realm->req(qw(auth_realm owner)), $req_or_realm);
    return $_M->new($req, 'MailReceiveDispatchForm')
	->format_recipient(
#TODO: This needs to be coupled with the actual task's uri, not the constant here
	    $realm->get('name'),
	    undef,
	    $proto->TASK_URI,
	);
}

sub want_realm_mail_created {
    return 1;
}

sub want_reply_to {
    return 1;
}

1;
