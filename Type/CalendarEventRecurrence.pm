# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::CalendarEventRecurrence;
use strict;
use Bivio::Base 'Type.Enum';

my($_DT) = b_use('Type.DateTime');
my($_TOO_SHORT) = b_use('Bivio.TypeError')->TOO_SHORT;
my($_TOO_LONG) = b_use('Bivio.TypeError')->TOO_LONG;
my($_NULL) = b_use('Bivio.TypeError')->NULL;
my($_EXISTS) = b_use('Bivio.TypeError')->EXISTS;
__PACKAGE__->compile([
    UNKNOWN => [0, 'None'],
    EVERY_WEEK => 1,
    EVERY_TWO_WEEKS => 2,
    EVERY_FOUR_WEEKS => 4,
]);

sub is_continuous {
    return 0;
}

sub period_in_days {
    return shift->as_int * 7;
}

sub validate_end_date {
    my($self, $end_date, $recurrence_end_date) = @_;
    if ($self->eq_unknown) {
	return $_EXISTS
	    if $recurrence_end_date;
	return undef;
    }
    return $_NULL
	unless $recurrence_end_date;
    my($dd) = $_DT->delta_days($end_date, $recurrence_end_date);
    return $dd < 7 ? $_TOO_SHORT
#TODO: Need to have better algorithm for inputting recurrences
	: $dd >= 800 ? $_TOO_LONG
	: undef,
}

1;
