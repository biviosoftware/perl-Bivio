# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::FullCalendarForm;
use strict;
use Bivio::Base 'Biz.FormModel';
b_use('IO.ClassLoaderAUTOLOAD');


sub api_error {
    my($self, $property, $error, $detail) = @_;
    $self->internal_put_error_and_detail($property, $error, $detail);
    return;
}

sub execute_empty {
    my($self) = @_;
#TODO: FullCalendarList without query sets full_calendar_start/end
#      Render with Action.JSONReply which is called inline with a type_values
#      APIBaseForm has dispatch for execute_json_ok and execute_json_empty
    return;
}

sub execute_ok {
    my($self) = @_;
    return $self->api_error(event => 'NULL')
	unless my $event = $self->unsafe_get('event');
    my($method) = 'handle_api_' . lc($event);
    return $self->api_error(event => 'NOT_FOUND')
	unless $self->b_can($method);
    return $self->$method;
}

sub handle_api_eventdrop {
    my($self) = @_;
    return $self->api_error(id => 'NULL')
	unless defined(my $id = $self->unsafe_get('id'));
    return $self->api_error(dayDelta => 'NULL')
	unless defined(my $dd = $self->unsafe_get('dayDelta'));
    my($ce) = $self->new_other('CalendarEvent')
	->load({calendar_event_id => $self->get('id')});
    $ce->update({
	map(($_ => Type_Date()->add_days($ce->get($_), $self->get('dayDelta'))),
	    qw(dtstart dtend),
	),
    });
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        $self->field_decl(
	    visible => [
		[qw(event Name)],
		[qw(id CalendarEvent.calendar_event_id)],
		[qw(dayDelta Integer)],
		[qw(minuteDelta Integer)],
		[qw(allDay Boolean)],
	    ],
	),
    });
}

1;
