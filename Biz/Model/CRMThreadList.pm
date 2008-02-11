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

sub _model {
    my($self) = @_;
    return $self->req->unsafe_get('Model.CRMThread')
	|| $self->new_other('CRMThread')->load({
	    thread_root_id => $self->get_query->get('parent_id'),
	});
}

1;
