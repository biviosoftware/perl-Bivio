# $Id$
use Bivio::Test;
use Bivio::Test::HTMLParser;
use Bivio::IO::File;
Bivio::Test->unit([
    map {(
        Bivio::Test::HTMLParser->new(
	    Bivio::IO::File->read("HTMLParser/$_->[0].html")) => [
		get_nested => $_->[1]
	    ],
    )} [
	login => [
	    ['Links', 'Please Register.', 'href'] => ['/pub/register'],
	    ['Links', 'help_off', 'href'] => ['/hp/index.html'],
	    ['Forms', 'User ID or Email:', 'visible',
		'User ID or Email:', 'type'] => ['text'],
	    ['Forms', 'User ID or Email:', 'visible',
		'Password:', 'type'] => ['password'],
	    ['Forms', 'User ID or Email:', 'visible',
		'Save Password', 'type'] => ['checkbox'],
	],
     ], [
	 petshop => [
	     ['Forms', 'search', 'submit', 'search', 'type'] => ['submit'],
	     ['Forms', 'search', 'visible', '_anon', 'type'] => ['text'],
	 ],
     ], [
	 'petshop-login' => [
	     ['Forms', 'search', 'submit', 'search', 'type'] => ['submit'],
	     ['Forms', 'search', 'visible', '_anon', 'type'] => ['text'],
	     ['Links', 'Cart', 'href'] => ['/my/cart'],
	     ['Links', 'bivio_power', 'href'] => ['http://www.bivio.biz'],
	     ['Forms', 'User ID:', 'visible',
		 'User ID:', 'type'] => ['text'],
	     ['Forms', 'User ID:', 'visible',
		 'Password:', 'type'] => ['password'],
	 ],
     ], [
	 'petshop-corgi' => [
	     ['Forms', 'add_to_cart_0', 'submit',
		 'add_to_cart_0', 'name'] => ['f2_0'],
	 ],
     ], [
	 'petshop-cart' => [
	     ['Forms', 'remove_0', 'visible', 'Quantity_0',
		 'value'] => ['1'],
	 ],
     ],
]);

