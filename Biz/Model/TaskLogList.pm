# Copyright (c) 2009 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TaskLogList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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
	$qf->filter_statement($stmt, {
	    date_time => 'TaskLog.date_time',
	    match_fields => [
		qr/\// => 'TaskLog.uri',
		qr/\@/ => 'Email.email',
		qr/^\w/ => 'RealmOwner.display_name',
	    ],
	});
    }
    return shift->SUPER::internal_prepare_statement(@_);
}

1;
