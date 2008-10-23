# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::YearWindow;
use strict;
use Bivio::Base 'Type.Enum';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = __PACKAGE__->use('Type.Date');
my($_NOW) = $_D->get_part($_D->now, 'year');

# 10 year window from current year forward, ex. (Y2004 => [2004, 2004])
__PACKAGE__->compile(__PACKAGE__->year_range_config(0, 9));

sub year_range_config {
    my($proto, $start, $end) = @_;
    return [
	map({
	    ("Y$_" => [$_, $_]),
	} ($_NOW + $start .. $_NOW + $end)),
    ];
}

1;
