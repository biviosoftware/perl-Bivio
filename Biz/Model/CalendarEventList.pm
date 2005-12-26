# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CalendarEventList;
use strict;
use base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	auth_id => 'CalendarEvent.realm_id',
        primary_key => [
	    [qw{CalendarEvent.calendar_event_id RealmOwner.realm_id}],
	 ],
	order_by => [
	    'CalendarEvent.dtstart',
	    'CalendarEvent.dtend',
	],
	other => [
	    'RealmOwner.display_name',
	    'RealmOwner.name',
	    'CalendarEvent.location',
	    'CalendarEvent.description',
	],
    });
}

1;
