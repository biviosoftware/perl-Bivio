# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Delegate::UniversalTimeZone;
use strict;
use base 'Bivio::Delegate';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_delegate_info {
    return [
	UNKNOWN => [0, "Unknown (UTC default)"],
    ];
}

sub convert_datetime {
    my($proto, $date_time, $time_zone_in, $time_zone_out) = @_;
    # Does nothing by default since we don't know what type of time zone
    # handling is in place. This method should be overridden if subclass adds
    # other time zones besides implicit UTC.
    return $date_time;
}

1;
