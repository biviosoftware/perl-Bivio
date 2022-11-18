# Copyright (c) 2005-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CalendarEventList;
use strict;
use Bivio::Base 'Biz.ListModel';

my($_T) = b_use('Type.Time');
my($_UTC) = b_use('Type.TimeZone')->UTC;
my($_DTWTZ) = b_use('Type.DateTimeWithTimeZone');
my($_EDIT_TASK) = 'FORUM_CALENDAR_EVENT_FORM';

sub can_user_edit_any_realm {
    my($self) = @_;
    return $self->req('Model.AuthUserGroupList')
        ->can_user_execute_task_in_any_realm($_EDIT_TASK);
}

sub can_user_edit_this_realm {
    my($self) = @_;
    $self->assert_has_cursor;
    return $self->req->can_user_execute_task(
        $_EDIT_TASK,
        $self->get('CalendarEvent.realm_id'),
    );
}

sub decl_for_internal_initialize {
    my($proto) = @_;
    return {
        version => 1,
        # No auth_id, see internal_prepare_statement
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
                CalendarEvent.uid
            ),
            [qw(CalendarEvent.realm_id owner.RealmOwner.realm_id)],
            $proto->field_decl([
                [qw(uid RealmOwner.name)],
                [qw(dtstart_with_tz DateTimeWithTimeZone)],
                [qw(dtend_with_tz DateTimeWithTimeZone)],
                [qw(dtstart_tz DateTime)],
                [qw(dtend_tz DateTime)],
                [qw(path_info FilePath)],
                [qw(query Text)],
                [qw(time_zone DisplayName)],
                [qw(time_and_name DisplayName)],
            ], undef, 'NOT_NULL'),
        ],
    };
}

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
    return $self->merge_initialize_info(
        $self->SUPER::internal_initialize, $self->decl_for_internal_initialize);
}

sub internal_post_load_row {
    my($self, $row) = @_;
    return 0
        unless shift->SUPER::internal_post_load_row(@_);
    $row->{uid} = $row->{'CalendarEvent.calendar_event_id'};
    my($tz) = $row->{'CalendarEvent.time_zone'} || $_UTC;
    $row->{time_zone} = $self->req('Model.TimeZoneList')
        ->display_name_for_enum($tz);
    foreach my $field (qw(dtstart dtend)) {
        $row->{"${field}_tz"} = (
            $row->{"${field}_with_tz"}
                = $_DTWTZ->new($row->{"CalendarEvent.$field"}, $tz)
        )->as_date_time;
    }
    $row->{path_info} = undef;
    $row->{time_and_name}
        = $_T->to_string($row->{dtstart_tz})
        . ' '
        . $row->{'RealmOwner.display_name'};
    $row->{query} = $self->get_query->format_uri_for_this(
        $self->internal_get_sql_support,
        [$row->{'CalendarEvent.calendar_event_id'}],
    );
    return 1;
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    $self->new_other('TimeZoneList')->load_all;
    $self->new_other('AuthUserGroupList')->load_all_for_task;
    $stmt->where(
        ['CalendarEvent.realm_id' => $self->internal_realm_ids],
    );
    return shift->SUPER::internal_prepare_statement(@_);
}

sub internal_realm_ids {
    my($self) = @_;
#TODO: If user, will display auth_user, not auth_realm.  Not correct but safe
    return $self->req(qw(auth_realm type))->eq_user
        ? $self->req('Model.AuthUserGroupList')->realm_ids
        : [$self->req('auth_id')];
}

sub show_create_on_month_view {
    my($self) = @_;
    return $self->can_user_edit_any_realm
        if $self->req(qw(auth_realm type))->eq_user;
    return $self->req->can_user_execute_task($_EDIT_TASK);
}

1;
