use strict;
my($_LOG) = 'HTTPLog.tmp';
use Bivio::IO::Config;
Bivio::IO::Config->introduce_values({
    'Bivio::Util::HTTPLog' => {
	email => '',
	pager_email => '',
	interval_minutes => 5,
	error_list => [
	    'this is an error',
	],
	error_count_for_page => 2,
	critical_list => [
	    'this is critical',
	],
	ignore_list => [
	    'this is normal',
	],
	error_file => $_LOG,
    },
    'Bivio::IO::Alert' => {
	want_time => 1,
    },
});

our($_PREFIX) = '2003/03/22 06:2';
use Bivio::Type::DateTime;
package Bivio::Type::DateTime;
undef(&now);
*now = sub {
    return Bivio::Type::DateTime->from_literal("${main::_PREFIX}9:00");
};
undef(&from_local_literal);
*from_local_literal = sub {
    return shift->from_literal(@_);
};
package main;
use Bivio::Test;
Bivio::Test->new('Bivio::Util::HTTPLog')->unit([
    [] => [
	{
	    compute_params => sub {
		my($case, $params) = @_;
		Bivio::IO::File->write($_LOG,
		    join('', map("$_PREFIX$_\n", @$params)));
		return [5];
	    },
	    check_return => sub {
		my($case, $actual, $expect) = @_;
		return ref($expect) eq 'ARRAY'
		    ? @$expect ? [map({\("$_PREFIX$_\n")} @$expect)] : [\('')]
	            : $expect;
	    },
	    method => 'parse_errors'
	} => [
	    # Inside interval
	    '4:02 this is an error' => '4:02 this is an error',
	    '4:50 this is normal' => [],
	    '4:51 this is critical' => qr/CRITICAL.*this is critical/,
	    # Repeated
	    [map("4:2$_ this is an error", 1..2)] => qr/CRITICAL/,
	    # Unknown
	    '4:55 Unknown' => '4:55 Unknown',
	    '4:55 normal' => '4:55 normal',
	    # Outside interval
	    '1:22 this is an error' => [],
	],
    ],
]);
