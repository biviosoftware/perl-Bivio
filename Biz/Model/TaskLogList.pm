# Copyright (c) 2009-2010 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TaskLogList;
use strict;
use Bivio::Base 'Biz.ListModel';

my($_IDI) = __PACKAGE__->instance_data_index;

sub ITERATE_NEXT_AND_LOAD_SIZE {
    return 10_000;
}

sub execute_iterate_start {
    return _execute_iterate(@_);
}

sub execute_unauth_iterate_start {
    return _execute_iterate(@_);
}

sub execute_unauth_load_all {
    my($proto, $req) = @_;
    $proto->new($req)->unauth_load_all;
    return 0;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
        primary_key => ['TaskLog.task_log_id'],
	date => 'TaskLog.date_time',
	order_by => [
	    'TaskLog.date_time',
	],
	other => [
	    'Email.email',
	    'RealmOwner.display_name',
	    'super_user.RealmOwner.name',
	    'TaskLog.uri',
	    'TaskLog.user_id',
	    'TaskLog.client_address',
	    [qw(TaskLog.super_user_id super_user.RealmOwner.realm_id(+))],
	],
	other_query_keys => [qw(b_filter)],
	auth_id => ['TaskLog.realm_id'],
    });
}

sub internal_left_join_model_list {
    return qw(Email RealmOwner);
}

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;
    foreach my $model ($self->internal_left_join_model_list) {
	$stmt->from($stmt->LEFT_JOIN_ON('TaskLog', $model, [
	    ['TaskLog.user_id', "$model.realm_id"],
	    b_use("Model.$model")->isa('Bivio::Biz::Model::LocationBase')
	        ? ["$model.location",
		    [$self->get_instance($model)->DEFAULT_LOCATION]]
	        : (),
	]));
    }
    if (my $qf = $self->ureq('Model.FilterQueryForm')) {
	$qf->filter_statement(
	    $stmt,
	    {
		date_time => 'TaskLog.date_time',
		match_fields => [
		    qr{/} => 'TaskLog.uri',
		    qr{\@} => 'Email.email',
		    qr{^\d+\.}s => 'TaskLog.client_address',
		    qr{^\w} => 'RealmOwner.display_name',
		],
	    },
	    $qf->default_date_filter('WEEK'),
	);
    }
    return shift->SUPER::internal_prepare_statement(@_);
}

sub iterate_next_and_load {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return
	unless !$fields || $fields->{count}-- > 0;
    return shift->SUPER::iterate_next_and_load(@_);
}

sub _execute_iterate {
    my($proto, $req) = @_;
    my($method) = $proto->my_caller =~ /unauth/ ? 'unauth_iterate_start'
	: 'iterate_start';
    my($self) = $proto->new($req);
    $self->unauth_iterate_start($self->ureq('query'));
    $self->[$_IDI] = {
	count => $self->get_query->unsafe_get('count')
	    || $self->ITERATE_NEXT_AND_LOAD_SIZE,
    };
    $self->put_on_request;
    return;
}

1;
