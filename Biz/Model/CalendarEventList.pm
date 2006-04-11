# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CalendarEventList;
use strict;
use base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_CE) = Bivio::Biz::Model->get_instance('CalendarEvent');

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	auth_id => 'CalendarEvent.realm_id',
	can_iterate => 1,
        primary_key => [
	    [qw{CalendarEvent.calendar_event_id RealmOwner.realm_id}],
	 ],
	order_by => [qw(
	    CalendarEvent.dtstart
	    CalendarEvent.dtend
	    RealmOwner.display_name
	    CalendarEvent.location
	)],
	other => [qw(
	    RealmOwner.name
	    RealmOwner.creation_date_time
	    CalendarEvent.modified_date_time
	    CalendarEvent.description
	    CalendarEvent.url
	), {
	    name => 'uid',
	    type => 'RealmOwner.name',
	},
	{
	    name => 'item_uri',
	    type => 'Text',
	    in_select => 0,
	    constraint => 'NOT_NULL',
	}],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    $row->{uid} = $_CE->id_to_uid($row->{'CalendarEvent.calendar_event_id'});
    my($req) = $self->get_request;
    my($fro) = $self->new_other('RealmOwner')->load;
#TODO: Expand relative URI to absolute URI for RSS spec compliance
    $row->{item_uri} = $req->format_uri({
	task_id => 'FORUM_CALENDAR_EVENT_ICS',
	realm => $fro->get('name'),
	query => {
	    'ListQuery.this' => $row->{'CalendarEvent.calendar_event_id'},
	},
#	path_info => $row->{'RealmFile.path'},
    });
    return 1;
}

sub update_from_ics {
    my($self, $ics) = @_;
    my($old) = {map(($_->{uid} => $_), @{$self->map_iterate})};
    my($ce) = $self->new_other('CalendarEvent');
    foreach my $v (@{Bivio::MIME::Calendar->from_ics($ics)}) {
        if (my $x = delete($old->{$v->{uid}})) {
	    $ce->load({calendar_event_id => $x->{'CalendarEvent.calendar_event_id'}})
		->update_from_vevent($v);
	}
	else {
	    $ce->create_from_vevent($v);
	}
    }
    foreach my $x (values(%$old)) {
	$ce->load({calendar_event_id => $x->{'CalendarEvent.calendar_event_id'}})
	    ->cascade_delete;
    }
    return;
}

1;
