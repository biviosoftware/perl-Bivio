# Copyright (c) 2008 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::DateYearMonth;
use strict;
use Bivio::Base 'Type.Date';


sub FROM_SQL_FORMAT {
    return 'YYYYMM';
}

sub from_sql_column {
    my($proto, $value) = @_;
    return undef
        unless defined($value);
    my($y, $m) = $value =~ /^(\d{4})(\d{2})$/;
    b_die($value, ': illegal database format')
        unless defined($y);
    return $proto->date_from_parts(1, $m, $y);
}

sub to_order_by_value {
    return shift->from_sql_value(@_);
}

1;
