# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::TaskLog;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub list {
    my($self) = @_;
    my($f) = $self->use('Model.TaskLogQueryForm');
    $self->internal_put_base_attr(selector => Join([
	ECMAScript(<<"EOF"),
function task_log_x_filter_onfocus (field) {
    if (field.value == "@{[$f->X_FILTER_HINT]}") {
        field.value = "";
    }
    field.className = "element enabled";
    return;
}
EOF
	Form($f->simple_package_name, Join([
	    Text({
		field => 'x_filter',
		id => 'x_filter',
		class => 'element disabled',
		ONFOCUS => 'task_log_x_filter_onfocus(this)',
		size => b_use('Type.Name')->get_width,
		max_width => b_use('Type.Line')->get_width,
	    }),
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
			String(['Phone.phone']),
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

1;
