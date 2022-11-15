# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Model::FieldTestForm;
use strict;
use Bivio::Base 'Biz.FormModel';


sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        $self->field_decl(visible => [
            [qw(boolean Boolean)],
            [qw(date Date)],
            [qw(date_time DateTime)],
            [qw(realm_name RealmName)],
            [qw(line Line)],
            [qw(text Text)],
            [qw(required_date Date NOT_NULL)],
            [qw(gender Gender)],
            [qw(bunit_enum BunitEnum)],
        ], undef, 'NONE'),
    });
}

1;
