# Copyright (c) 2005-2010 bivio Software, Inc.  All Rights Reserved.
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
	# No auth_id, see internal_prepare_statement
	can_iterate => 1,
	date => 'CalendarEvent.dtstart',
        primary_key => [
	    [qw{CalendarEvent.calendar_event_id RealmOwner.realm_id}],
	 ],
	order_by => [qw(
	    CalendarEvent.dtstart
	    CalendarEvent.dtend
	    RealmOwner.display_name
	    CalendarEvent.location
	)],
	other => [
	    qw(
		RealmOwner.name
		RealmOwner.creation_date_time
		owner.RealmOwner.name
		owner.RealmOwner.display_name
		CalendarEvent.modified_date_time
		CalendarEvent.description
		CalendarEvent.url
		CalendarEvent.time_zone
	    ),
	    [qw(CalendarEvent.realm_id owner.RealmOwner.realm_id)],
	    $self->field_decl([
		[qw(uid RealmOwner.name)],
		[qw(dtstart_in_tz DateTime)],
		[qw(dtend_in_tz DateTime)],
		[qw(path_info FilePath)],
		[qw(query Text)],
		[qw(time_zone DisplayName)],
	    ], undef, 'NOT_NULL'),
	],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    return 0
	unless shift->SUPER::internal_post_load_row(@_);
    $row->{uid} = $_CE->id_to_uid($row->{'CalendarEvent.calendar_event_id'});
    my($tz) = $row->{'CalendarEvent.time_zone'} || $_UTC;
    $row->{time_zone} = $self->req('Model.TimeZoneList')
	->display_name_for_enum($tz);
    $row->{'dtstart_in_tz'}
	= $tz->date_time_from_utc($row->{'CalendarEvent.dtstart'});
    $row->{'dtend_in_tz'}
	= $tz->date_time_from_utc($row->{'CalendarEvent.dtend'});
    $row->{path_info} = undef;
    $row->{query} = $self->get_query->format_uri_for_this(
	$self->internal_get_sql_support,
	[$row->{'CalendarEvent.calendar_event_id'}],
    );
    return 1;
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    $self->new_other('TimeZoneList')->load_all;
    $stmt->where(
	['CalendarEvent.realm_id' => $self->internal_realm_ids],
    );
    return shift->SUPER::internal_prepare_statement(@_);
}

sub internal_realm_ids {
    my($self) = @_;
#TODO: If user, will display auth_user, not auth_realm.  Not correct but safe
    return $self->req(qw(auth_realm type))->eq_user
	? $self->new_other('AuthUserGroupList')
	    ->set_ephemeral
	    ->realm_ids($self->req('task_id'))
        : [$self->req('auth_id')];
}

1;
