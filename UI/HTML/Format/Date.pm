# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Format::Date;
use strict;
use Bivio::Base 'UIHTML.Format';

my($_DT) = b_use('Type.DateTime');

sub get_widget_value {
    # Formats a date time value as a string with the
    # specified 2 or 4 digit year.
    my(undef, $time, $year_digits) = @_;
    return '' unless defined($time);
    b_die('invalid year_digits ', $year_digits)
	if defined($year_digits) && $year_digits != 2 && $year_digits != 4;
    $year_digits ||= 4;
    my($sec, $min, $hour, $mday, $mon, $year) = $_DT->to_parts($time);
    return $year_digits == 2
	? sprintf('%02d/%02d/%02d', $mon, $mday, $year =~ /(\d\d)$/)
	: sprintf('%02d/%02d/%04d', $mon, $mday, $year);
}

1;
