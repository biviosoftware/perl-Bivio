use strict;
use Bivio::Test;
use Bivio::Type::DateTime;
use Bivio::Type::Date;
use Bivio::Type::Time;
use Bivio::Agent::Request;

my($_D) = 'Bivio::Type::Date';

# Set the timezone to something specific
Bivio::Agent::Request->get_current_or_new->put(timezone => 120);

# Tests
Bivio::Test->unit([
    'Bivio::Type::Date' => [
	from_literal => [
	    ['1/1/1850'] => ['2396759 79199'],
	    ['1/2/1800'] => ['2378498 79199'],
	    ['1/1/1900'] => ['2415021 79199'],
	    ['1/1/2000'] => ['2451545 79199'],
	    ['1/1/2100'] => ['2488070 79199'],
	    ['12/31/2199'] => ['2524593 79199'],
	    [undef] => [undef],
	    ['1/1/1970 x'] => [undef, Bivio::TypeError::DATE()],
	],
    ],
]);
