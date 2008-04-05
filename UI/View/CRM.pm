# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::CRM;
use strict;
use Bivio::Base 'View.Mail';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_CF) = __PACKAGE__->use('Model.CRMForm')->get_instance;

sub internal_reply_list {
    return qw(all realm);
}

sub send_form {
    return shift->SUPER::send_form(
	[
	    ['CRMForm.action_id', {
		wf_class => 'Select',
		list_display_field => 'name',
		choices => ['->req', 'Model.CRMActionList'],
		list_id_field => 'id',
		row_control => ['Model.CRMForm', '->show_action'],
	    }],
	    @{$_CF->tuple_tag_map_slots('ticket.CRMThread.thread_root_id', sub {
		my($field) = @_;
	        return [TupleTagSlotLabel($field), TupleTagSlotField($field)];
	    })},
	],
	'*ok_button update_only cancel_button',
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
