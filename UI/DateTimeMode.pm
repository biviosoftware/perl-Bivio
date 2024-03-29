# Copyright (c) 1999-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::DateTimeMode;
use strict;
use Bivio::Base 'Type.Enum';

__PACKAGE__->compile([
    # DO NOT CHANGE THESE NUMBERS
    # unless you modify UI::HTML::Widget::DateTime
    DATE => 1,
    TIME => 2,
    DATE_TIME => 3,
    MONTH_NAME_AND_DAY_NUMBER => 4,
    MONTH_AND_DAY => 5,
    FULL_MONTH_DAY_AND_YEAR_UC => 6,
    FULL_MONTH_AND_YEAR_UC => 7,
    FULL_MONTH => 8,
    DAY_MONTH3_YEAR => 9,
    DAY_MONTH3_YEAR_TIME => 10,
    RFC822 => 11,
    DAY_MONTH3_YEAR_TIME_PERIOD => 12,
    FULL_MONTH_DAY_AND_YEAR => 13,
    HOUR_MINUTE_AM_PM_LC => 14,
]);
Bivio::IO::Config->register(my $_CFG = {
    default => __PACKAGE__->DATE_TIME,
    date_default => __PACKAGE__->DATE,
    widget_default => Bivio::IO::Config->if_version(
        4 => sub {__PACKAGE__->DATE_TIME},
        sub {__PACKAGE__->DATE},
    ),
});

sub get_default {
    return $_CFG->{default};
}

sub get_date_default {
    return $_CFG->{date_default};
}

sub get_widget_default {
    return $_CFG->{widget_default};
}

sub handle_config {
    my($proto, $cfg) = @_;
    foreach my $x (qw(default date_default widget_default)) {
        $_CFG->{$x} = $proto->from_any($cfg->{$x});
    }
    return;
}

1;
