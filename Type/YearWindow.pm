# Copyright (c) 2008-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::YearWindow;
use strict;
use Bivio::Base 'Type.Enum';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
__PACKAGE__->compile(0, 9);

sub compile {
    my($proto) = shift;
    my($now) = b_use('Type.DateTime')->now_as_year;
    my($start, $end) = map($_ < 100 ? $now + $_ : $_, @_);
    return $proto->SUPER::compile([
	map(("Y$_" => [$_, $_]), $start .. $end),
    ]);
}

1;
