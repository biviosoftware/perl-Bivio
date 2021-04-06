# Copyright (c) 2021 Bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::Model::ECUserPaymentList;
use strict;
use Bivio::Base 'Model.ECPaymentList';
b_use('IO.ClassLoaderAUTOLOAD');

our($VERSION) = sprintf('%d.%02d', q$Revision: 0.0$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
#        auth_id => undef,
        auth_user_id => 'ECPayment.user_id',
    });
}

1;
