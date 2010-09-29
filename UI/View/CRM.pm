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
    my($self, $model) = @_;
    my($m) = $model->simple_package_name;
    return [
	["$m.action_id", {
	    wf_class => 'Select',
	    list_display_field => 'name',
	    choices => ['->req', 'Model.CRMActionList'],
	    list_id_field => 'id',
	}],
	$self->internal_tuple_tag_form_fields($model),
    ];
}

sub internal_reply_list {
    return qw(all realm);
}

sub internal_standard_tools {
    shift->SUPER::internal_standard_tools([
        {
	    task_id => 'FORUM_CRM_THREAD_ROOT_LIST_CSV',
	    control => ['!', 'task_id', '->eq_forum_crm_form'],
	    query => ['->req', 'query'],
	},
    ]);
    return;
}

sub internal_thread_root_list_columns {
    my($self, $model) = @_;
    return [
	_update_uri_column(qw(CRMThread.crm_thread_num String)),
	# WidgetFactory uses singleton to find type so we have to do it here
	map([$_, {
	    wf_type => $model->get_field_type($_),
	    column_heading => String(vs_text($model->simple_package_name, $_)),
	}], $model->tuple_tag_field_check),
 	['RealmMail.from_email', {
	    column_widget => String(['RealmMail.from_email']),
	}],
	_update_uri_column(qw(CRMThread.crm_thread_status Enum)),
	_update_uri_column(qw(owner_name String)),
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

sub internal_tuple_tag_form_fields {
    my($self, $model) = @_;
    return map([$model->simple_package_name . ".$_", {
	wf_type => $model->get_field_type($_),
    }], $model->tuple_tag_field_check);
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
    vs_put_pager('CRMThreadRootList');
    return $self->internal_body([sub {
	return $self->internal_thread_root_list(
	    $self->internal_thread_root_list_columns(
		$_M->from_req(shift->req, 'CRMThreadRootList'),
	    ),
	);
    }])
}

sub thread_root_list_csv {
    return shift->internal_body(
	CSV('CRMThreadRootList', [
	    'CRMThread.crm_thread_num',
	    map($_, b_use('Model.CRMThreadRootList')->tuple_tag_field_check),
	    'RealmMail.from_email',
	    'CRMThread.crm_thread_status',
	    'owner_name',
	    'CRMThread.subject',
	    'CRMThread.modified_date_time',
	    'modified_by_name',
        ], {
	    want_iterate_start => 1,
	}),
    );
}

sub _update_uri_column {
    my($field, $widget) = @_;
    return [$field, {
	column_widget => Link(vs_call($widget, [$field]), ['->update_uri']),
    }];
}

1;
