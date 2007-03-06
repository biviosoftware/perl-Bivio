# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::RealmMotionMode;
use strict;
use base 'Bivio::Type::Enum';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

__PACKAGE__->compile([
    UNKNOWN => [0, "Select Option"],
    DEFAULT => [1, "Disabled"],
    CLOSED_RESULTS_MOTION => [2, "Enabled, Closed Results"],
    OPEN_RESULTS_MOTION => [3, "Enabled, Members Can View Results"],
]);

sub OPTIONAL_MODES {
    return qw(closed_results_motion open_results_motion);
}

1;
