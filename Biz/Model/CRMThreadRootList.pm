# Copyright (c) 2008-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CRMThreadRootList;
use strict;
use Bivio::Base 'Model.MailThreadRootList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_CAL) = b_use('Model.CRMActionList');
my($_LOCATION) = b_use('Model.Email')->DEFAULT_LOCATION;
my($_TSN) = b_use('Type.TupleSlotNum');
my($_CRMQF) = b_use('Model.CRMQueryForm');
b_use('ClassWrapper.TupleTag')->wrap_methods(
    __PACKAGE__, b_use('Model.CRMForm')->TUPLE_TAG_INFO);

sub LIST_QUERY_FORM_CLASS {
    return $_CRMQF;
}

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
	    customer.RealmOwner.name
	    customer.RealmOwner.display_name
	)],
        other_query_keys => $self->get_instance(
	    $self->LIST_QUERY_FORM_CLASS)->filter_keys,
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
    return 0
	unless shift->SUPER::internal_post_load_row(@_);
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
	$stmt->LEFT_JOIN_ON(qw(CRMThread customer.RealmOwner), [
	    ['CRMThread.customer_realm_id', 'customer.RealmOwner.realm_id'],
	]),
    );
    if (my $qf = $self->req->unsafe_get($self->LIST_QUERY_FORM_CLASS)) {
	my($status, $owner) = $qf->unsafe_get(qw(b_status b_owner_name));
	$stmt->where(['CRMThread.crm_thread_status', [
            $status->get_criteria_list,
        ]])
	    if $status;
	$stmt->where(['CRMThread.owner_user_id', [$owner]])
	    if $owner;
    }
    return shift->SUPER::internal_prepare_statement(@_);
}

sub _do {
    my($op) = @_;
    return map($op->($_ . '_name', "$_.Email"), qw(owner modified_by));
}

1;
