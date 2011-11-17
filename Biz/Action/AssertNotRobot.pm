# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::AssertNotRobot;
use strict;
use Bivio::Base 'Biz.Action';
use Bivio::DieCode;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute {
    my($proto, $req) = @_;
    return if $req->ureq('auth_user_id');
    return unless $req->ureq('Type.UserAgent');
    Bivio::DieCode->FORBIDDEN->throw_die('Assert not robot')
	if $req->req('Type.UserAgent')->is_robot;
    return;
}

1;
