# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::Biz::Model::MFARecoveryCodeListRefillForm;
use strict;
use Bivio::Base 'Biz.FormModel';

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        require_context => 1,
    });
}

1;
