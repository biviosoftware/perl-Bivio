# Copyright (c) 2002-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::EmptyReply;
use strict;
use Bivio::Base 'Biz.Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
__PACKAGE__->use('Agent.Task')->register(__PACKAGE__);
my($_AC) = __PACKAGE__->use('Ext.ApacheConstants');
my($_BA) = __PACKAGE__->use('Action.BasicAuthorization');

sub execute {
    my($proto, $req, $status, $output) = @_;
    $status ||= 'HTTP_OK';
    $status = 'NOT_FOUND'
	if $status =~ /NOT_FOUND/;
    my($reply) = $req->get('reply')->set_http_status($_AC->$status());
    return
	if $reply->unsafe_get_output;
    $output ||= '';
    $reply->set_output(\$output);
    return 1;
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

sub execute_server_error {
    return shift->execute(shift, 'SERVER_ERROR');
}

sub execute_task_item {
    my($self, $error, $req) = @_;
    return $error =~ /^execute/ ? $self->$error($req)
	: $self->execute($req, uc($error));
}

sub handle_pre_auth_task {
    my($proto, $task, $req) = @_;
    return $_BA->execute($req)
	if $task->get('id')->get_name =~ /^BOT_/;
    return;
}

1;
