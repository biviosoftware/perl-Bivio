# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CalendarEventForm;
use strict;
use base 'Bivio::Biz::FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_empty {
    my($self) = @_;
    my($e_id) = $self->unsafe_get('CalendarEvent.calendar_event_id');
    if ($e_id) {
	$self->load_from_model_properties('CalendarEvent');
	$self->load_from_model_properties('RealmOwner');
	my($start) = $self->get('CalendarEvent.dtstart');
	my($end) = $self->get('CalendarEvent.dtend');
	$self->internal_put_field(
	    'start_date' => Bivio::Type::Date->from_datetime($start));
	$self->internal_put_field(
	    'start_time' => Bivio::Type::Time->from_datetime($start));
	$self->internal_put_field(
	    'end_date' => Bivio::Type::Date->from_datetime($end));
	$self->internal_put_field(
	    'end_time' => Bivio::Type::Time->from_datetime($end));
    }
    return;
}

sub execute_ok {
    my($self) = @_;
    shift->SUPER::execute_ok(@_);
    return if $self->in_error;
#TODO: Date/time validations, e.g. start must precede end time
    $self->internal_put_field('CalendarEvent.dtstart' =>
        Bivio::Type::DateTime->from_date_and_time(
	    $self->get('start_date'), $self->get('start_time')));
    $self->internal_put_field('CalendarEvent.dtend' =>
        Bivio::Type::DateTime->from_date_and_time(
	    $self->get('end_date'), $self->get('end_time')));
    if ($self->is_create) {
	my($ce, $ro) = $self->new_other('CalendarEvent')->create_realm({
            realm_id => $self->get_request->get('auth_id'),
            %{$self->get_model_properties('CalendarEvent')},
        }, $self->get_model_properties('RealmOwner'));
    }
    else {
	foreach my $model(qw(RealmOwner CalendarEvent)) {
	    $self->update_model_properties($model);
	}
    }
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	require_context => 1,
	visible => [
	    'RealmOwner.display_name',
	    'CalendarEvent.description',
	    'CalendarEvent.location',
	    'CalendarEvent.url',
	    {
		name => 'start_date',
		type => 'Date',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'start_time',
		type => 'Time',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'end_date',
		type => 'Date',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'end_time',
		type => 'Time',
		constraint => 'NOT_NULL',
	    },
	],
	other => [
	    [qw(CalendarEvent.calendar_event_id RealmOwner.realm_id)],
	    'CalendarEvent.dtstart',
	    'CalendarEvent.dtend',
	 ],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    my($l) = $self->get_request->unsafe_get('Model.CalendarEventList');
    $self->internal_put_field(
	'CalendarEvent.calendar_event_id' =>
	    $l->get('CalendarEvent.calendar_event_id')
	) if $l;
    return;
}

sub is_create {
    my($self) = @_;
    return $self->unsafe_get('CalendarEvent.calendar_event_id') ? 0 : 1;
}

1;
