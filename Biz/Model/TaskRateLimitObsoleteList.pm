# Copyright (c) 2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TaskRateLimitObsoleteList;
use strict;
use Bivio::Base 'Biz.ListModel';
b_use('IO.ClassLoaderAUTOLOAD');


sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        can_iterate => 1,
        primary_key => ['TaskRateLimit.bucket_key'],
        order_by => ['TaskRateLimit.bucket_date_time'],
    });
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    $stmt->LT('TaskRateLimit', Type_DateTime()->add_days(Type_DateTime()->now, 1));
    return shift->SUPER::internal_prepare_statement(@_);
}

1;
