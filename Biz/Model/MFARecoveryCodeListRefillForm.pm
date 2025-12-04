# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::Biz::Model::MFARecoveryCodeListRefillForm;
use strict;
use Bivio::Base 'Biz.FormModel';

my($_AAC) = b_use('Action.AccessChallenge');

sub execute_ok {
    my($self) = @_;
    my($next) = $_AAC->get_next($self->req);
    return {
        method => 'server_redirect',
        task_id => $next,
        carry_query => 1,
    } if $next;
    return 0;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        require_context => 1,
    });
}

1;
