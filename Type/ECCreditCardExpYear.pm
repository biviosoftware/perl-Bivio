# Copyright (c) 2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::ECCreditCardExpYear;
use strict;
use Bivio::Base 'Type.Enum';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

#TODO: remove this class - use YearWindow instead
my($_D) = __PACKAGE__->use('Type.Date');
my($_NOW) = $_D->get_part($_D->now, 'year');

# 10 year window from current year forward, ex. (Y2004 => [2004, 2004])
__PACKAGE__->compile([
    map({
	("Y$_" => [$_, $_]),
    } ($_NOW .. $_NOW + 9)),
]);

1;
