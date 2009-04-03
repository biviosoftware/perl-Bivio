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
        primary_key => ['TaskLog.task_log_id'],
	order_by => [
	    'TaskLog.date_time',
	],
	other => [
	    'Email.email',
	    'RealmOwner.display_name',
	    'super_user.RealmOwner.name',
	    'TaskLog.uri',
	    [qw(TaskLog.user_id Email.realm_id RealmOwner.realm_id)],
	    ['Email.location',
		[$self->get_instance('Email')->DEFAULT_LOCATION]],
	    [qw(TaskLog.super_user_id super_user.RealmOwner.realm_id(+))],
	],
	other_query_keys => [qw(x_filter)],
	auth_id => ['TaskLog.realm_id'],
    });
}

sub internal_left_join_model_list {
    return ();
}

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;

    foreach my $model ($self->internal_left_join_model_list) {
	$stmt->from($stmt->LEFT_JOIN_ON('TaskLog', $model, [
	    ['TaskLog.user_id', "$model.realm_id"],
	    ["$model.location",
		[$self->get_instance($model)->DEFAULT_LOCATION]],
	]));
    }

    if (my $qf = $self->ureq('Model.TaskLogQueryForm')) {
	if (defined(my $filter = $qf->unsafe_get('x_filter'))) {
	    if ($filter =~ /\S/ && $filter ne $qf->X_FILTER_HINT) {
		$filter =~ s/\%/_/g;
		$stmt->where(map({
		    my($method) = $_ =~ s/^-// ? 'NOT_ILIKE' : 'ILIKE';
		    $stmt->$method(
			$_ =~ m{/} ? 'TaskLog.uri'
			    : $_ =~ m,\@, ? 'Email.email'
			    : 'RealmOwner.display_name',
			'%' . lc($_) . '%',
		    );
		} split(' ', $filter)));
	    }
	}
    }
    return shift->SUPER::internal_prepare_statement(@_);
}

1;
