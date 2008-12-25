# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CRMThreadRootList;
use strict;
use Bivio::Base 'Model.MailThreadRootList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_CAL) = __PACKAGE__->use('Model.CRMActionList');
my($_LOCATION) = __PACKAGE__->use('Model.Email')->DEFAULT_LOCATION;
my($_TSN) = __PACKAGE__->use('Type.TupleSlotNum');

sub internal_initialize {
    my($self) = @_;
    my($info) = $self->SUPER::internal_initialize;
    return $self->merge_initialize_info($info, {
        version => 1,
        primary_key => ['CRMThread.crm_thread_num'],
        order_by => [qw(
	    CRMThread.modified_date_time
	    CRMThread.crm_thread_num
	    CRMThread.crm_thread_status
	    owner.Email.email
	    modified_by.Email.email
	    CRMThread.subject_lc
	),
	    @{$_TSN->map_list(sub {'TupleTag.' . shift(@_)})},
	],
        other_query_keys => $self->get_instance('CRMQueryForm')->filter_keys,
	other => [
            delete($info->{primary_key})->[0],
	    'CRMThread.subject',
	    ['RealmMail.thread_root_id', 'CRMThread.thread_root_id'],
	    _do(sub {
	        my($name, $model) = @_;
	        return (
		    {
			name => $name,
			type => 'Name',
			constraint => 'NONE',
		    },
		);
	    }),
	],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    _do(sub {
        my($name, $model) = @_;
	my($e) = $row->{"$model.email"};
	$row->{$name} = $_CAL->owner_email_to_name($e);
	return;
    });
    return 1;
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    $stmt->from(
	$stmt->LEFT_JOIN_ON(qw(CRMThread owner.Email), [
	    ['CRMThread.owner_user_id', 'owner.Email.realm_id'],
	    ['owner.Email.location', [$_LOCATION]],
	]),
	$stmt->LEFT_JOIN_ON(qw(CRMThread modified_by.Email), [
	    ['CRMThread.modified_by_user_id', 'modified_by.Email.realm_id'],
	    ['modified_by.Email.location', [$_LOCATION]],
	]),
	$stmt->LEFT_JOIN_ON(qw(RealmMail TupleTag), [
	    ['RealmMail.thread_root_id', 'TupleTag.primary_id'],
	]),
    );
    if (my $qf = $self->req->unsafe_get('Model.CRMQueryForm')) {
	my($status, $owner) = $qf->unsafe_get(qw(x_status x_owner_name));
	$stmt->where(['CRMThread.crm_thread_status', [
            $status->eq_open ? ($status->OPEN, $status->NEW) : $status
        ]])
	    if $status;
	$stmt->where(['CRMThread.owner_user_id', [$owner]])
	    if $owner;
	$_TSN->map_list(sub {
	    my($name) = @_;
	    my($v) = $qf->unsafe_get('x_' . $name);
	    $stmt->where(['TupleTag.' . $name, [$v]])
		if defined($v);
	    return;
	});
    }
    return shift->SUPER::internal_prepare_statement(@_);
}

sub _do {
    my($op) = @_;
    return map($op->($_ . '_name', "$_.Email"), qw(owner modified_by));
}

1;
