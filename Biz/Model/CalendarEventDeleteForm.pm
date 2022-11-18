# Copyright (c) 2008-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CalendarEventDeleteForm;
use strict;
use Bivio::Base 'Biz.FormModel';


sub execute_ok {
    my($self) = @_;
    $self->req('Model.CalendarEvent')->cascade_delete;
#TODO: Return to view which had the event
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        other => [
            'RealmOwner.display_name',
        ],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    $self->internal_put_field(
        'RealmOwner.display_name' => $self->new_other('CalendarEvent')
            ->load_this_from_request
            ->get_model('RealmOwner')
            ->get('display_name'),
    );
    return shift->SUPER::internal_pre_execute(@_);
}

1;
