# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::CRM;
use strict;
use Bivio::Base 'View.Mail';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_T) = b_use('MIME.Type');
my($_M) = b_use('Biz.Model');
my($_CTS) = b_use('Type.CRMThreadStatus');
my($_UIT) = b_use('FacadeComponent.Text');
my($_DT) = b_use('Type.DateTime');

sub close_form {
    my($self) = @_;
    return $self->internal_body(vs_simple_form('CRMCloseForm', [
	Join([
	    'Close ticket #',
	    String(['Model.CRMThread', 'crm_thread_num']),
	    ' - ',
	    String(['Model.CRMThread', 'subject']),
	    '?',
	]),
	'CRMCloseForm.do_not_show_again',
    ]));
}

sub field_updates_imail {
    my($self) = @_;
    return $self->internal_put_base_attr(
	from => [qw(Model.CRMForm ->mail_header_from)],
	headers_object => ['Model.CRMForm'],
	body => [sub {
            my($source) = @_;
	    my($old) = $source->req(qw(Model.CRMForm old_fields));
	    my($new) = $source->req(qw(Model.CRMForm new_fields));
	    my($buffer) = '';
	    my($skip) = 0;
	    foreach my $which (qw(status change)) {
		last
		    if $skip;
		foreach my $k (sort({
		    $a eq 'crm_thread_status' && $b eq 'owner_user_id' ? -1
		    : $b eq 'crm_thread_status' && $a eq 'owner_user_id' ? 1
		    : $a =~ /^(crm_thread_status|owner_user_id)$/ ? -1
		    : $b =~ /^(crm_thread_status|owner_user_id)$/ ? 1
		    : $a cmp $b;
		} keys(%$new))) {
		    my($label, $ov, $nv) = (
			ref($new->{$k}) eq 'ARRAY'
			    ? $k : $_UIT->get_value("CRMForm.$k", $source->req),
			$old->{$k},
			$new->{$k},
		    );
		    _update_text($which, $label, map({
			my($x) = $_;
			if ($k eq 'crm_thread_status') {
			    $skip++
				if $x->eq_unknown;
			    $x = $x->get_short_desc;
			}
			elsif ($k eq 'owner_user_id') {
			    $x = $source->req('Model.CRMForm')
				->new_other('RealmOwner')
				->unauth_load_or_die(
				    realm_id => $x,
				)->get('display_name')
				    if $x;
			}
			else {
			    $x = $x->[0] && $x->[1] =~ /Date/
				? $_DT->to_mm_dd_yyyy($x->[0])
				: $x->[0];
			}
			$x = $_UIT->get_value('CRMForm.empty_label', $source->req)
			    unless $x;
			$x;
		    } ($ov, $nv)),
		    \$buffer);
		}
		$buffer .= "\n"
		    if $which eq 'status';
	    }
	    return MIMEEntity({
		mime_type => 'text/plain',
		mime_data => $buffer,
		mime_encoding => $_T->suggest_encoding('text/plain', \$buffer),
	    });
	}],
    );
}

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
	["$m.owner_user_id", {
            choices => ['Model.CRMUserList'],
	    list_display_field => 'RealmOwner.name',
	    list_id_field => 'RealmUser.user_id',
            unknown_label => vs_text($m, 'unknown_owner_user_id'),
	}],
	["$m.crm_thread_status", {
            choices => Bivio_TypeValue(
                $_CTS,
                [
                    $_CTS->CLOSED,
                    $_CTS->OPEN,
                    $_CTS->PENDING_CUSTOMER,
                ],
            ),
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
	    column_data_class => 'b_word_break_all',
 	}],
 	'CRMThread.modified_date_time',
 	'modified_by_name',
	vs_actions_column([
	    ['close', 'FORUM_CRM_CLOSE', 'THIS_AS_PARENT'],
	]),
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
	    vs_inline_form(
		$f->simple_package_name,
		[
		    map(
			Select({
			    %{$f->get_select_attrs($_)},
			    unknown_label => vs_text('CRMQueryForm', $_),
			    auto_submit => 1,
			    $_ eq 'b_status' ? (
				enum_display => 'get_desc_for_query_form',
			    ) : (),
			}),
			grep($f->get_field_type($_)->isa(
			    'Bivio::Type::TupleChoiceList'),
			     $f->tuple_tag_field_check),
			'b_status',
		    ),
		    Select({
			%{$f->get_select_attrs('b_owner')},
                        choices => ['Model.CRMUserList'],
                        list_display_field => 'RealmOwner.name',
                        list_id_field => 'RealmUser.user_id',
                        unknown_label => vs_text($f->simple_package_name, 'b_owner'),
			auto_submit => 1,
		    }),
		    ScriptOnly({
			widget => Simple(''),
			alt_widget => FormButton('ok_button')
			    ->put(label => 'Refresh'),
		    }),
		],
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

sub _update_text {
    my($which, $label, $old, $new, $buffer) = @_;
    $$buffer .= "$label: $new\n"
	if $which eq 'status';
    $$buffer .= "$label changed from $old to $new\n"
	if $which eq 'change' && $old ne $new;
    return;
}

sub _update_uri_column {
    my($field, $widget) = @_;
    return [$field, {
	column_widget => Link(vs_call($widget, [$field]), ['->update_uri']),
    }];
}

1;
