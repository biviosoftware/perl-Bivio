# Copyright (c) 2026 bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::Model::UserPasswordResetConfirmForm;
use strict;
use Bivio::Base 'Biz.FormModel';

sub execute_ok {
    my($proto) = @_;
    # Using server redirect so that reset task has to come from this task or the UserAccessCode
    # won't be found on the request if reset task is accessed directly.
    return {
        method => 'server_redirect',
        task_id => 'next',
    };
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
    });
}

sub internal_pre_execute {
    my($self) = @_;
    my(@res) = shift->SUPER::internal_pre_execute(@_);
    my($uac) = $self->ureq('Model.UserAccessCode');
    return 'FORBIDDEN'
        unless $uac && $uac->get('status')->eq_active && !$uac->is_expired;
    return @res;
}

1;
