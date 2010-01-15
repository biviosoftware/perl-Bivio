# Copyright (c) 2006-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CalendarEventForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_CER) = b_use('Type.CalendarEventRecurrence');
my($_DT) = b_use('Type.DateTime');
my($_D) = b_use('Type.Date');
my($_T) = b_use('Type.Time');
my($_TZ) = b_use('Type.TimeZone');
my($_FM) = b_use('Type.FormMode');
my($_A) = b_use('Action.Acknowledgement');

sub execute_empty {
    my($self) = @_;
    $self->internal_put_field(recurrence => $_CER->from_name('UNKNOWN'));
    if ($self->is_create) {
	$self->internal_put_field(
	    'CalendarEvent.time_zone' => $_TZ->get_default,
	    'CalendarEvent.realm_id' =>
		$self->req(qw(auth_realm type))->eq_user ? undef
	        : $self->req('auth_id'),
	);
    }
    else {
	$self->load_from_model_properties('CalendarEvent');
	$self->load_from_model_properties('RealmOwner');
	foreach my $which (qw(start end)) {
	    my($dt) = $self->get('CalendarEvent.time_zone')
		->date_time_from_utc($self->get("CalendarEvent.dt$which"));
	    $self->internal_put_field(
		"${which}_date" => $_D->from_datetime($dt),
		"${which}_time" => $_T->from_datetime($dt),
	    );
	}
    }
    $self->internal_put_field(time_zone => _time_zone_display($self));
    my($augsl) = $self->req('Model.AuthUserGroupSelectList');
    if (my $rid = $self->get('CalendarEvent.realm_id')) {
	$self->internal_put_field('CalendarEvent.realm_id' => undef)
	    unless $augsl->realm_exists($rid);
    }
    if ($augsl->get_result_set_size <= 2) {
	# Will blow up if list is only "Select Forum"
	$self->internal_put_field('CalendarEvent.realm_id',
	    $augsl->set_cursor_or_die(1)->get('RealmUser.realm_id'));
    }
    return;
}

sub execute_ok {
    my($self) = @_;
    $self->internal_put_field(
	'CalendarEvent.time_zone' => _time_zone_enum($self) || return);
    $self->internal_put_error(
	'recurrence_end_date',
	$self->get('recurrence')->validate_end_date(
	    $self->unsafe_get(qw(end_date recurrence_end_date))),
    );
    return
	if $self->in_error;
    $_FM->execute_create($self->req)
	if $self->is_copy;
    _create_or_update($self);
    return _res($self)
	if $self->get('recurrence')->eq_unknown;
    $_FM->execute_create($self->req);
    my($days) = $self->get('recurrence')->period_in_days;
    my($recur_end) = $self->get('recurrence_end_date');
    while (1) {
	foreach my $field (qw(start_date end_date)) {
	    $self->internal_put_field(
		$field => $_DT->add_days($self->get($field), $days));
	}
	last
	    if $_DT->is_less_than($recur_end, $self->get('end_date'));
	_create_or_update($self);
    }
    return _res($self);
}

sub form_mode_as_string {
    my($self) = @_;
    return $self->is_copy ? 'copy' : $self->is_create ? 'create' : 'edit';
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	require_context => 1,
	visible => [
	    'CalendarEvent.realm_id',
	    'RealmOwner.display_name',
	    'CalendarEvent.description',
	    'CalendarEvent.location',
	    'CalendarEvent.url',
	    $self->field_decl(
		[
		    [qw(time_zone DisplayName NOT_NULL)],
		    [qw(start_date Date)],
		    [qw(end_date Date)],
		    [qw(start_time Time)],
		    [qw(end_time Time)],
		    [qw(recurrence CalendarEventRecurrence)],
		    [qw(recurrence_end_date Date NONE)],
		    [qw(copy_button OKButton NONE)],
		],
		undef, 'NOT_NULL',
	    ),
	],
	other => [
	    [qw(CalendarEvent.calendar_event_id RealmOwner.realm_id)],
	    'CalendarEvent.dtstart',
	    'CalendarEvent.time_zone',
	    'CalendarEvent.dtend',
	 ],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    $self->new_other('TimeZoneList')->load_all;
    my($ucel) = $self->new_other('UnauthCalendarEventList');
    if ($_FM->setup_by_list_this($ucel, 'CalendarEvent')->eq_edit) {
	$self->new_other('AuthUserGroupList')
	    ->set_ephemeral
	    ->assert_realm_exists(
		$ucel->get('CalendarEvent.realm_id'),
		$self->req('task')->get_attr_as_id('read_task'),
	    );
	$self->internal_put_field(
	    'CalendarEvent.calendar_event_id'
	         => $ucel->get('CalendarEvent.calendar_event_id'),
	);
    }
    my($augsl) = $self->new_other('AuthUserGroupSelectList')
	->load_all_for_task($self->req('task_id'));
    $self->throw_die(FORBIDDEN => {
	entity => $self->req('auth_id'),
	message => 'no authorized realms',
	auth_user => $self->req('auth_user'),
    }) if $augsl->get_result_set_size <= 1;
    $augsl->assert_realm_exists($self->get('CalendarEvent.realm_id'))
	if $self->unsafe_get('CalendarEvent.realm_id');
    return;
}

sub is_copy {
    my($self) = @_;
    return ($self->ureq('Model.UnauthCalendarEventList') || return 0)
	->is_copy_in_query
	|| $self->unsafe_get('copy_button')
	? 1 : 0;
}

sub is_create {
    my($self) = @_;
    return $self->req('Type.FormMode')->eq_create;
}

sub _create_or_update {
    my($self) = @_;
    my($start) = $_DT->from_date_and_time($self->get(qw(start_date start_time)));
    my($end) = $_DT->from_date_and_time($self->get(qw(end_date end_time)));
    return $self->internal_put_error(end_date => 'MUTUALLY_EXCLUSIVE')
	if $_DT->is_greater_than_or_equals($start, $end);
    $self->internal_put_field(
	'CalendarEvent.dtstart' =>
	    $self->get('CalendarEvent.time_zone')->date_time_to_utc($start),
	'CalendarEvent.dtend' =>
	    $self->get('CalendarEvent.time_zone')->date_time_to_utc($end),
    );
    if ($self->is_create) {
	$self->internal_put_field('CalendarEvent.calendar_event_id' => undef);
	$self->new_other('CalendarEvent')->create_realm(
	    $self->get_model_properties('CalendarEvent'),
	    $self->get_model_properties('RealmOwner'),
	);
    }
    else {
	$self->update_model_properties('CalendarEvent');
	$self->update_model_properties('RealmOwner');
    }
    return;
}

sub _res {
    my($self) = @_;
    $_A->save_label(
	$self->req('task_id')->get_name
	    . '.'
	    . (!$self->get('recurrence')->eq_unknown ? 'recurrence'
	    : $self->is_copy ? 'copy'
	    : $self->is_create ? 'create'
	    : 'edit'),
	$self->req,
    );
#TODO: Need to redirect to the right forum's calendar if added in a different forum and not the user's realm.  The date of the start should be the date shown.
    return;
}

sub _time_zone_display {
    my($self) = @_;
    my($tz) = $self->get('CalendarEvent.time_zone');
    my($tzl) = $self->req('Model.TimeZoneList');
    return $tz->as_display_name
	unless $tzl->find_row_by(enum => $tz);
    return $tzl->get('display_name');
}

sub _time_zone_enum {
    my($self) = @_;
    my($tzl) = $self->req('Model.TimeZoneList');
    my($tz) = $self->get('time_zone');
    return $tzl->get('enum')
	if $tzl->find_row_by(display_name => $tz);
    return $tz
	if $tz = $_TZ->unsafe_from_any($tz);
    return $self->internal_put_error(time_zone => 'NOT_FOUND');
}

1;
