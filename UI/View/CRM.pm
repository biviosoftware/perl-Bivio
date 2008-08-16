# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::CRM;
use strict;
use Bivio::Base 'View.Mail';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_crm_send_form_buttons {
    return StandardSubmit({
	buttons => Join([
	    'ok_button',
 	    If([qw(! ->req form_model is_new)],
 	       'update_only',
 	    ),
	    'cancel_button',
	], {join_separator => ' '}),
    });
}

sub internal_crm_send_form_extra_fields {
    my($self, $p) = shift->name_parameters([qw(action label field)], \@_);
    my($form) = b_use('Model', $self->internal_name . 'Form')->get_instance;
    return [
        [$form->simple_package_name . '.action_id', {
	    wf_class => 'Select',
	    list_display_field => 'name',
	    choices => ['->req', 'Model.CRMActionList'],
	    list_id_field => 'id',
	    %{$p->{action} || {}},
	}],
	@{$form->tuple_tag_map_slots(sub {
	    my($field) = @_;
	    return [
		TupleTagSlotLabel($field, $p->{label}),
		TupleTagSlotField($field, $p->{field}),
	    ];
	})},
    ];
}

sub internal_reply_list {
    return qw(all realm);
}

sub send_form {
    my($self, $extra_fields, $buttons) = @_;
    Bivio::IO::Alert->warn_deprecated('use internal_crm_send_form_buttons')
        if $buttons;
    $extra_fields ||= $self->internal_crm_send_form_extra_fields;
    $buttons ||= $self->internal_crm_send_form_buttons;
    return $self->SUPER::send_form(
	[
	    $buttons,
	    @$extra_fields
	],
	$buttons,
    );
}

sub thread_root_list {
    return shift->SUPER::thread_root_list(
	'CRMThread.modified_date_time',
	'modified_by_name',
	'CRMThread.crm_thread_num',
	'RealmFile.modified_date_time',
	'RealmMail.from_email',
	['CRMThread.subject', {
	    order_by_names => 'CRMThread.subject_lc',
	}],
	'CRMThread.crm_thread_status',
	'owner_name',
    );
}

1;
