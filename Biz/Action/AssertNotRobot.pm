# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::AssertNotRobot;
use strict;
use Bivio::Base 'Biz.Action';
use Bivio::DieCode;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute {
    my($proto, $req) = @_;
    return
	if $req->ureq('auth_user_id');
    return
	unless my $ua = $req->ureq('Type.UserAgent');
    Bivio::DieCode->NOT_FOUND->throw_die('Assert not robot')
	if $ua->is_robot;
    return;
}

1;
