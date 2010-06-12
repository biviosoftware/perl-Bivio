# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::RealmMailBase;
use strict;
use Bivio::Base 'Biz.Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_M) = b_use('Biz.Model');

sub format_email_for_realm {
    my($proto, $req_or_realm) = @_;
    my($realm, $req) = $_M->is_blessed($req_or_realm)
	? ($req_or_realm, $req_or_realm->req)
	: ($req_or_realm->req(qw(auth_realm owner)), $req_or_realm);
    return $req->format_email(
#TODO: This needs to be coupled with the actual task's uri, not the constant here
	($proto->TASK_URI ? $proto->TASK_URI . '.' : '')
	    . $realm->get('name'),
    );
}

1;
