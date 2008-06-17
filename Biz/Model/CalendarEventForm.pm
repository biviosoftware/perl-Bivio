# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CalendarEventForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');
my($_D) = b_use('Type.Date');
my($_T) = b_use('Type.Time');
my($_TZ) = b_use('Type.TimeZone');

sub execute_empty {
    my($self) = @_;
    if ($self->is_create) {
	$self->internal_put_field(
	    'CalendarEvent.time_zone' => $_TZ->get_default);
    }
    else {
	$self->load_from_model_properties('CalendarEvent');
	$self->load_from_model_properties('RealmOwner');

	my($start) = $self->get('CalendarEvent.time_zone')
	    ->date_time_from_utc($self->get('CalendarEvent.dtstart'));
	my($end) = $self->get('CalendarEvent.time_zone')
	    ->date_time_from_utc($self->get('CalendarEvent.dtend'));
	$self->internal_put_field('start_date' => $_D->from_datetime($start));
	$self->internal_put_field('start_time' => $_T->from_datetime($start));
	$self->internal_put_field('end_date' => $_D->from_datetime($end));
	$self->internal_put_field('end_time' => $_T->from_datetime($end));
    }
    return;
}

sub execute_ok {
    my($self) = @_;
    shift->SUPER::execute_ok(@_);
    return if $self->in_error;
    $self->internal_put_field(
	'CalendarEvent.dtstart' =>
	    $self->get('CalendarEvent.time_zone')->date_time_to_utc(
		$_DT->from_date_and_time($self->get('start_date'),
					 $self->get('start_time'))));
    $self->internal_put_field(
	'CalendarEvent.dtend' =>
	    $self->get('CalendarEvent.time_zone')->date_time_to_utc(
		$_DT->from_date_and_time($self->get('end_date'),
					 $self->get('end_time'))));
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
	    {
		name => 'CalendarEvent.time_zone',
		type => 'TimeZone',
		constraint => 'NOT_ZERO_ENUM',
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
    my($id) = $self->use('Type.PrimaryId')->from_literal(
	($self->req('query') || {})->{$self->use('SQL.ListQuery')
	    ->to_char('this')});
    return unless $id;
    $self->internal_put_field('CalendarEvent.calendar_event_id' =>
	$self->new_other('CalendarEvent')->load({
	    calendar_event_id => $id,
	})->get('calendar_event_id'));
    return;
}

sub is_create {
    my($self) = @_;
    return $self->unsafe_get('CalendarEvent.calendar_event_id') ? 0 : 1;
}

sub validate {
    my($self) = @_;
    return if $self->in_error;
    my($sdt) = $_DT->from_date_and_time($self->get('start_date'),
					$self->get('start_time'));
    my($edt) = $_DT->from_date_and_time($self->get('end_date'),
					$self->get('end_time'));
    $self->internal_put_error('end_date', 'INVALID_END_DATETIME')
	unless $_DT->compare($sdt, $edt) == -1;
    return;
}

1;
