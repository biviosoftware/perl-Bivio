# Copyright (c) 2007-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::Calendar;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_D) = b_use('Type.Date');
my($_DT) = b_use('Type.DateTime');
my($_UCEL) = b_use('Model.UnauthCalendarEventList')->get_instance;
my($_CEMF) = b_use('Model.CalendarEventMonthForm')->get_instance;
my($_CEF) = b_use('Model.CalendarEventForm')->get_instance;
my($_CEWL) = b_use('Model.CalendarEventWeekList')->get_instance;

sub event_delete {
    view_put(xhtml_rss_task => 'FORUM_CALENDAR_EVENT_LIST_RSS');
    return shift->internal_body(vs_simple_form(CalendarEventDeleteForm => []));
}

sub event_detail {
    my($self) = @_;
    view_put(
	xhtml_rss_task => 'FORUM_CALENDAR_EVENT_LIST_RSS',
	xhtml_tools => TaskMenu([
	    map({
		my($task, $label) = @$_;
		$label ||= '';
#TODO: Modularize better.  This is really messy code to have in a view.
		ref($task) eq 'HASH' ? $task : +{
		    task_id => $task,
		    realm => [qw(Model.CalendarEventList owner.RealmOwner.name)],
		    $label ? (label => vs_text_as_prose("task_menu.title.FORUM_CALENDAR_EVENT_FORM.$label"))
			: (),
		    ($label eq 'create') ? () : (query => {
			'ListQuery.this' => [qw(Model.CalendarEventList CalendarEvent.calendar_event_id)],
			$label eq 'copy' ? ($_UCEL->IS_COPY_QUERY_KEY => 1) : (),
		    }),
		    $label eq 'copy' ? (
			realm => $self->req(qw(auth_user name)),
			control => [qw(Model.CalendarEventList ->can_user_edit_any_realm)],
		    ) : $label eq 'create' ? (
			control => [qw(Model.CalendarEventList ->can_user_edit_any_realm)],
		    ) : (
			control => [qw(Model.CalendarEventList ->can_user_edit_this_realm)],
		    ),
		};
	    }
		[qw(FORUM_CALENDAR_EVENT_FORM create)],
		[qw(FORUM_CALENDAR_EVENT_FORM copy)],
		[qw(FORUM_CALENDAR_EVENT_DELETE)],
		[qw(FORUM_CALENDAR_EVENT_FORM edit)],
		[_user_list_link()],
		[qw(FORUM_CALENDAR_EVENT_ICS)],
	    ),
	]),
    );
    return $self->internal_body(vs_paged_detail('CalendarEventList',
	[qw(THIS_LIST FORUM_CALENDAR)],
	WithModel('CalendarEventList', Grid([
	    map([
		vs_label_cell("CalendarEventList.$_"),
		vs_display("CalendarEventList.$_")->put(cell_class => 'field'),
	    ], (
		'RealmOwner.display_name',
		'owner.RealmOwner.display_name',
		'time_zone',
		'dtstart_with_tz',
		'dtend_with_tz',
		'CalendarEvent.description',
		'CalendarEvent.location',
		'CalendarEvent.url',
	    )),
	], {
	    class => 'simple',
	})),
    ));
}

sub event_form {
    my($self) = @_;
    view_put(xhtml_rss_task => 'FORUM_CALENDAR_EVENT_LIST_RSS');
    return $self->internal_body(vs_simple_form(
	CalendarEventForm => [
	    'CalendarEventForm.RealmOwner.display_name',
	    ['CalendarEventForm.CalendarEvent.realm_id', {
		choices => ['Model.AuthUserGroupSelectList'],
		list_display_field => 'RealmOwner.name',
		list_id_field => 'RealmUser.realm_id',
	    }],
	    'CalendarEventForm.time_zone_selector',
	    'CalendarEventForm.start_date',
	    'CalendarEventForm.start_time',
	    'CalendarEventForm.end_date',
	    'CalendarEventForm.end_time',
	    'CalendarEventForm.CalendarEvent.description',
	    'CalendarEventForm.CalendarEvent.location',
	    'CalendarEventForm.CalendarEvent.url',
	    ['CalendarEventForm.recurrence' => {
		enum_sort => 'get_short_desc',
		wf_want_select => 1,
		column_count => 1,
	    }],
	    'CalendarEventForm.recurrence_end_date',
	    '*ok_button cancel_button',
	],
    ));
}

sub event_list_rss {
    return shift->internal_body(AtomFeed('CalendarEventList'));
}

sub full_calendar_list_json {
    my($self) = @_;
    return $self->internal_body(Simple(
	[
	    sub {
		my($source) = @_;
		return ${MIME_JSON()->to_text(
		    $source->req('Model.FullCalendarList')->as_type_values,
		)};
	    },
	],
    ));
}

sub list {
    my($self) = @_;
    view_put(xhtml_rss_task => 'FORUM_CALENDAR_EVENT_LIST_RSS');
    $self->internal_put_base_attr(
	tools => TaskMenu([
	    {
		task_id => 'FORUM_CALENDAR_EVENT_FORM',
		label => 'FORUM_CALENDAR_EVENT_FORM.create',
		control => [qw(Model.CalendarEventMonthList ->can_user_edit_any_realm)],
	    },
	    _user_list_link(),
	    'FORUM_CALENDAR_EVENT_LIST_ICS',
	], {
	    selected_item => 0,
	}),
	selector => vs_selector_form($_CEMF->simple_package_name => [
	    Select($_CEMF->get_select_attrs('b_month')),
	    Checkbox('b_time_zone', {control => vs_constant('Calendar.want_b_time_zone')}),
	    Checkbox('b_list_view'),
	]),
    );
    return $self->internal_body(If(
	['Model.CalendarEventMonthList', '->is_list_view'],
	_list_view(),
	_month_view(),
    ));
}

sub _list_view {
    my($self) = @_;
    return vs_list(CalendarEventMonthList => [
	[dtstart_with_tz => {
	    column_data_class => 'b_datetime',
	    column_order_by => ['CalendarEvent.dtstart'],
	}],
	'time_zone',
	map([$_ => {
	    wf_list_link => {
		realm => ['owner.RealmOwner.name'],
		query => 'THIS_DETAIL',
		task => 'FORUM_CALENDAR_EVENT_DETAIL',
	    },
	}], qw(
	    RealmOwner.display_name
	    CalendarEvent.location
	)),
	['owner.RealmOwner.display_name' => {
	    wf_list_link => {
		href => URI({
		    task_id => 'FORUM_CALENDAR',
		    realm => ['owner.RealmOwner.name'],
		}),
	    },
	}],
	{
	    column_heading => String(vs_text('CalendarEventMonthList.list_actions')),
	    column_widget => ListActions([
		map({
		    my($task) = $_ =~ /^(\w+)/;
		    [
			vs_text_as_prose("CalendarEventMonthList.list_action.$_"),
			$task,
			URI({
			    task_id => $task,
			    query => [qw(->format_query THIS_DETAIL)],
			    realm => ['owner.RealmOwner.name'],
			}),
			['->can_user_edit_this_realm'],
		    ];
		}
		    'FORUM_CALENDAR_EVENT_DELETE',
		    'FORUM_CALENDAR_EVENT_FORM.edit',
		),
	    ], {
		column_control => [
		    [qw(->req Model.CalendarEventMonthList)],
		    '->can_user_edit_any_realm',
		],
	    }),
	},
    ], {
	class => 'list b_list_calendar',
    });
}

sub _month_view {
    return Table($_CEWL->simple_package_name => [
	map([$_ => {
	    column_widget => Join([
		SPAN_b_day_of_month(["day_of_month_$_"]),
		With(
		    ["day_list_$_"],
		    Link(
			String(['time_and_name']),
			URI({
			    task_id => 'FORUM_CALENDAR_EVENT_DETAIL',
			    query => [qw(->format_query THIS_DETAIL)],
			    realm => ['owner.RealmOwner.name'],
			}),
			{class => 'b_event_name'},
		    ),
		),
		Link(
		    vs_text_as_prose('task_menu.title.FORUM_CALENDAR_EVENT_FORM.create'),
		    URI({
			task_id => 'FORUM_CALENDAR_EVENT_FORM',
			query => {
			    $_CEF->CREATE_DATE_QUERY_KEY
			        => ["create_date_$_", 'HTMLFormat.DateTime', 'DATE', 1],
			},
		    }),
		    {
			control =>
			    [[qw(->req Model.CalendarEventMonthList)], '->show_create_on_month_view'],
			class => 'b_day_of_month_create',
			STYLE => [sub {
			    my(undef, $list) = @_;
			    my($i) = $list->get_result_set_size;
			    return 'height: '
				. ($i >= 4 ? '3' : (7 - $i))
				. 'ex;';
			}, ["day_list_$_"]],
		    },
		),
	    ]),
	    column_data_class => Join([
		If(
		    ["in_this_month_$_"],
		    'b_date_this_month',
		    'b_date_other_month',
		),
		If(["is_today_$_"], 'b_is_today'),
	    ], {
		join_separator => ' ',
	    }),
	}], $_CEWL->day_of_week_suffix_list),
    ], {
	source_name => ['Model.CalendarEventMonthList', '->week_list'],
	class => 'b_month_calendar',
	odd_row_class => '',
	even_row_class => '',
    });
}

sub _user_list_link {
    return {
	task_id => 'FORUM_CALENDAR',
	label => vs_text_as_prose(
	    'task_menu.title.FORUM_CALENDAR.user'),
	realm => ['auth_user', 'name'],
	control => And(
	    ['auth_user_id'],
	    ['!', ['auth_realm', 'type'], '->eq_user'],
	),
    };
}

1;
