# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CRMThreadRootList;
use strict;
use Bivio::Base 'Model.MailThreadRootList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_LOCATION) = __PACKAGE__->use('Model.Email')->DEFAULT_LOCATION;
my($_CAL) = __PACKAGE__->use('Model.CRMActionList');

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
	)],
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
    my(undef, $stmt) = @_;
    $stmt->from(
	$stmt->LEFT_JOIN_ON(qw(CRMThread owner.Email), [
	    ['CRMThread.owner_user_id', 'owner.Email.realm_id'],
	    ['owner.Email.location', [$_LOCATION]],
	]),
	$stmt->LEFT_JOIN_ON(qw(CRMThread modified_by.Email), [
	    ['CRMThread.owner_user_id', 'modified_by.Email.realm_id'],
	    ['modified_by.Email.location', [$_LOCATION]],
	]),
    );
    return shift->SUPER::internal_prepare_statement(@_);
}

sub _do {
    my($op) = @_;
    return map($op->($_ . '_name', "$_.Email"), qw(owner modified_by));
}

1;
