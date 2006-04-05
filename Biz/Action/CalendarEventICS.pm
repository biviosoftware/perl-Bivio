# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::CalendarEventICS;
use strict;
use base 'Bivio::Biz::Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = Bivio::Type->get_instance('DateTime');
my($_D) = Bivio::Type->get_instance('Date');

sub execute {
    my($proto, $req) = @_;
    $req->get('reply')->set_output_type('text/calendar')
	->set_output($proto->render($req));
    return;
}

#TODO: Copy modified from CalendarEventDAVList.pm
sub render {
    my($proto, $req) = @_;
    my($it) = $req->get('Model.CalendarEventList');
    Bivio::IO::Alert->info($it->get('CalendarEvent.calendar_event_id'));
    return \(join(
	"\r\n",
	'BEGIN:VCALENDAR',
	'VERSION:2.0',
	'PRODID:-//Mozilla.org/NONSGML Mozilla Calendar V1.0//EN',
	'BEGIN:VEVENT',
	map({
	    my($k, $f) = ref($_) ? @$_ : (uc($_), "CalendarEvent.$_");
	    my($t) = $it->get_field_type($f);
	    $t->isa('Bivio::Type::DateTime') ? _dt($it, $k, $f)
		: "$k:" . $it->get_as($f, 'to_literal');
	}
	    [qw(CREATED RealmOwner.creation_date_time)],
	    [qw(LAST-MODIFIED CalendarEvent.modified_date_time)],
	    [qw(DTSTAMP CalendarEvent.modified_date_time)],
	    [qw(UID uid)],
	    [qw(SUMMARY RealmOwner.display_name)],
	    qw(dtstart dtend location url description),
	),
#TODO: CLASS private or public
	'CLASS:PRIVATE',
	'PRIORITY:0',
	'STATUS:',
	'X-LIC-ERROR:No value for STATUS property. Removing entire property:',
	'END:VEVENT',
	'END:VCALENDAR',
	'',
    ));
}

#TODO: Copied verbatim from CalendarEventDAVList.pm
sub _dt {
    my($it, $key, $field) = @_;
    my($v) = $it->get($field);
    unless ($key =~ /DTSTART|DTEND/) {
	$v = $_DT->to_file_name($v) . 'Z';
	substr($v, 8, 0) = 'T';
    }
    elsif ($_DT->is_date($v)) {
	$key .= ";VALUE=DATE";
	$v = $_D->to_file_name($v);
    }
    else {
#TODO: timezone
	$v = $_DT->to_local_file_name($v, 0);
	substr($v, 8, 0) = 'T';
    }
    return "$key:$v";
}

1;
