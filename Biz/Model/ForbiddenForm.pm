# Copyright (c) 2004 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ForbiddenForm;
use strict;
use Bivio::Base 'Biz.FormModel';


sub execute_empty {
    my($self) = @_;
    my($req) = $self->get_request;
    my($auth_user, $agent) = $req->get('auth_user', 'Type.UserAgent');
    my($reply) = $req->get('reply');
    return 'next'
	unless $agent->is_browser;
    return {
	method => 'server_redirect',
	task_id => 'login_task',
# TODO: figure out why this breaks acceptance test login_as()
# 	task_id => $req->get('user_state')->eq_just_visitor
#             && $req->get('task')->unsafe_get('register_task')
#             || 'login_task',
	carry_query => 0,
	carry_path_info => 0,
    } unless $auth_user;
    return 'next';
}

sub execute_unwind {
    my($self) = @_;
    my($rc) = ($self->unsafe_get('redirect_count') || 0) + 1;
    $self->internal_put_field(redirect_count => $rc);
    return $rc < 2 ? $self->internal_redirect_next : 'forbidden_task';
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	version => 1,
	require_context => 1,
	hidden => [
	    {
		name => 'redirect_count',
		type => 'Integer',
		constraint => 'NONE',
	    },
	],
    });
}

sub unsafe_realm_name_from_context {
    return undef
        unless my $c = shift->unsafe_get_context;
    return $c->unsafe_get_nested(qw(realm owner name));
}

1;
