#!perl -w
# $Id$
#
use strict;
use Bivio::Test;
use Bivio::TypeError;
Bivio::Test->new('Bivio::Type::Country')->unit([
    'Bivio::Type::Country' => [
	get_width => 2,
	from_literal => [
	    us => 'US',
	    [undef] => [undef, undef],
	    u => [undef, Bivio::TypeError->COUNTRY],
	    usa => [undef, Bivio::TypeError->TOO_LONG],
	],
    ],
]);
