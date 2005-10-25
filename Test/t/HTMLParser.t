# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# $Id$
BEGIN {
    use Bivio::IO::Config;
    Bivio::IO::Config->introduce_values({
	'Bivio::Test::HTMLParser::Forms' => {
	    error_color => '#990000',
	},
    });
}
use Bivio::Test;
use Bivio::DieCode;
use Bivio::IO::File;
my($_TMP);
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
        'div-err' => [
            ['Forms', 'Email Address:', 'visible', 'Email Address:', 'error']
	        => ['You must supply a value for Email Address.'],
        ],
    ], [
	'already-registered' => [
	    ['Forms', 'Your Full Name:', 'visible',
		 'Your Full Name:', 'error'] => 'You are already registered.Please click here if you would like to recover your password.',
	],
    ], [
	'missing-href' => [
	    ['Links', 'missing'] => Bivio::DieCode->DIE,
	],
    ], [
	duplicate => [
	    ['Forms', 'OK#0'] => undef,
	    ['Forms', 'OK#1'] => undef,
	],
    ], [
	'service-price' => [
	    ['Forms', 'Recalculate Price'] => undef,
	    ['Forms', 'Recalculate Price', 'submit', 'Recalculate Price'] => undef,
	    ['Forms', 'Recalculate Price', 'submit', 'Recalculate Price#0'] => undef,
	    ['Forms', 'Recalculate Price', 'submit', 'Recalculate Price#1'] => undef,
	],
    ], [
 	'ballot-pool-membership' => [
 	    ['Forms', 'Enrolled_0', 'visible',
 		 'Enrolled_0', 'checked' ] => [ 1 ],
 	    ['Forms', 'Enrolled_0', 'visible',
 		 'Enrolled_1', 'checked' ] => Bivio::DieCode::DIE,
 	],
    ], [
	'ieeesa-ballot-invitation-request-step-2' => [
	    ['Forms', 'AES/GA', 'visible',
		 'AES/GA', 'type'] => [ 'checkbox' ],
	],
    ], [
        'ioe-overview' => [
            ['Forms', '<prev', 'visible', 'PK', 'type'] => ['checkbox'],
            ['Forms', '<prev', 'visible', 'PK', 'checked'] => ['1'],
            ['Forms', '<prev', 'visible', '1983-1984', 'checked'] => ['1'],
            ['Forms', '<prev', 'visible', '2004-2005', 'checked'] => ['1'],
            ['Forms', '<prev', 'visible', '1984-1985', 'checked'] =>
                Bivio::DieCode::DIE,
        ],
    ], [
	'ieeesa-open-ballot-invitations' => [
	    ['Forms', 'Join Ballot Group_0', 'visible',
		 'Classification_0', 'options', '', 'value'] => [ '1' ],
	],
    ], [
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
	    ['Tables', 'Remove', 'headings', 0, 'text'] => ['Remove'],
	    ['Tables', 'Remove', 'rows', 0, 1, 'text'] => ['EST-6'],
	    ['Tables', 'Remove', 'rows', 0, 2, 'text'] => ['Male Adult Corgi'],
	    ['Tables', 'Remove', 'rows', 0, 5, 'text'] => ['1'],
	    ['Tables', 'Remove', 'rows', 1, 1, 'text'] => ['Total:'],
	    ['Tables', 'Remove', 'rows', 1, 6, 'text'] => ['18.50'],
	],
    ], [
	'petshop-checkout' => [
	    ['Tables', 'Item ID', 'headings', 2, 'text'] => ['In Stock'],
	    ['Tables', 'Item ID', 'rows', 0, 2, 'text'] => ['yes'],
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
    ], [
	'petshop-item-detail' => [
	    ['Tables', 'item', 'headings'] => [[]],
	    ['Tables', 'item', 'rows', 0, 1, 'text'] => ['18.50'],
	],
    ], [
	'as-blacklist-summary' => [
	    ['Tables', 'IP Address', 'rows', 0, 2, 'text'] => ['0'],
	    ['Tables', 'IP Address', 'rows', 1, 2, 'text'] => ['2'],
	    ['Links', '06/11/2003 GMT', 'href']
	        => ['/demo/blacklists/detail?p=10400025'],
	    ['Links', '06/11/2003 GMT_1', 'href']
	        => ['/demo/blacklists/detail?p=10300025'],
	],
    ], [
	'as-blacklist-detail' => [
	    ['Tables', 'Server', 'rows', 2, 2, 'text'] => ['request removal, website'],
	],
    ], [
	'as-mail-campaign-list' => [
	    ['Tables', 'First Seen', 'rows', 0, 1, 'text'] => 'REMINDER: Boulder Software Club - First Annual Business Builders Series',
	    ['Tables', 'First Seen', 'rows', 1, 1, 'text'] => 'campaign.btest at 06/16/2003 17:21:39',
	],
    ], [
        'societas-valuation' => [
            ['Tables', 'Shares Held', 'rows', 2, 1, 'text'] => ['(600.0000)'],
        ],
    ], [
        'button-error' => [
            ['Forms', 'Copyright Release_1', 'submit', 'Copyright Release_1', 'error']
	        => ['To join the ballot, you must sign the Copyright Release'],
        ],
    ]),
    ['login', 'Forms'] => [
	get_by_field_names => [
	    ['User ID or Email:', 'Password:', 'Save Password'] => undef,
	    ['Not found'] => Bivio::DieCode->DIE,
	],
	get_by_field_names => [
	    [qr/User ID/] => undef,
	    [qr/User ID/ . ''] => undef,
	    [qr/Not fo/] => Bivio::DieCode->DIE,
	],
    ],
    ['societas-valuation', 'Tables'] => [
        find_row => [
            ['Shares Held', '', 'Hartford Financial Services Group Inc (HIG)']
	        => qr{1,368.00}m,
        ],
        do_rows => [
            ['Shares Held', sub {
                 my($row, $index) = @_;
                 $_TMP = 0;
                 return 1 unless exists($row->{'Price per Share'});
                 return 1 unless $row->{'Price per Share'}->get('text')
                     eq '72.2800';
                 $_TMP = $index;
                 return 0;
             }] => sub {
                 return $_TMP == 2 ? 1 : 0;
             },
        ],
    ],
    ['petshop-cart', 'Tables'] => [
	get_by_headings => [
	    ['Remove'] => undef,
	    ['Not found'] => Bivio::DieCode->DIE,
	],
	do_rows => [
	    ['Remove', sub {
		my($row, $index) = @_;
		unless ($_TMP) {
		    die('index not 0 first time')
			unless $index eq 0;
		}
		die('In Stock is not yes')
		    unless $row->{'In Stock'}->get('text') eq 'yes';
		die($index, ': row index mismatch: ', $row)
		    unless $row->{_row_index} eq $index;
		$_TMP = $index;
		return 0;
	    }] => sub {
		return $_TMP == 0 ? 1 : 0;
	    },
	],
    ],
    ['as-mail-campaign-list', 'Tables'] => [
	do_rows => [
	    ['First Seen', sub {
		 my($row, $index) = @_;
		 if ($index == 1 && $row->{Subject}->get('text')
		     eq 'campaign.btest at 06/16/2003 17:21:39') {
		     $_TMP = $row->{ID}->get('text');
		     Bivio::Die->die(
			 $row->{Subject}->get('Links')->get_shallow_copy,
			 ': bad href'
		     ) unless $row->{Subject}->get_nested('Links',
			 'campaign.btest at 06/16/2003 17:21:39',
			 'href',
		     ) eq '/dev/campaign-domains?p=33600023';
		 }
		 return 1;
	    }] => sub {
		shift->actual_return([$_TMP]);
		return [1055805699];
	    },
	],
	find_row => [
	    ['First Seen', 'Subject', 'campaign.btest at 06/16/2003 17:21:39']
	        => qr{href.*/dev/campaign-domains\?p=33600023}m,
	    ['Subject', 'campaign.btest at 06/16/2003 17:21:39']
	        => qr{href.*/dev/campaign-domains\?p=33600023}m,
	],
    ],
]);
