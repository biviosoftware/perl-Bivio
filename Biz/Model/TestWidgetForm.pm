# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TestWidgetForm;
use strict;
use Bivio::Base 'Biz.FormModel';


sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
            'User.gender',
            $self->field_decl([
                [qw(user_agent UserAgent NONE)],
                [qw(bunit_enum BunitEnum NONE)],
            ]),
        ],
    });
}

1;
