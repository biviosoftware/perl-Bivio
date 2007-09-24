# Copyright (c) 2002-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::EmptyReply;
use strict;
use base 'Bivio::Biz::Action';
use Bivio::Ext::ApacheConstants;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
Bivio::Agent::Task->register(__PACKAGE__);

sub execute {
    my($proto, $req, $status) = @_;
    $status ||= 'HTTP_OK';
    my($buffer) = '';
    $req->get('reply')
	->set_http_status(Bivio::Ext::ApacheConstants->$status())
	->set_output(\$buffer);
    return 0;
}

sub execute_forbidden {
    return shift->execute(shift, 'FORBIDDEN');
}

sub execute_no_resources {
    return shift->execute(shift, 'HTTP_SERVICE_UNAVAILABLE');
}

sub execute_not_found {
    return shift->execute(shift, 'NOT_FOUND');
}

sub execute_task_item {
    my($self, $error, $req) = @_;
    return $error =~ /^execute/ ? $self->$error($req)
	: $self->execute($req, uc($error));
}

sub handle_pre_auth_task {
    my($proto, $task, $req) = @_;
    return $proto->get_instance('BasicAuthorization')->execute($req)
	if $task->get('id')->get_name =~ /^BOT_/;
    return;
}

1;
