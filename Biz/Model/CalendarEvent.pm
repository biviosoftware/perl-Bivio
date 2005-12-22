# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CalendarEvent;
use strict;
use base 'Bivio::Biz::PropertyModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = Bivio::Type->get_instance('DateTime');

sub create_realm {
    my($self, $calendar_event, $realm_owner) = @_;
    my($req) = $self->get_request;
    my($ro) = $self->new_other('RealmOwner')->create({
	%$realm_owner,
	realm_type => Bivio::Auth::RealmType->CALENDAR_EVENT,
	realm_id => $self->create({
	    modified_date_time => $_DT->now,
	    %$calendar_event,
	    realm_id => $req->get('auth_id'),
	})->get('calendar_event_id'),
    });
    $self->new_other('RealmUserAddForm')->copy_admins($ro->get('realm_id'));
    return ($self, $ro);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	table_name => 'calendar_event_t',
        columns => {
	    calendar_event_id => ['PrimaryId', 'PRIMARY_KEY'],
            realm_id => ['RealmOwner.realm_id', 'NOT_NULL'],
	    modified_date_time => ['DateTime', 'NOT_NULL'],
	    start_date_time => ['DateTime', 'NOT_NULL'],
	    end_date_time => ['DateTime', 'NOT_NULL'],
	    location => ['Text', 'NONE'],
	    description => ['Text', 'NONE'],
	    url => ['HTTPURI', 'NONE'],
# 	    rrule_freq
# 		rrule_until
# 		rrule_count
# 	        rrule_interval
# 		rrule_bymonth
# 	    occurance, freq
	},
    });
}

1;
