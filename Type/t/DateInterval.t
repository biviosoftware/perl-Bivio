#!perl -w
# $Id$
#
use strict;
use Bivio::Test;
use Bivio::Type::DateInterval;
use Bivio::Type::Date;
my($_D) = 'Bivio::Type::Date';
my($_DI) = 'Bivio::Type::DateInterval';
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
    $_DI->NONE => [
	inc => [
	    ['1/1/1911'] => ['1/1/1911'],
#TODO: This is the current behavior.  It probably shouldn't die.
	    [$_D->get_max] => Bivio::DieCode->DIE,
	],
	dec => [
	    ['1/1/1911'] => ['1/1/1911'],
	    [$_D->get_min] => [$_D->get_min],
	],
	inc_to_end => [
	    ['1/1/1911'] => ['1/1/1911'],
	    [$_D->get_min] => [$_D->get_min],
	],
    ],
    $_DI->DAY => [
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
	inc_to_end => [
	    ['1/1/1911'] => ['1/1/1911'],
	    [$_D->get_min] => [$_D->get_min],
	    [$_D->get_max] => [$_D->get_max],
	],
    ],
    $_DI->WEEK => [
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
	inc_to_end => [
	    ['1/1/1911'] => ['1/7/1911'],
	    ['12/31/2000'] => ['1/6/2001'],
	],
    ],
    $_DI->BEGINNING_OF_YEAR => [
	inc => [
	    ['5/5/1999'] => ['1/1/2000'],
	    ['1/1/1911'] => ['1/1/1912'],
	    [$_D->get_max] => Bivio::DieCode->DIE,
	],
	dec => [
	    ['5/5/1999'] => ['1/1/1999'],
	    ['1/1/1911'] => ['1/1/1911'],
	    [$_D->get_min] => [$_D->get_min],
        ],
    ],
    $_DI->MONTH => [
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
	inc_to_end => [
	    ['1/1/1911'] => ['1/31/1911'],
	    ['2/29/2000'] => ['3/28/2000'],
	],
    ],
    $_DI->YEAR => [
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
	inc_to_end => [
	    ['1/1/1911'] => ['12/31/1911'],
	    ['2/29/2000'] => ['2/27/2001'],
	    [$_D->get_max] => Bivio::DieCode->DIE,
	],
    ],
    $_DI->FISCAL_YEAR => [
	inc => [
	    ['3/3/1911'] => ['1/1/1912'],
	    ['1/1/1999'] => ['1/1/2000'],
	    [$_D->get_max] => Bivio::DieCode->DIE,
	],
	dec => [
	    ['3/3/1911'] => ['1/1/1911'],
	    ['1/1/1999'] => ['1/1/1998'],
	    [$_D->get_min] => Bivio::DieCode->DIE,
	],
	inc_to_end => [
	    ['3/3/1911'] => ['12/31/1911'],
	    ['1/1/1999'] => ['12/31/1999'],
	    ['12/31/1999'] => ['12/31/1999'],
	    [$_D->get_max] => Bivio::DieCode->DIE,
	],
    ],
    $_DI->IRS_TAX_SEASON => [
	inc => [
	    ['3/3/1911'] => ['1/1/1912'],
	    ['1/1/1999'] => ['1/1/2000'],
	    [$_D->get_max] => Bivio::DieCode->DIE,
	],
	dec => [
	    ['3/3/1911'] => Bivio::DieCode->DIE,
	    ['1/1/1999'] => Bivio::DieCode->DIE,
	    [$_D->get_min] => Bivio::DieCode->DIE,
	],
	inc_to_end => [
	    ['3/3/1911'] => ['4/15/1911'],
	    ['1/1/1999'] => ['4/15/1999'],
	    ['12/31/1999'] => ['4/15/2000'],
	    ['4/15/1999'] => ['4/15/1999'],
	    ['4/16/1999'] => ['4/15/2000'],
	    [$_D->get_max] => Bivio::DieCode->DIE,
	],
    ],
]);
