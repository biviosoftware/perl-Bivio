# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::AssertNotRobot;
use strict;
use Bivio::Base 'Biz.Action';


sub execute {
    my($proto, $req) = @_;
    return
        if $req->ureq('auth_user_id');
    return
        unless my $ua = $req->ureq('Type.UserAgent');
    return
        unless $ua->is_robot;
    b_die('NOT_FOUND', 'Assert not robot')
        unless my $rt = $req->req('task')->unsafe_get_attr_as_id('robot_task');
    return {
        method => 'server_redirect',
        task_id => $rt,
        carry_query => 1,
        carry_path_info => 1,
    };
}

1;
