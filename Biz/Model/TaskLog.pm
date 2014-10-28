# Copyright (c) 2009-2010 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TaskLog;
use strict;
use Bivio::Base 'Biz.PropertyModel';

my($_REQ_KEY) = __PACKAGE__ . '.state';
my($_DT) = b_use('Type.DateTime');
$_DT->register_with_agent_task;
b_use('Agent.Task')->register(__PACKAGE__)
    if b_use('Agent.TaskId')->unsafe_from_name('SITE_ADMIN_TASK_LOG');

sub handle_post_execute_task {
    my($proto, $task, $req) = @_;
    # create model in post execute so it survies a form error rollback
    return
	unless my $values = $req->unsafe_get($_REQ_KEY);
    $proto->new($req)->create($values);
    return;
}

sub handle_pre_execute_task {
    my($proto, $task, $req) = @_;
    return
	unless grep(defined($_), $req->unsafe_get(qw(uri auth_id))) == 2;
    my($query) = b_use('AgentHTTP.Query')->format($req->get('query'), $req);
    # save state before task items modify them
    $req->put($_REQ_KEY => {
	realm_id => $req->req('auth_id'),
	user_id => b_use('Model.UserLoginForm')->unsafe_get_cookie_user_id($req)
	    || $req->unsafe_get('auth_user_id'),
	super_user_id => $req->unsafe_get('super_user_id'),
	task_id => $task->get('id'),
	method => $req->unsafe_get('r') ? $req->get('r')->method : '',
	uri => $proto->new($req)->get_field_type('uri')->clean_and_trim(
	    $req->get('uri') . (defined($query) && length($query)
		? ('?' . $query)
		: '')),
	client_address => $req->unsafe_get('client_addr') || '',
	date_time => $_DT->now,
    });
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'task_log_t',
	columns => {
	    task_log_id => [qw(PrimaryId PRIMARY_KEY)],
	    realm_id => [qw(RealmOwner.realm_id NOT_NULL)],
	    user_id => [qw(User.user_id NONE)],
	    super_user_id => [qw(User.user_id NONE)],
	    date_time => [qw(DateTime NOT_NULL)],
	    task_id => [qw(Bivio::Agent::TaskId NOT_NULL)],
	    method => [qw(Name NONE)],
	    uri => [qw(Text NOT_NULL)],
	    client_address => [qw(Name NONE)],
	},
	other => [
	    [qw(realm_id RealmOwner_1.realm_id)],
	    [qw(user_id User.user_id RealmOwner_2.realm_id)],
	],
	auth_id => 'realm_id',
    });
}

sub set_user_id {
    my($proto, $req, $user_id) = @_;
    $req->get($_REQ_KEY)->{user_id} = $user_id;
    return;
}

1;
