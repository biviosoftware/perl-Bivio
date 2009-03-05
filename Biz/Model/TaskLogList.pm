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
	    'User.last_name_sort',
	    'User.first_name_sort',
	    'User.middle_name_sort',
	    'Email.email',
	    'Phone.phone',
	    'TaskLog.uri',
	],
	other => [
	    [qw(TaskLog.user_id User.user_id Email.realm_id Phone.realm_id
                RealmOwner.realm_id)],
	    'TaskLog.super_user_id',
	    map('User.' . $_ . '_name', qw(last first middle)),
	    {
		name => 'last_first_middle',
		constraint => 'NOT_NULL',
		type => 'Line',
	    },
	],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    $row->{last_first_middle} = $_U->concat_last_first_middle(
	@{$row}{qw(User.last_name User.first_name User.middle_name)});
    return 1;
}

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;
    return unless $self->req->unsafe_get('Model.SearchForm');
    my($search) = $self->req(qw(Model.SearchForm search));
    return unless $search;

    if ($search =~ m,/,) {
	$stmt->where($stmt->ILIKE('TaskLog.uri',
	    '%' . lc($search) . '%'));
    }
    elsif ($search =~ m,\@,) {
	$stmt->where($stmt->EQ('Email.email', [lc($search)]));
    }
    else {
	$stmt->where($stmt->ILIKE('RealmOwner.display_name',
	    '%' . lc($search) . '%'));
    }
    return;
}

1;
