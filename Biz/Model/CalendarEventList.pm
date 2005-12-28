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
	)],
	other => [qw(
	    RealmOwner.display_name
	    RealmOwner.name
	    RealmOwner.creation_date_time
	    CalendarEvent.modified_date_time
	    CalendarEvent.location
	    CalendarEvent.description
	    CalendarEvent.url
	), {
	    name => 'uid',
	    type => 'RealmOwner.name',
	}],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    $row->{uid} = $_CE->id_to_uid($row->{'CalendarEvent.calendar_event_id'});
    return 1;
}

sub update_from_ics {
    my($self, $ics) = @_;
    my($old) = {map(($_->{uid} => $_), @{$self->map_iterate})};
    my($ce) = $self->new_other('CalendarEvent');
    foreach my $v (@{Bivio::MIME::Calendar->from_ics($ics)}) {
        if (my $x = delete($old->{$v->{uid}})) {
	    $ce->load({calendar_event_id => $x->{calendar_event_id}})
		->update_from_vevent($v);
	}
	else {
	    $ce->create_from_vevent($v);
	}
    }
    foreach my $x (values(%$old)) {
	$ce->load({calendar_event_id => $x->{calendar_event_id}})
	    ->cascade_delete;
    }
    return;
}

1;
