# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ContextlessUserLoginForm;
use strict;
use Bivio::Base 'Model.UserLoginForm';


sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        require_context => 0,
    });
}

1;
