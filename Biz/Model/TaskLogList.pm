# Copyright (c) 2009 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TaskLogList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_LOCATION) = b_use('Model.Email')->DEFAULT_LOCATION;
my($_U) = b_use('Model.User');

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
	    'Phone.phone',
	    'super_user.RealmOwner.name',
	    'TaskLog.uri',
	    [qw(TaskLog.user_id Email.realm_id Phone.realm_id(+)
                RealmOwner.realm_id)],
	    [qw(TaskLog.super_user_id super_user.RealmOwner.realm_id(+))],
#TODO: locations
	],
    });
}

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;
    if (my $qf = $self->ureq('Model.TaskLogQueryForm')) {
	if (defined(my $filter = $qf->unsafe_get('x_filter'))) {
	    unless ($filter eq $qf->X_FILTER_HINT) {
		$filter =~ s/\%/_/g;
		$stmt->where($stmt->ILIKE(
		    $filter =~ m,/,
			? 'TaskLog.uri'
			: $filter =~ m,\@,
			    ? 'Email.email'
			    : 'RealmOwner.display_name',
		    '%' . lc($filter) . '%'));
	    }
	}
    }
    return shift->SUPER::internal_prepare_statement(@_);
}

1;
