# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::TimeZone;
use strict;
use base 'Bivio::Type::EnumDelegator';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

__PACKAGE__->compile;

# Delegates of this type must define this method, since EnumDelegator's
# AUTOLOAD implementation does not allow this subclass to define it.
#
# sub convert_datetime {
#     my($proto, $date_time, $time_zone_in, $time_zone_out) = @_;
#     return $converted_date_time;
# }

1;
