#!perl -w
# $Id$
#
use strict;
use Bivio::Test;
use Bivio::Type::DateInterval;
use Bivio::Type::Date;
my($_D) = 'Bivio::Type::Date';
Bivio::Test->new({
    compute_params => sub {
	my($object, $method, $params) = @_;
	$params->[0] = Bivio::Type::Date->from_literal_or_die(
	    $params->[0]);
	return $params;
    },
    result_ok => sub {
	my($object, $method, $params, $expected, $actual) = @_;
	return Bivio::Test->default_result_ok(@_)
	    if ref($expected) eq 'Bivio::DieCode';
	return $_D->from_literal_or_die($expected->[0]) eq $actual->[0];
    }
})->unit([
    Bivio::Type::DateInterval->NONE => [
	inc => [
	    ['1/1/1911'] => ['1/1/1911'],
	    ['3/3/2000'] => ['3/3/2000'],
	],
	dec => [
	    ['1/1/1911'] => ['1/1/1911'],
	    ['3/3/2000'] => ['3/3/2000'],
	],
    ],
    Bivio::Type::DateInterval->DAY => [
	inc => [
	    ['1/1/1911'] => ['1/2/1911'],
	    ['1/31/2000'] => ['2/1/2000'],
	    [$_D->get_max] => Bivio::DieCode->DIE,
	],
	dec => [
	    ['1/1/1911'] => ['12/31/1910'],
	    ['1/31/2000'] => ['1/30/2000'],
	    [$_D->get_min] => Bivio::DieCode->DIE,
	],
    ],
    Bivio::Type::DateInterval->WEEK => [
	inc => [
	    ['1/1/1911'] => ['1/8/1911'],
	    ['12/31/2000'] => ['1/7/2001'],
	    [$_D->get_max] => Bivio::DieCode->DIE,
	],
	dec => [
	    ['1/1/1911'] => ['12/25/1910'],
	    ['3/3/2000'] => ['2/25/2000'],
	    [$_D->get_min] => Bivio::DieCode->DIE,
	],
    ],
    Bivio::Type::DateInterval->BEGINNING_OF_YEAR => [
	inc => [
	    ['5/5/1999'] => ['1/1/2000'],
	    ['1/1/1911'] => ['1/1/1912'],
	    [$_D->get_max] => Bivio::DieCode->DIE,
	],
	dec => [
	    ['5/5/1999'] => ['1/1/1999'],
	    ['1/1/1911'] => ['1/1/1911'],
	    [$_D->get_min] => Bivio::DieCode->DIE,
        ],
    ],
    Bivio::Type::DateInterval->MONTH => [
	inc => [
	    ['1/1/1911'] => ['2/1/1911'],
	    ['1/31/2000'] => ['2/29/2000'],
	    [$_D->get_max] => Bivio::DieCode->DIE,
	],
	dec => [
	    ['1/1/1911'] => ['12/1/1910'],
	    ['2/29/2000'] => ['1/29/2000'],
	    ['7/31/2000'] => ['6/30/2000'],
	    [$_D->get_min] => Bivio::DieCode->DIE,
	],
    ],
    Bivio::Type::DateInterval->YEAR => [
	inc => [
	    ['1/1/1911'] => ['1/1/1912'],
	    ['2/29/2000'] => ['2/28/2001'],
	    [$_D->get_max] => Bivio::DieCode->DIE,
	],
	dec => [
	    ['1/1/1911'] => ['1/1/1910'],
	    ['2/29/2000'] => ['2/28/1999'],
	    [$_D->get_min] => Bivio::DieCode->DIE,
	    [$_D->get_max] => ['12/31/2198'],
	],
    ],
    Bivio::Type::DateInterval->FISCAL_YEAR => [
	inc => [
	    ['3/3/1911'] => ['1/1/1912'],
	    ['1/1/1999'] => ['1/1/2000'],
	    [$_D->get_max] => Bivio::DieCode->DIE,
	],
	dec => [
	    ['3/3/1911'] => ['1/1/1911'],
	    ['1/1/1999'] => ['1/1/1999'],
	    [$_D->get_min] => Bivio::DieCode->DIE,
	],
    ],
]);
