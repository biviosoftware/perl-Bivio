# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::Biz::Model::MFARecoveryCodeListRefillForm;
use strict;
use Bivio::Base 'Biz.FormModel';

my($_AMC) = b_use('Action.MFAChallenge');

sub execute_ok {
    my($self) = @_;
    # TODO: does context take care of redirecting to correct task?
    return;
    # return {
    #     method => 'server_redirect',
    #     # TODO: fallback? should have the req key if were here, though...
    #     task_id => $self->req($_AMC->NEXT_TASK_REQ_KEY),
    #     no_context => 1,
    # };
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
    });
}

1;
