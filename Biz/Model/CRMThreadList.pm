# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CRMThreadList;
use strict;
use Bivio::Base 'Model.MailThreadList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub PROPERTY_CLASS {
    return 'CRMThread';
}

sub get_crm_thread_num {
    return _model(shift)->get('crm_thread_num');
}

sub get_crm_thread_status {
    return _model(shift)->get('crm_thread_status');
}

sub get_subject {
    return _model(shift)->get('subject');
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        parent_id => 'CRMThread.crm_thread_num',
        other => [
            ['RealmMail.thread_root_id', 'CRMThread.thread_root_id'],
            [qw(RealmMail.realm_id CRMThread.realm_id)],
        ],
   });
}

sub _model {
    my($self) = @_;
    return $self->req->unsafe_get('Model.CRMThread')
	|| ($self->has_cursor ? $self : $self->set_cursor_or_die(0))
            ->get_model('CRMThread');
}

1;
