# Copyright (c) 2002-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::JobBase;
use strict;
use Bivio::Base 'Biz.Action';

my($_SENTINEL) = __PACKAGE__ . '.internal_execute';

sub enqueue_task {
    my($proto, $task_id, $attrs, $req) = @_;
    b_use('AgentJob.Dispatcher')->enqueue(
        $req,
        $task_id,
        {
            %{$attrs || {}},
            $_SENTINEL => 1,
        },
    );
    return;
}

sub execute {
    my($proto, $req) = @_;
    die($proto, ': does not implement internal_execute')
        unless $proto->can('internal_execute');
    return $proto->internal_execute($req)
        if $req->unsafe_get($_SENTINEL);
    $proto->enqueue_task($req->get('task_id'), undef, $req);
    my($buffer) = '';
    $req->get('reply')->set_output(\$buffer);
    return 0;
}

sub set_sentinel {
    my(undef, $req) = @_;
    return $req->put($_SENTINEL => 1);
}

1;
