# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::FullCalendarList;
use strict;
use Bivio::Base 'Model.CalendarEventList';
b_use('IO.ClassLoaderAUTOLOAD');

# Supports fullcalendar.js

sub as_type_values {
    my($self) = @_;
    return $self->map_rows(sub {
        my($it) = @_;
        return {
            className => Bivio_TypeValue()->new(Type_Line(), 'b_full_calendar_event'),
            allDay => Bivio_TypeValue()->new(Type_Boolean(), Type_Boolean()->FALSE),
#TODO: calculate
            editable => Bivio_TypeValue()->new(Type_Boolean(), Type_Boolean()->TRUE),
            map(
                ($_->[1] => Bivio_TypeValue()->new(
                    $it->get_field_type($_->[0]),
                    $it->get($_->[0]),
                )),
                [qw(CalendarEvent.calendar_event_id id)],
                [qw(RealmOwner.display_name title)],
                [qw(dtstart_tz start)],
                [qw(dtend_tz end)],
#TODO: url, description
            ),
        };
    });
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        other_query_keys => [qw(full_calendar_start full_calendar_end)],
    });
}

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;
    my($q) = {map(
        ($_ => Type_DateTime()->from_unix($query->get("full_calendar_$_"))),
        qw(start end),
    )};
    $stmt->where(
        $stmt->OR(
            map(
                $stmt->AND(
                    $stmt->GTE("CalendarEvent.$_", [$q->{start}]),
                    $stmt->LTE("CalendarEvent.$_", [$q->{end}]),
                ),
                qw(dtstart dtend),
            ),
        ),
    );
    return shift->SUPER::internal_prepare_statement(@_);
}

1;
