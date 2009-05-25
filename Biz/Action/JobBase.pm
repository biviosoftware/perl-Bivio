# Copyright (c) 2002-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::JobBase;
use strict;
use Bivio::Base 'Biz.Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_SENTINEL) = __PACKAGE__ . '.internal_execute';

sub execute {
    my($proto, $req) = @_;
    die($proto, ': does not implement internal_execute')
	unless $proto->can('internal_execute');
    return $proto->internal_execute($req)
	if $req->unsafe_get($_SENTINEL);
    b_use('AgentJob.Dispatcher')->enqueue(
	$req, $req->get('task_id'), {$_SENTINEL => 1});
    my($buffer) = '';
    $req->get('reply')->set_output(\$buffer);
    return 0;
}

sub set_sentinel {
    my(undef, $req) = @_;
    return $req->put($_SENTINEL => 1);
}

1;
