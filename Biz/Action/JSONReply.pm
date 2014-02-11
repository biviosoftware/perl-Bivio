# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::JSONReply;
use strict;
use Bivio::Base 'Action.EmptyReply';
b_use('IO.ClassLoaderAUTOLOAD');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_api {
    my($proto, $req, $status) = @_;
    return $proto->execute($req, $status || 'BAD_REQUEST');
}

sub execute_check_req_is_json {
    my($proto, $req, $else) = @_;
    return $req->if_req_is_json(
	sub {
	    my($t) = $req->get('task_id')->get_name;
	    return $proto->execute_api(
		$req,
		$t =~ /FORBIDDEN/ ? 'FORBIDDEN'
		    : $t =~ /NOT_FOUND/ ? 'NOT_FOUND'
		    : 'BAD_REQUEST',
	    );
	},
	$else || 0,
    );
}

sub execute_javascript_log_error {
    my($proto, $req) = @_;
    $req->warn('javascript error')
	if $req->get_form;
    return $proto->execute($req, 'HTTP_OK');
}

1;
