# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
foreach my $r (qw(fourem fourem-sub2 fourem-sub1)) {
    model('CalendarEvent')->test_unauth_delete_all({realm_id => realm_id($r)});
}
my($create) = sub {
    my($realm, $start, $end, $recurrence, $recurrence_end_date) = @_;
    req()->set_realm_and_user($realm)
        ->initialize_fully('FORUM_CALENDAR_EVENT_FORM');
    $end ||= $start;
    $recurrence ||= 'UNKNOWN';
    my($tag) = random_string();
    model(CalendarEventForm => {
        'RealmOwner.display_name' => "DN ' $tag",
        'CalendarEvent.location' => "L $tag",
        time_zone_selector => 'UTC',
        start_date => Date($start),
        start_time => Time('9:00'),
        end_date => Date($end),
        end_time => Time('10:00'),
        recurrence => CalendarEventRecurrence($recurrence),
        recurrence_end_date => $recurrence_end_date && Date($recurrence_end_date),
    });
    return req('Model.CalendarEvent');
};
my($event) = {};
my($create_list) = sub {
    my(@dates) = @_;
    foreach my $date (map(Date($_), @dates ? @dates : qw(7/15/2008 7/16/2008))) {
         $event->{$date} = $create->(fourem => $date)->get('location');
         $date = Date()->add_days($date, 30);
         $event->{$date} = $create->('fourem-sub2' => $date)->get('location');
         $date = Date()->add_days($date, 30);
         $event->{$date} = $create->('fourem-sub1' => $date)->get('location');
    }
    return $event;
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
($create_list, $rows, $create);

