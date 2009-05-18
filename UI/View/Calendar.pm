# Copyright (c) 2007-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::Calendar;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = __PACKAGE__->use('Type.Date');
my($_DT) = __PACKAGE__->use('Type.DateTime');

sub event_delete {
    my($self) = @_;
    view_put(
	xhtml_title => Join([
	    'Remove event: ',
	    String([['Model.CalendarEvent', '->get_model', 'RealmOwner'],
		    'display_name']),
	]),
    );
    return $self->internal_body(vs_simple_form(CalendarEventDeleteForm => [
	Join([
	    'This will permanently remove this event from the ',
	    String([qw(auth_realm owner display_name)]),
	    ' calendar.',
	]),
    ]));

}

sub event_detail {
    my($self) = @_;
    view_put(
	xhtml_title => String(['Model.CalendarEventList',
	    'RealmOwner.display_name']),
	xhtml_tools => TaskMenu([
	    {
		task_id => 'FORUM_CALENDAR_EVENT',
		uri => ['->format_uri', 'FORUM_CALENDAR_EVENT'],
	    },
 	    {
 		task_id => 'FORUM_CALENDAR_EVENT_DELETE',
 		uri => ['->format_uri', 'FORUM_CALENDAR_EVENT_DELETE'],
 	    },
	    {
		task_id => 'FORUM_CALENDAR_EVENT_ICS',
		uri => ['->format_uri', 'FORUM_CALENDAR_EVENT_ICS'],
	    },
	    {
		task_id => 'FORUM_CALENDAR_EVENT',
		label => String('Create Event'),
		query => undef,
	    },
	]),
    );
    return $self->internal_body(vs_paged_detail('CalendarEventList',
	[qw(THIS_LIST FORUM_CALENDAR)],
	DIV_list(Grid([
	    map([
		SPAN_label_ok(String($_->[0] . ':')),
		$_->[1] ? $_->[1] : (),
	    ], (
		[Description => String(['Model.CalendarEventList',
		    'CalendarEvent.description'])],
		[Location => String(['Model.CalendarEventList',
		    'CalendarEvent.location'])],
		[URL => Link(['Model.CalendarEventList', 'CalendarEvent.url'],
		    ['Model.CalendarEventList', 'CalendarEvent.url'])],
		['Time Zone' => Enum(['Model.CalendarEventList',
		    'CalendarEvent.time_zone'])],
		['Start', _date_time('dtstart_in_tz')],
		['End', _date_time('dtend_in_tz')],
		['Local Time'],
		map([ucfirst($_) => DateTime({
		    field => 'CalendarEvent.dt' . $_,
		    value => ['Model.CalendarEventList',
			'CalendarEvent.dt' . $_],
		    mode => 'DAY_MONTH3_YEAR_TIME',
		})], qw(start end)),
	    )),
	])),
    ));
}

sub event_form {
    my($self) = @_;
    return $self->internal_body(vs_simple_form(
	CalendarEventForm => [qw(
	    CalendarEventForm.RealmOwner.display_name
	    CalendarEventForm.start_date
 	    CalendarEventForm.start_time
	    CalendarEventForm.end_date
 	    CalendarEventForm.end_time
	    CalendarEventForm.CalendarEvent.time_zone
	    CalendarEventForm.CalendarEvent.location
	    CalendarEventForm.CalendarEvent.url
	    CalendarEventForm.CalendarEvent.description
	)],
    ));
}

sub event_list_rss {
    return shift->internal_body(AtomFeed('CalendarEventList'));
}

sub month_list {
    my($self) = @_;
    view_pre_execute(sub {
	my($req) = @_;
	my($v) = {};
	$v->{date} = $_D->add_days(
	    $_DT->from_literal_or_die(
		$req->get('Model.CalendarEventMonthList')->get_query
		    ->get('date')), -1);
	$v->{current} = $_D->date_from_parts(
	    1, $_D->get_parts($v->{date}, qw(month year)));
	while ($_D->english_day_of_week($v->{current}) ne 'Sunday') {
	    $v->{current} = $_D->add_days($v->{current}, -1);
	}
	$v->{current} = $_D->add_days($v->{current}, -7);
	_globals($req, $v);
	return;
    });
    view_put(xhtml_rss_task => 'FORUM_CALENDAR_EVENT_LIST_RSS');
    $self->internal_put_base_attr(tools => TaskMenu([
        {
	    task_id => 'FORUM_CALENDAR_EVENT',
	    label => String('Create Event'),
	    query => undef,
	},
    ]));
    return $self->internal_body(Join([
	DIV_month_selection(Form('SelectMonthForm', Grid([[
	    String('Month:'),
	    Select({
		field => 'begin_date',
		choices => ['Model.MonthList'],
		list_display_field => 'month',
		list_id_field => 'date',
		auto_submit => 1,
	    }),
	    ScriptOnly({
		widget => Join([]),
		alt_widget => FormButton('ok_button', {
		    label => 'Refresh',
		}),
	    }),
	]]))),
        DIV_month_calendar(Grid([
            [
		map(_heading_cell(), (1 .. 7))
	    ],
            map([
		map(_date_cell(), (1 .. 7))
	    ], (1 .. 6)),
        ])),
    ]));
}

sub _date_cell {
    return Join([
        DIV_day_of_month(String([
	    sub {
		my($source) = @_;
		my($v) = _globals($source);
		return sprintf('%2d ', $_D->get_parts($v->{current}, 'day'));
	    }
	])),
        _event_links(),
    ])->put(
	cell_class => [
	    sub {
		my($v) = _globals(shift);
		return _is_same_month($v->{date}, $v->{current}) ?
		    'date_this_month' : 'date_other_month';
	    }
	],
        row_control => [
	    sub {
		my($v) = _globals(shift);
		# don't show the last row if it is all in the next month
		if ($_D->english_day_of_week($v->{current}) eq 'Sunday'
			&& $_D->compare($v->{current}, $v->{date}) > 0
			    && ! _is_same_month($v->{current}, $v->{date})) {
		    return 0;
		}
		return 1;
	    }
	],
    );
}

sub _date_time {
    my($field) = @_;
    return Join([
	String({
	    field => $field,
	    value => [
		['Model.CalendarEventList', $field],
		'HTMLFormat.DateTime',
		'DAY_MONTH3_YEAR',
		1,
	    ],
	}),
	String({
	    field => $field,
	    value => [
		'Bivio::Type::Time', '->to_string',
		['Model.CalendarEventList', $field],
	    ],
	}),
    ], ' ');
}

sub _event_links {
#TODO: bug - if event is on the first it will be lost
# (also if event spans the month boundary, it needs to show up)
    return Join([
	List('CalendarEventMonthList', [
	    If([sub {
	        my($list) = @_;
		my($v) = _globals($list->req);
		my($start) = $_D->from_datetime($list->get('dtstart_in_tz'));
		my($end) = $_D->from_datetime($list->get('dtend_in_tz'));
		return 0 unless $_D->compare($start, $v->{current}) == 0
		    || $_D->compare($end, $v->{current}) == 0
		    || ($_D->compare($start, $v->{current}) == -1
			&& $_D->compare($end, $v->{current}) == 1);
		return 1;
	    }], DIV_event(Link(String(['RealmOwner.display_name']),
		['->format_uri', 'THIS_DETAIL', 'FORUM_CALENDAR_EVENT_DETAIL']))),
	]),
	[sub {
	    my($req) = @_;
 	    my($v) = _globals($req);
	    $v->{current} = $_D->add_days($v->{current}, 1);
	    return '';
	}],
    ]);
}

sub _globals {
    my($req) = shift->req;
    if (my $values = shift) {
	$req->put(__PACKAGE__, $values);
    }
    return $req->get(__PACKAGE__);
}

sub _heading_cell {
    return String([
	sub {
	    my($source) = @_;
	    my($v) = _globals($source);
	    my($str) = $_D->english_day_of_week($v->{current});
	    $v->{current} = $_D->add_days($v->{current}, 1);
	    return $str;
	}
    ])->put(cell_class => 'day_of_week');
}


sub _is_same_month {
    my($date, $date2) = @_;
    return $_D->get_parts($date, 'month') == $_D->get_parts($date2, 'month')
        ? 1 : 0;
}

1;
