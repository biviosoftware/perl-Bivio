# $Id$
use Bivio::Test;
use Bivio::IO::File;
my($_NEW) = 
Bivio::Test->new({
    class_name => 'Bivio::Test::HTMLParser',
    create_object => sub {
	my($case, $params) = @_;
	my($o) = Bivio::Test::HTMLParser->new(
	    Bivio::IO::File->read("HTMLParser/$params->[0].html"));
	return $params->[1] ? $o->get($params->[1]) : $o;
    },
})->unit([
    map({
	$_->[0] => [
	    get_nested => $_->[1],
        ];
    } [
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
	'petshop-account-created' => [
	    ['Links', 'MyAccount', 'href'] => ['/test_http_28027/account'],
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
	'petshop-login-error' => [
	    ['Forms', 'User ID:', 'visible',
		 'User ID:', 'error'] => ['not found'],
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
	    ['Tables', 0, 'headings', 0] => ['Remove'],
	    ['Tables', 0, 'rows', 0, 1] => ['EST-6'],
	    ['Tables', 0, 'rows', 0, 2] => ['Male Adult Corgi'],
	    ['Tables', 0, 'rows', 0, 5] => ['1'],
	    ['Tables', 0, 'rows', 1, 1] => ['Total:'],
	    ['Tables', 0, 'rows', 1, 6] => ['18.50'],
	],
    ], [
	'petshop-checkout' => [
	    ['Tables', 0, 'headings', 2] => ['In Stock'],
	    ['Tables', 0, 'rows', 0, 2] => ['yes'],
	],
    ], [
	'petshop-cart-error' => [
	    ['Forms', 'remove_0', 'visible', 'Quantity_0',
		 'error'] => ['expecting a number without a decimal point'],
	],
    ], [
	'petshop-register' => [
	    ['Forms', 'User ID:', 'visible', 'Country:', 'name'] => ['f10'],
	    ['Forms', 'User ID:', 'visible', '_anon', 'name'] => ['f6'],
	    ['Forms', 'User ID:', 'visible', 'Postal Code:', 'name'] => ['f9'],
	    ['Forms', 'User ID:', 'visible', 'State/Province:', 'name']
	        => ['f8'],
	],

    ]),
    ['login', 'Forms'] => [
	get_by_field_names => [
	    ['User ID or Email:', 'Password:', 'Save Password'] => undef,
	    ['Not found'] => Bivio::DieCode->DIE,
	],
    ],
    ['petshop-cart', 'Tables'] => [
	get_by_headings => [
	    ['Remove'] => undef,
	    ['Not found'] => Bivio::DieCode->DIE,
	],
    ],
]);
