# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CalendarEventList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_CE) = b_use('Model.CalendarEvent');
my($_T) = b_use('Type.Time');
my($_D) = b_use('Type.Date');
my($_UTC) = b_use('Type.TimeZone')->UTC;
my($_DT) = b_use('Type.DateTime');
my($_MC) = b_use('MIME.Calendar');


sub get_creation_date_time {
    return shift->get('RealmOwner.creation_date_time');
}

sub get_modified_date_time {
    return shift->get('CalendarEvent.modified_date_time');
}

sub get_rss_author {
    my($self) = @_;
    return $self->req(qw(auth_realm owner display_name));
}

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
	    CalendarEvent.time_zone
	),
	    {
		name => 'uid',
		type => 'RealmOwner.name',
	    },
	    {
		name => 'dtstart_in_tz',
		type => 'DateTime',
	    }, {
		name => 'dtend_in_tz',
		type => 'DateTime',
	    },
	    {
		name => 'title_',
		type => 'Line',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'path_info',
		type => 'FilePath',
		constraint => 'NONE',
	    },
	    {
		name => 'query',
		type => 'Line',
		constraint => 'NOT_NULL',
	    },
	],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    $row->{uid} = $_CE->id_to_uid($row->{'CalendarEvent.calendar_event_id'});
    my($tz) = $row->{'CalendarEvent.time_zone'} || $_UTC;
    $row->{'dtstart_in_tz'}
	= $tz->date_time_from_utc($row->{'CalendarEvent.dtstart'});
    $row->{'dtend_in_tz'}
	= $tz->date_time_from_utc($row->{'CalendarEvent.dtend'});
    $row->{path_info} = undef;
    $row->{query} = $self->get_query->format_uri_for_this(
	$self->internal_get_sql_support,
	[$row->{'CalendarEvent.calendar_event_id'}],
    );
#TODO: Enscapsulate with T
    $row->{title} = join(' - ',
	$row->{'RealmOwner.display_name'},
	grep($_ =~ s/GMT|UTC// || 1,
	     $_DT->to_string($row->{'dtstart_in_tz'}),
	     $_DT->to_string($row->{'dtend_in_tz'}),
	),
    );
    return 1;
}

sub update_from_ics {
    my($self, $ics) = @_;
    my($old) = {map(($_->{uid} => $_), @{$self->map_iterate})};
    my($ce) = $self->new_other('CalendarEvent');
    foreach my $v (@{$_MC->from_ics($ics)}) {
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
