# $Id$
use Bivio::Test;
use Bivio::Collection::Attributes;
Bivio::Test->unit([
    Bivio::Collection::Attributes->new({
	a => '1',
	b => ['A', 'B'],
	c => {A => 1, B => 2},
	d => Bivio::Collection::Attributes->new({a => 99}),
    }) => [
	get_nested => [
	    ['a'] => ['1'],
	    ['b', 1] => ['B'],
	    ['c', 'B'] => [2],
	    ['d', 'a'] => [99],
	],
    ],
]);

