# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CalendarEventDAVList;
use strict;
use base 'Bivio::Biz::Model::AnyTaskDAVList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = Bivio::Type->get_instance('DateTime');
my($_D) = Bivio::Type->get_instance('Date');

sub dav_is_read_only {
    return 0;
}

sub dav_put {
    my($self, $content) = @_;
    $self->get_request->set_realm($self->get_auth_id);
    $self->new_other('CalendarEventList')->update_from_ics($content);
    return;
}

sub dav_reply_get {
    my($self) = @_;
    $self->get_request->get('reply')
	->set_output_type('text/calendar')->set_output(\(join(
	"\r\n",
	'BEGIN:VCALENDAR',
	'VERSION:2.0',
	'PRODID:-//Mozilla.org/NONSGML Mozilla Calendar V1.0//EN',
	'METHOD:PUBLISH',
	@{$self->new_other('CalendarEventList')->map_iterate(sub {
            my($it) = @_;
	    return (
		'BEGIN:VEVENT',
		map({
		    my($k, $f) = ref($_) ? @$_ : (uc($_), "CalendarEvent.$_");
		    my($t) = $it->get_field_type($f);
		    $t->isa('Bivio::Type::DateTime') ? _dt($it, $k, $f) : "$k:"
			. Bivio::HTML->escape($it->get_as($f, 'to_literal'));
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
	    );
	},
	    'unauth_iterate_start',
	     {auth_id => $self->get_auth_id},
        )},
	'END:VCALENDAR',
	'',
    )));
    return 1;
}

sub _dt {
    my($it, $key, $field) = @_;
    my($v) = $it->get($field);
#     unless ($key =~ /DTSTART|DTEND/) {
# 	$v = $_DT->to_file_name($v) . 'Z';
# 	substr($v, 8, 0) = 'T';
#     }
#     elsif ($_DT->is_date($v)) {
    if ($_DT->is_date($v)) {
	$key .= ";VALUE=DATE";
	$v = $_D->to_file_name($v);
    }
    else {
#TODO: timezone
#	$v = $_DT->to_local_file_name($v, 0);
 	$v = $_DT->to_file_name($v) . 'Z';
	substr($v, 8, 0) = 'T';
    }
    return "$key:$v";
}

1;
