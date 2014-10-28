# Copyright (c) 2005-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::CalendarEventICS;
use strict;
use Bivio::Base 'Biz.Action';


sub execute {
    my($proto, $req) = @_;
    $req->get('reply')
	->set_output_type('text/calendar')
	->set_output(
	    b_use('Model.CalendarEventDAVList')->new($req)
	    ->vcalendar_list($req->get('Model.CalendarEventList')),
	);
    return;
}

1;
