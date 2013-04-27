# Copyright (c) 2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::View::PetShop;
use strict;
use Bivio::Base 'View.Base';
b_use('UI.ViewLanguageAUTOLOAD');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = b_use('Type.Date');

sub account {
    my($self) = @_;
    return _with_menu(
	$self,
	'',
	vs_simple_form('UserAccountForm', [
	    _demo_warning(),
	    If(['auth_user'],
	       Link(
		   If([['auth_user'], '->require_otp'],
		      'Reset OTP',
		      'Convert your account to OTP',
		   ),
		  'USER_OTP')),
	    vs_blank_cell(),
	    String('Account Information:', 'page_heading', {
		cell_colspan => 2,
	    }),
	    'UserAccountForm.Email.email',
	    If(['auth_user'],
	       Link('Click here to change your password', 'USER_PASSWORD')),
	    ['UserAccountForm.RealmOwner.password', {
		row_control => ['!', 'task_id', '->eq_user_account_edit'],
	    }],
	    String('Address:', 'page_heading'),
	    'UserAccountForm.User.first_name',
	    'UserAccountForm.User.last_name',
	    vs_address_fields('UserAccountForm', ''),
	    vs_blank_cell(),
	    '*ok_button',
	]),
    );
}

sub account_created {
    my($self) = @_;
    return _with_menu(
	$self,
	'',
	Join([
	    String('Welcome to the bOP Pet Shop Demo', 'page_heading'),
	    BR(),
	    BR(),
	    _account_message('Your account was successfully created. Thank you for registering with us.'),
	]),
    );
}

sub account_updated {
    my($self) = @_;
    return _with_menu(
	$self,
	'',
	_account_message('Your account was successfully updated.'),
    );
}

sub cart {
    my($self) = @_;
    return _with_menu(
	$self,
	'Shopping Cart:',
	If(
	    ['Model.CartItemList', '->get_result_set_size'],
	    vs_simple_form('CartItemListForm', [
		Grid([[
		    vs_list('CartItemListForm', [
			['remove', {
			    column_heading => '',
			    class => 'submit',
			}],
			'Item.item_id',
			['item_name', {
			    wf_list_link => {
				query => 'THIS_CHILD_LIST',
				task => 'ITEM_DETAIL',
			    },
			}],
			'in_stock',
			'CartItem.unit_price',
			['CartItem.quantity', {
			    size => 4,
			}],
			'total_cost',
		    ], {
			footer_row_widgets => [
			    vs_blank_cell(),
			    String('Total:', 'table_heading'),
			    TableSummaryCell({
				field => 'total_cost',
				string_font => 'table_heading',
				column_span => 5,
			    }),
			],
		    }),
		    vs_blank_cell(),
		    FormField('CartItemListForm.update_cart', {
			class => 'submit',
		    }),
		]]),
		vs_blank_cell(),
		FormField('CartItemListForm.ok_button', {
		    class => 'submit',
		}),
	    ], 1),

	    # Else
	    'Your shopping cart is empty.',
	),
    );
}

sub checkout {
    my($self) = @_;
    return _with_menu(
	$self,
	'Shopping Cart:',
	Grid([[
	    vs_list('CartItemList', [
		'Item.item_id',
		['item_name', {
		    wf_list_link => {
			query => 'THIS_CHILD_LIST',
			task => 'ITEM_DETAIL',
		    },
		}],
		'in_stock',
		'CartItem.unit_price',
		'CartItem.quantity',
		'total_cost',
	    ], {
		footer_row_widgets => [
		    String('Total:', 'table_heading'),
		    vs_blank_cell()->put(column_span => 4),
		    TableSummaryCell({
			field => 'total_cost',
			string_font => 'table_heading',
		    }),
		],
	    }),
	], [
	    vs_blank_cell(),
	], [
	    SPAN_button_link(Link(
		'Continue',
		If(['user_state', '->eq_just_visitor'],
		    'USER_ACCOUNT_CREATE_AND_PLACE_ORDER',
		    'PLACE_ORDER',
		),
	    )),
	]]),
    );
}

sub item {
    my($self) = @_;
    _with_menu(
	$self,
	['Model.Item', '->format_name'],
	Form('ItemForm', Grid([[
	    Image(
		[['Model.Item', '->get_model', 'Product'], '->get_image_url'],
		{
		    alt => Join([
			String(['Model.Item', '->format_name']),
			': ',
			String(['Model.Product', 'description']),
		    ]),
		},
	    ),
	    vs_blank_cell(3),
	    Join([
		AmountCell(['Model.Item', 'list_price']),
		BR(),
		If(
		    ['Model.Inventory', 'quantity'],
		    Join([
			AmountCell(['Model.Inventory', 'quantity'])
			    ->put(decimals => 0),
			' in stock',
		    ]),
		    # Else
		    String('Back Ordered', 'error'),
		),
		BR(),
		BR(),
		FormField('ItemForm.ok_button', {
		    class => 'submit',
		}),
	    ]),
	], [
	    String(['Model.Product', 'description'])->put(cell_colspan => 3),
	]], {
	    id => 'item',
	})),
    );
}

sub items {
    my($self) = @_;
    return _with_menu(
	$self,
	# use the category from the first item in the list
	[['Model.ItemList', '->set_cursor_or_die', 0], 'Product.name'],
	vs_items_form('ItemListForm'),
    );
}

sub login {
    my($self) = @_;
    return _with_menu(
	$self,
	'',
	vs_simple_form('UserLoginForm', [
	    'UserLoginForm.login',
	    'UserLoginForm.RealmOwner.password',
	    '*ok_button',
	    vs_blank_cell(),
	    [
		vs_blank_cell(),
		XLink('USER_ACCOUNT_CREATE'),
	    ], [
		vs_blank_cell(),
		XLink('GENERAL_USER_PASSWORD_QUERY'),
	    ],
	]),
    );
}

sub main {
    return shift->internal_body(Grid([[
	DIV_pet_categories(List('CategoryList', [
	    Join([
		_category_link(),
		BR(),
		String(['Category.description']),
		BR(),
		BR(),
		BR(),
	    ]),
	])),
	vs_blank_cell(),
	Join([
	    MAP(Join([
		map({
		    my($product, $coords) = split(/:/, $_);
		    AREA({
			HREF => ['->format_uri', 'PRODUCTS', {
			    'ListQuery.parent_id' => uc($product),
			}],
			ALT => $product,
			COORDS => $coords,
		    }),
		} qw(
		    Dogs:116,6,255,210
		    Dogs:255,22,306,123
		    Fish:2,124,104,200
		    Dogs:38,204,141,281
		    Reptiles:141,237,243,314
		    Cats:243,204,345,279
		    Birds:267,124,369,200
		)),
	    ]))->put(ID => 'mainmap'),
	    Image('main', 'none')->put(attributes => ' usemap="#mainmap"'),
	]),
    ]], {
	expand => 1,
    }));
}

sub order_commit {
    my($self) = @_;
    view_put(
	xhtml_want_page_print => 1,
    );
    my($address_widget) = sub {
	my($heading, $location) = @_;
	$location = b_use('Type.Location')->from_name($location);
	return Join([
	    String($heading, 'page_heading'),
	    P(Join([
		String($location->get_short_desc),
		String(':'),
		BR(),
		String(['Model.Order', lc($location->get_name) . '_name']),
		BR(),
		[sub {
		    my($req) = @_;
		    b_use('Model.Address')->new($req)->load({
			location => $location,
		    });
		    return '';
		}],
		String(['Model.Address', 'street1']),
		BR(),
		If(['Model.Address', 'street2'],
		   Join([String(['Model.Address', 'street2']), BR()]),
	        ),
		Join([
		    String(['Model.Address', 'city']),
		    String(['Model.Address', 'state']),
		], ', '),
		vs_blank_cell(2),
		String(['Model.Address', 'zip']),
	    ])),
	]);
    };
    # renders the last four digits of the credit card
    my($card_number) = sub {
	my($source, $number) = @_;
	return '***********' . substr($number, -4, 4);
    };
    return _with_menu(
	$self,
	'',
	Grid([
	    [
		Join([
		    String('Date: ', 'page_heading'),
		    String(['Model.ECPayment', 'creation_date_time',
			    'HTMLFormat.Date']),
		]),
	    ], [
		Join([
		    String('Email: ', 'page_heading'),
		    [sub {
			 my($req) = @_;
			 b_use('Model.Email')->new($req)->unauth_load_or_die({
			     realm_id => $req->get('auth_user_id'),
			 });
			 return '';
		    }],
		    String(['Model.Email', 'email']),
		    BR(),
		]),
	    ], [
		String('Order Information:', 'page_heading'),
	    ], [
		Join([
		    String('Order ID: '),
		    String(['Model.Order', 'order_id']),
		    BR(),
		]),
	    ], [
		vs_list('CartItemList', [
		    'Item.item_id',
		    ['item_name', {
			wf_list_link => {
			    query => 'THIS_CHILD_LIST',
			    task => 'ITEM_DETAIL',
			},
		    }],
		    'CartItem.unit_price',
		    'CartItem.quantity',
		    'total_cost',
		], {
		    footer_row_widgets => [
			String('Total:', 'table_heading'),
			vs_blank_cell()->put(column_span => 3),
			TableSummaryCell({
			    field => 'total_cost',
			    string_font => 'table_heading',
			}),
		    ],
		}),
	    ], [
		$address_widget->('Shipping Information:', 'SHIP_TO'),
	    ], [
		$address_widget->('Billing Information:', 'BILL_TO'),
	    ], [
		String('Credit Card Information:', 'page_heading'),
	    ], [
		Grid([[
		    String('Number: '),
		    String([$card_number,
		        ['Model.ECCreditCardPayment', 'card_number']]),
		], [
		    String('Expiration Date: '),
		    CreditCardExpiration(
			['Model.ECCreditCardPayment', 'card_expiration_date'],
		    ),
		]], {
		    class => 'pet_small_pad',
		}),
	    ], [
		Join([
		    String('Status: ', 'page_heading'),
		    String([['Model.ECPayment', 'status'], '->get_short_desc']),
		]),
	    ],
	], {
	    class => 'pet_order',
	}),
    );
}

sub order_confirmation {
    my($self) = @_;
    my($order_field) = sub {
	my($req, $field) = @_;
	return ($req->get('Model.ConfirmationForm')
	    ->unsafe_get_context_field($field))[0];
    };
    # Returns a widget which render the specified address fields.
    my($address_widget) = sub {
	my($name_prefix, $address) = @_;
	$address ||= '';
	return P(Join([
	    String([$order_field, 'Order.' . $name_prefix . '_name']),
	    BR(),
	    String([$order_field, 'Address' . $address . '.street1']),
	    BR(),
	    If ([$order_field, 'Address' . $address . '.street2'],
		Join([
		    String([$order_field, 'Address' . $address . '.street2']),
		    BR(),
		]),
	    ),
	    String([$order_field, 'Address' . $address . '.city']),
	    ', ',
	    String([$order_field, 'Address' . $address . '.state']),
	    vs_blank_cell(2),
	    String([$order_field, 'Address' . $address . '.zip']),
	]));
    };
    return _with_menu(
	$self,
	'',
	vs_simple_form('ConfirmationForm', [
	    Prose(<<'EOF'),
Please confirm that the following data is correct and press
the B('Continue'); button to ship the order
EOF
	    '-billing_address',
	    $address_widget->('bill_to'),
	    '-shipping_address',
	    $address_widget->('ship_to', '_2'),
	    vs_blank_cell(),
	    '*ok_button',
	]),
    );
}

sub place_order {
    my($self) = @_;
    return _with_menu(
	$self,
	'',
	vs_simple_form('OrderForm', [
	    _demo_warning(),
	    '-credit_card',
	    'OrderForm.ECCreditCardPayment.card_number',
	    ['OrderForm.ECCreditCardPayment.card_expiration_date', {
		wf_class => 'MonthYear',
		base_field => 'card_exp',
		want_two_digit_month => 1,
	    }],
	    '-billing_address',
	    Prose(<<'EOF'),
Please confirm that the following Billing Address is correct and press
the B('Continue'); button
EOF
	    'OrderForm.Order.bill_to_name',
	    vs_address_fields('OrderForm'),
	    vs_blank_cell(),
	    'OrderForm.ship_to_billing_address',
	    vs_blank_cell(),
	    '*ok_button',
	]),
    );
}

sub products {
    my($self) = @_;
    return _with_menu(
	$self,
	# use the category from the first item in the list
	[['Model.ProductList', '->set_cursor_or_die', 0], 'Product.category_id'],
	vs_list('ProductList', [
	    'Product.product_id',
	    ['Product.name', {
		wf_list_link => {
		    query => 'THIS_CHILD_LIST',
		    task => 'ITEMS',
		},
	    }],
	    # For example, add a column by uncommenting this line.
	    # Must exist in Model.ProductList.
	    # 'Product.description',
	]),
    );
}

sub search {
    my($self) = @_;
    return _with_menu(
	$self,
	Join([
	    'Search Results for: ',
	    If([['Model.ItemSearchList', '->get_query'], 'search'],
	       vs_escape_html(
		   [['Model.ItemSearchList', '->get_query'], 'search']),
            ),
	]),
	vs_items_form('ItemSearchListForm'),
    );
}

sub shipping_address {
    my($self) = @_;
    return _with_menu(
	$self,
	'',
	vs_simple_form('ShippingAddressForm', [
	    Prose(<<'EOF'),
Please enter the name and address you would like your order shipped.
EOF
	    'ShippingAddressForm.Order.ship_to_name',
	    vs_address_fields('OrderForm', '_2'),
	    vs_blank_cell(),
	    '*ok_button',
	]),
    );
}

sub workflow_caller {
    my($self) = @_;
    return _with_menu(
	$self,
	vs_text('title.WORKFLOW_CALLER'),
	vs_simple_form('WorkflowCallerForm', [
	    'WorkflowCallerForm.prev_task',
	]),
    );
}

sub workflow_step {
    my($self) = @_;
    return _with_menu(
	$self,
	vs_text('title', [['->req', 'task_id'], '->get_name']),
	vs_simple_form('WorkflowStepForm', []),
    );
}

sub _account_message {
    my($message) = @_;
    return Join([
	$message,
	BR(),
	String(<<'EOF'),

Please select the shopping cart link to check out or one of the categories
from the menu bar to continue shopping.

EOF
	Link('Shop Main Page', 'MAIN'),
    ]);
}

sub _category_link {
    return Link(
	String(['Category.name'], 'heading_link'),
	['->format_uri', 'THIS_AS_PARENT', 'PRODUCTS'],
    );
}

sub _demo_warning {
    return String(<<'EOF', 'warning'),
This a demonstration site.
DO NOT ENTER REAL DATA.
EOF
}

sub _with_menu {
    my($self, $title, $content) = @_;
    return shift->internal_body(DIV_pet_content(Join([
	DIV_pet_title(String($title)),
	[sub {
	    my($req) = @_;
	    b_use('Model.CategoryList')->new($req)->load_all;
	    return '';
	}],
	List('CategoryList', [
	    _category_link(),
	], {
	    row_separator => Simple(' | '),
	}),
	BR(),
	BR(),
	$content,
    ])));
}

1;