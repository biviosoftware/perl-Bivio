# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::TaskLog;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_add_filter {
    my($self) = @_;
    my($f) = b_use('Model.TaskLogQueryForm')->get_instance;
    $self->internal_put_base_attr(selector => Join([
	Form($f->simple_package_name, Join([
	    ClearOnFocus(
		Text({
		    field => 'x_filter',
		    id => 'x_filter',
		    size => int(b_use('Type.Line')->get_width / 2),
		    max_width => $f->get_field_type('x_filter')->get_width,
		}),
		$f->CLEAR_ON_FOCUS_HINT,
	    ),
	    ScriptOnly({
		widget => Simple(''),
		alt_widget => FormButton('ok_button')->put(label => 'Refresh'),
	    }),
	]), {
	    form_method => 'get',
	    want_timezone => 0,
	    want_hidden_fields => 0,
	}),
    ]));
    return;
}

sub list {
    my($self, $extra_cols) = @_;
    $self->internal_add_filter;
    view_unsafe_put(
	xhtml_tools => Link(vs_text('title.GROUP_TASK_LOG_CSV'),
	    ['->format_uri', [qw(task ->get_attr_as_id csv_task)]]),
    );
    return $self->internal_body(vs_paged_list('TaskLogList', [
	['TaskLog.date_time', {
	    column_widget => Join([
		Join([
		    SPAN_date(DateTime(['TaskLog.date_time'], 'DATE_TIME')),
		    Join([
			SPAN_super_user(
			    String(['super_user.RealmOwner.name'])),
			' acting as',
		    ], {control => ['TaskLog.super_user_id']}),
		    SPAN_author(Join([
			String(['RealmOwner.display_name']),
			String(
			    Join(['<', ['Email.email'], '>']),
			    {escape_html => 1},
			),
			$extra_cols ? @$extra_cols : (),
		    ], {join_separator => ' '})),
		], {join_separator => ' '}),
		DIV_uri(String(['TaskLog.uri'])),
	    ]),
	}],
    ], {
	class => 'paged_list task_log',
	show_headings => 0,
    }));
}

sub list_csv {
    my($self, $extra_cols) = @_;
    return shift->internal_body(CSV(TaskLogList => [qw(
        TaskLog.date_time
	super_user.RealmOwner.name
	RealmOwner.display_name
	Email.email
        TaskLog.uri
    ),
	$extra_cols ? @$extra_cols : (),
    ]));
}

1;
