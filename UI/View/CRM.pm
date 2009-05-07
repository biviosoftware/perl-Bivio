# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::CRM;
use strict;
use Bivio::Base 'View.Mail';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_M) = b_use('Biz.Model');

sub internal_crm_send_form_buttons {
    my(undef, $model) = @_;
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
    my(undef, $model) = @_;
    my($m) = $model->simple_package_name;
    return [
	["$m.action_id", {
	    wf_class => 'Select',
	    list_display_field => 'name',
	    choices => ['->req', 'Model.CRMActionList'],
	    list_id_field => 'id',
	}],
	map(["$m.$_", {
	    wf_type => $model->get_field_type($_),
	}], $model->tuple_tag_field_check),
    ];
}

sub internal_reply_list {
    return qw(all realm);
}

sub internal_thread_root_list_columns {
    my($self, $model) = @_;
    return [
	['CRMThread.crm_thread_num', {
	    column_widget => Link(
		String(['CRMThread.crm_thread_num']),
		['->drilldown_uri'],
	    ),
	}],
	# WidgetFactory uses singleton to find type so we have to do it here
	map([$_, {
	    wf_type => $model->get_field_type($_),
	    column_heading => String(vs_text($model->simple_package_name, $_)),
	}], $model->tuple_tag_field_check),
 	['RealmMail.from_email', {
	    column_widget => String(['RealmMail.from_email']),
	}],
	['CRMThread.crm_thread_status', {
	    column_widget => Link(
		Enum(['CRMThread.crm_thread_status']),
		['->drilldown_uri'],
	    ),
	}],
	'owner_name',
#TODO: Put this in second row with colspan below all this other stuff
 	['CRMThread.subject', {
 	    order_by_names => 'CRMThread.subject_lc',
	    column_widget => Link(
		String(['CRMThread.subject']),
		['->drilldown_uri'],
	    ),
 	}],
 	'CRMThread.modified_date_time',
 	'modified_by_name',
    ];
}

sub send_form {
    my($self, $extra_fields) = @_;
    return $self->internal_body([sub {
        return $self->internal_send_form(
	    $extra_fields ? @$extra_fields
		: $self->internal_crm_send_form_extra_fields(
		    $self->internal_form_model(shift->req)),
	    $self->internal_crm_send_form_buttons,
	),
    }]);
}

sub thread_root_list {
    my($self) = @_;
    $self->internal_put_base_attr(
        selector => [sub {
	    my($f) = $_M->from_req(shift->req, 'CRMQueryForm');
	    Form(
		$f->simple_package_name,
		Join([
		    map(
			Select({
			    %{$f->get_select_attrs($_)},
			    unknown_label => vs_text('CRMQueryForm', $_),
			    auto_submit => 1,
			    $_ eq 'b_status' ? (
				enum_display => 'get_desc_for_query_form',
			    ): (),
			}),
			grep($f->get_field_type($_)->isa(
			    'Bivio::Type::TupleChoiceList'),
			     $f->tuple_tag_field_check),
			qw(b_status b_owner_name),
		    ),
		    ScriptOnly({
			widget => Simple(''),
			alt_widget => FormButton('ok_button')
			    ->put(label => 'Refresh'),
		    }),
		]),
		{
		    form_method => 'get',
		    want_timezone => 0,
		    want_hidden_fields => 0,
		},
	    ),
	}],
    );
    return $self->internal_body([sub {
	return $self->internal_thread_root_list(
	    $self->internal_thread_root_list_columns(
		$_M->from_req(shift->req, 'CRMThreadRootList'),
	    ),
	);
    }])
}

1;
