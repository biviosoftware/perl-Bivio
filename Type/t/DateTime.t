use strict;
use Bivio::Test;
use Bivio::Type::DateTime;
use Bivio::Type::Date;
use Bivio::Type::Time;
use Bivio::Agent::Request;

# Set the timezone to something specific
Bivio::Agent::Request->get_current_or_new->put(timezone => 120);

# Tests
Bivio::Test->unit([
    'Bivio::Type::DateTime' => [
	from_literal => [
	    [undef] => [undef],
	    ['2378497 9'] => ['2378497 9', undef],
	    ['-9'] => [undef, Bivio::TypeError::DATE_TIME()],
	    ['Feb 29 0:0:0 MST 1972'] => ['2441377 0', undef],
	    ['Feb 29 13:13:13 XXX 2000'] => ['2451604 47593', undef],
	    ['1972/2/29 0:0:0'] => ['2441377 0', undef],
	    ['2000/2/29 13:13:13'] => ['2451604 47593', undef],
	],
	from_local_literal => [
	    [undef] => [undef, undef],
	    ['2378497 9'] => ['2378497 25209', undef],
	    ['-9'] => [undef, Bivio::TypeError::DATE_TIME()],
	    ['Feb 29 0:0:0 MST 1972'] => ['2441377 25200', undef],
	    ['Feb 29 13:13:13 XXX 2000'] => ['2451604 72793', undef],
	    ['1972/2/29 0:0:0'] => ['2441377 25200', undef],
	    ['2000/2/29 13:13:13'] => ['2451604 72793', undef],
	],
	to_string => [
	    ['2378497 9'] => ['01/01/1800 00:00:09 GMT'],
	    ['2441377 0'] => ['02/29/1972 00:00:00 GMT'],
	    ['2451604 47593'] => ['02/29/2000 13:13:13 GMT'],
	],
#	to_local_string => [
#	    ['2378497 7209'] => ['01/01/1800 02:00:09'],
#	    ['2441377 7200'] => ['02/29/1972 02:00:00'],
#	    ['2451604 54793'] => ['02/29/2000 13:13:13'],
#	],
	to_parts => [
	    [Bivio::Type::DateTime->get_min]
	    	=> ['0', '0', '0', '1', '1', '1800'],
	    [Bivio::Type::DateTime->get_max]
	    	=> ['59', '59', '23', '31', '12', '2199'],
	    ['2440588 0'] => ['0', '0', '0', '1', '1', '1970'],
	    ['2441377 0'] => ['0', '0', '0', '29', '2', '1972'],
	    ['2451604 47593'] => ['13', '13', '13', '29', '2', '2000'],
	],
	add_days => [
	    ['2440588 0', 1] => ['2440589 0'],
	    ['2440588 0', -1] => ['2440587 0'],
	],
	add_seconds => [
	    ['2440588 0', 1] => ['2440588 1'],
	    ['2440588 0', 86401] => ['2440589 1'],
	    ['2440588 0', -86401] => ['2440586 86399'],
	    ['2440588 0', -1] => ['2440587 86399'],
	],
    ],
    'Bivio::Type::Date' => [
	{
	    method => 'from_literal',
	    result_ok => sub {
		my($proto, $method, $params, $expect, $actual) = @_;
		return $actual
		    eq $expect.' '.Bivio::Type::DateTime->DEFAULT_TIME;
	    },
	} => [
	    ['1/1/1800'] => [2378497],
#	    ['1/1/1800'] => [make_date(2378497)],
	    ['1/1/1850'] => ['2396759 79199'],
#	    ['1/1/1850'] => [make_date(2396759)],
	    ['1/2/1800'] => ['2378498 79199'],
#	    ['1/2/1800'] => [make_date(2378498)],
	    ['1/1/1900'] => ['2415021 79199'],
#	    ['1/1/1900'] => [make_date(2415021)],
#	    ['1/1/1970'] => [make_date(
#		Bivio::Type::DateTime::UNIX_EPOCH_IN_JULIAN_DAYS())],
	    ['1/1/2000'] => ['2451545 79199'],
#	    ['1/1/2000'] => [make_date(2451545)],
	    ['1/1/2100'] => ['2488070 79199'],
#	    ['1/1/2100'] => [make_date(2488070)],
	    ['12/31/2199'] => ['2524593 79199'],
#	    ['12/31/2199'] => [make_date(2524593)],
	],
	from_literal => [
	    [undef] => [undef],
	    ['1/1/1970 x'] => [undef, Bivio::TypeError::DATE_TIME()],
	],
    ],
]);

