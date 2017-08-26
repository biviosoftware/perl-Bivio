# Copyright (c) 2002-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::EmptyReply;
use strict;
use Bivio::Base 'Biz.Action';

my($_AC) = b_use('Ext.ApacheConstants');
b_use('Agent.Task')->register(__PACKAGE__);
b_use('Action.BasicAuthorization');

sub execute {
    my($proto, $req, $status, $output) = @_;
    $status = $status ? uc($status) : 'HTTP_OK';
    $status = 'NOT_FOUND'
	if $status =~ /NOT_FOUND/;
    $status = 'SERVER_ERROR'
	if $status eq 'UPDATE_COLLISION';
    unless ($_AC->can($status)) {
	b_warn($status, ': unknown ApacheConstants method');
	$status = 'SERVER_ERROR';
    }
    my($reply) = $req->get('reply');
    unless ($reply->unsafe_get_output) {
	$output ||= '';
	$reply->set_output(\$output);
	$status = 'HTTP_NO_CONTENT'
	    if $status eq 'HTTP_OK' && !(defined($output) && length($output));
    }
    $reply->set_http_status($_AC->$status);
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
    return ($error || '') =~ /^execute/ ? $self->$error($req)
	: $self->execute($req, uc($error));
}

1;
