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
	return $_D->from_literal_or_die($expected->[0]) eq $actual->[0];
    }
})->unit([
    Bivio::Type::DateInterval->MONTH => [
	inc => [
	    ['1/1/1911'] => ['2/1/1911'],
	    ['1/31/2000'] => ['2/29/2000'],
	],
	dec => [
	    ['1/1/1911'] => ['12/1/1910'],
	    ['2/29/2000'] => ['1/29/2000'],
	    ['7/31/2000'] => ['6/30/2000'],
	],
    ],
    Bivio::Type::DateInterval->YEAR => [
	inc => [
	    ['1/1/1911'] => ['1/1/1912'],
	    ['2/29/2000'] => ['2/28/2001'],
	],
	dec => [
	    ['1/1/1911'] => ['1/1/1910'],
	    ['2/29/2000'] => ['2/28/1999'],
	],
    ],
]);
