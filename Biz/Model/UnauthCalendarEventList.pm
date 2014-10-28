# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UnauthCalendarEventList;
use strict;
use Bivio::Base 'Biz.ListModel';


sub IS_COPY_QUERY_KEY {
    return 'b_is_copy';
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	primary_key => [['CalendarEvent.calendar_event_id', 'RealmOwner.realm_id']],
	order_by => ['CalendarEvent.calendar_event_id'],
	other => [
	    $self->get_instance('CalendarEvent')->get_qualified_field_name_list,
	    'RealmOwner.display_name',
	],
	other_query_keys => [$self->IS_COPY_QUERY_KEY],
    });
}

sub is_copy_in_query {
    my($self) = @_;
    return $self->get_query->unsafe_get($self->IS_COPY_QUERY_KEY) ? 1 : 0;
}

1;
