# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
foreach my $r (qw(fourem fourem-sub2 fourem-sub1)) {
    model('CalendarEvent')->test_unauth_delete_all({realm_id => realm_id($r)});
}
my($create) = sub {
    my($realm, $date) = @_;
    req()->set_realm_and_user($realm)
	->initialize_fully('FORUM_CALENDAR_EVENT_FORM');
    my($tag) = random_string();
    model(CalendarEventForm => {
	'RealmOwner.display_name' => "DN $tag",
	'CalendarEvent.location' => "L $tag",
	time_zone => 'UTC',
	start_date => Date($date),
	start_time => Time('9:00'),
	end_date => Date($date),
	end_time => Time('10:00'),
	recurrence => CalendarEventRecurrence('UNKNOWN'),
    });
    return req('Model.CalendarEvent');
};
my($event);
my($create_list) = sub {
    my($list) = {};
    foreach my $date (map(Date($_), qw(7/15/2008 7/16/2008))) {
	 $list->{$date} = $create->(fourem => $date)->get('location');
	 $date = Date()->add_days($date, 30);
	 $list->{$date} = $create->('fourem-sub2' => $date)->get('location');
	 $date = Date()->add_days($date, 30);
	 $list->{$date} = $create->('fourem-sub1' => $date)->get('location');
    }
    return $event = $list;
};
my($rows) = sub {
    my($dates, $op) = @_;
    return map(
	$op ? $op->($event->{$_}) : +{'CalendarEvent.location' => $event->{$_}},
	reverse(sort(
	    {Date()->compare($a, $b)}
	    grep(Date()->to_string($_) =~ $dates, keys(%$event)))),
    );
};
($create_list, $rows);

