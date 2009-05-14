# Copyright (c) 2009 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TaskLog;
use strict;
use Bivio::Base 'Biz.PropertyModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_REQ_KEY) = __PACKAGE__ . 'state';
my($_DT) = b_use('Type.DateTime');
my($_Q) = b_use('AgentHTTP.Query');
my($_ULF);
b_use('IO.Config')->register(my $_CFG = {
    enable_log => 0,
});

sub handle_config {
    my(undef, $cfg) = @_;
    if ($cfg->{enable_log}) {
	b_use('Agent.Task')->register(__PACKAGE__);
	$_ULF = b_use('Model.UserLoginForm');
    }
    $_CFG = $cfg;
    return;
}

sub handle_post_execute_task {
    my($proto, $task, $req) = @_;
    # create model in post execute so it survies a form error rollback
    $proto->new($req)->create($req->get($_REQ_KEY))
	if $req->unsafe_get($_REQ_KEY);
    return;
}

sub handle_pre_execute_task {
    my($proto, $task, $req) = @_;
    return
	unless grep(defined($_), $req->unsafe_get(qw(uri auth_id))) == 2;
    my($query) = $_Q->format($req->get('query'));
    # save state before task items modify them
    $req->put($_REQ_KEY => {
	realm_id => $req->req('auth_id'),
	user_id => $_ULF->unsafe_get_cookie_user_id($req)
	    || $req->unsafe_get('auth_user_id'),
	super_user_id => $req->unsafe_get('super_user_id'),
	task_id => $task->get('id'),
	method => $req->unsafe_get('r') ? $req->get('r')->method : '',
	uri => $proto->new($req)->get_field_type('uri')->clean_and_trim(
	    $req->get('uri') . (defined($query) && length($query)
		? ('?' . $query)
		: '')),
	date_time => $_DT->now,
    });
    return;
}

sub if_enabled {
    my(undef, $then, $else) = @_;
    return $_CFG->{enable_log} ? $then->() : $else ? $else->() : ();
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
	},
	other => [
	    [qw(realm_id RealmOwner_1.realm_id)],
	    [qw(user_id User.user_id RealmOwner_2.realm_id)],
	],
	auth_id => 'realm_id',
    });
}

1;
