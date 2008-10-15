# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::YearWindow;
use strict;
use Bivio::Base 'Bivio::Type::Enum';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = __PACKAGE__->use('Type.Date');
my($_NOW) = $_D->get_part($_D->now, 'year');

# 10 year window from current year forward, ex. (Y2004 => [2004, 2004])
__PACKAGE__->compile([
    UNKNOWN => [0],
    map({
	("Y$_" => [$_, $_]),
    } ($_NOW .. $_NOW + 9)),
]);

sub is_continuous {
    return 0;
}

1;
