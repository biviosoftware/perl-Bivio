# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::FullCalendarList;
use strict;
use Bivio::Base 'Model.CalendarEventList';
b_use('IO.ClassLoaderAUTOLOAD');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
# Supports fullcalendar.js

sub as_json_ref {
    my($self) = @_;
    return [
	{
	    title => 'Day30',
	    start => '2014-01-30T20:00:00Z',
	    end => '2014-01-30T22:00:00Z',
	},
    ];
}

sub execute_load_all {
    my($proto, $req) = @_;
    $proto->new($req)->put_on_req($req);
    return;
}

# sub internal_prepare_statement {
#     my($self) = @_;
#     my($self, $stmt, $query) = @_;
#     my($bom) = _query($self, 'b_month');
#     $self->new_other('MonthList')->load_all({b_month => $bom});
#     my($begin) = $_DT->set_beginning_of_week($bom);
#     my($end) = $_DT->set_end_of_week(
# 	$_DT->set_end_of_day($_DT->set_end_of_month($bom)));
#     _if_tz($self, sub {
#         my($tz) = @_;
# 	$begin = $tz->date_time_to_utc($begin);
# 	$end = $tz->date_time_to_utc($end);
# 	return;
#     });
#     $self->[$_IDI] = [$begin, $end];
#     $stmt->where(
# 	$stmt->OR(
# 	    map($stmt->AND(
# 		$stmt->GTE("CalendarEvent.$_", [$begin]),
# 		$stmt->LTE("CalendarEvent.$_", [$end]),
# 	    ), qw(dtstart dtend)),
# 	),
#     );
#     return shift->SUPER::internal_prepare_statement(@_);
# }

1;
