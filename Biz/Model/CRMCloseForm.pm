# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CRMCloseForm;
use strict;
use Bivio::Base 'Model.ConfirmableForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_ok {
    my($self) = @_;
    $self->req('Model.CRMThread')->update({
	crm_thread_status => b_use('Type.CRMThreadStatus')->CLOSED,
    });
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        require_context => 1,
    });
}

sub internal_pre_execute {
    my($self) = @_;
    my(@res) = shift->SUPER::internal_pre_execute(@_);
    $self->req('Model.CRMThreadList')->set_cursor_or_not_found(0)
	->get_model('CRMThread');
    return @res;
}

1;
