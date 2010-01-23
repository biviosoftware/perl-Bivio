# Copyright (c) 2007-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::Calendar;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = b_use('Type.Date');
my($_DT) = b_use('Type.DateTime');
my($_UCEL) = b_use('Model.UnauthCalendarEventList')->get_instance;
my($_CEMF) = b_use('Model.CalendarEventMonthForm')->get_instance;
my($_CEWL) = b_use('Model.CalendarEventWeekList')->get_instance;

sub event_delete {
    view_put(xhtml_rss_task => 'FORUM_CALENDAR_EVENT_LIST_RSS');
    return shift->internal_body(vs_simple_form(CalendarEventDeleteForm => []));
}

sub event_detail {
    my($self) = @_;
    view_put(
	xhtml_rss_task => 'FORUM_CALENDAR_EVENT_LIST_RSS',
	xhtml_title => String(
	    ['Model.CalendarEventList', 'RealmOwner.display_name']),
	xhtml_tools => TaskMenu([
	    map({
		my($task, $label) = @$_;
		$label ||= '';
#TODO: Modularize better.  This is really messy code to have in a view.
		+{
		    task_id => $task,
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
		'owner.RealmOwner.display_name',
		'time_zone',
		'dtstart_tz',
		'dtend_tz',
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
	    ['CalendarEventForm.CalendarEvent.realm_id', {
		choices => ['Model.AuthUserGroupSelectList'],
		list_display_field => 'RealmOwner.name',
		list_id_field => 'RealmUser.realm_id',
	    }],
	    'CalendarEventForm.RealmOwner.display_name',
	    ['CalendarEventForm.time_zone', {
		wf_widget => ComboBox({
		    field => 'time_zone',
		    list_class => 'TimeZoneList',
		    list_display_field => ['display_name'],
		}),
	    }],
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
#TODO: Do we need copy_button?
	    '*ok_button cancel_button',
	],
    ));
}

sub event_list_rss {
    return shift->internal_body(AtomFeed('CalendarEventList'));
}

sub list {
    my($self) = @_;
    view_put(xhtml_rss_task => 'FORUM_CALENDAR_EVENT_LIST_RSS');
    $self->internal_put_base_attr(
	tools => TaskMenu([
	    {
		task_id => 'FORUM_CALENDAR',
		label => vs_text_as_prose(
		    'task_menu.title.FORUM_CALENDAR.user'),
		realm => ['->req', 'auth_user', 'name'],
		control => And(
		    ['->req', 'auth_user'],
		    ['!', ['->req', 'auth_realm', 'type'], '->eq_user'],
		),
	    },
	    'FORUM_CALENDAR_EVENT_LIST_ICS',
	]),
	selector => vs_selector_form($_CEMF->simple_package_name => [
	    Select($_CEMF->get_select_attrs('b_month')),
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
	[dtstart_tz => {
	    column_data_class => 'datetime',
	}],
	'time_zone',
	['RealmOwner.display_name' => {
	    wf_list_link => {
		query => 'THIS_DETAIL',
		task => 'FORUM_CALENDAR_EVENT_DETAIL',
	    },
	}],
	'CalendarEvent.location',
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
	class => 'list list_calendar',
    });
}

sub _month_view {
    return Table($_CEWL->simple_package_name => [
	map([$_ => {
	    column_widget => Join([
		SPAN_day_of_month(["day_of_month_$_"]),
		With(
		    ["day_list_$_"],
		    Link(
			String(['RealmOwner.display_name']),
			['->detail_uri'],
			{class => 'event_name'},
		    ),
		),
	    ]),
	    column_data_class => If(
		["in_this_month_$_"],
		'date_this_month',
		'date_other_month',
	    ),
	}], $_CEWL->day_of_week_suffix_list),
    ], {
	source_name => ['Model.CalendarEventMonthList', '->week_list'],
	class => 'month_calendar',
	odd_row_class => '',
	even_row_class => '',
    });
}

1;
