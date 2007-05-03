# Copyright (c) 2000-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Facade::PetShop;
use strict;
use base 'Bivio::UI::FacadeBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

my($_SELF) = __PACKAGE__->new({
    uri => 'petshop',
    http_host => 'petshop.bivio.biz',
    mail_host => 'bivio.biz',
    Color => [
	[page_link => 0x330099],
	[['page_vlink', 'page_alink'] => 0x330099],
	[page_link_hover => 0xCC9900],
	[page_text => 0x000000],
	[page_bg => 0xFFFFFF],
	[page_heading => 0x111199],
	[error => 0x993300],
	[warning => 0x993301],
	[table_heading => -1],
	[table_even_row_bg => 0xF0F9FF],
	[table_odd_row_bg => 0xD5EEFF],
	[table_separator => 0x000000],
	[summary_line => 0x66CC66],
	[header_background => 0xEDE4B5],
	[category_background => 0xD5EEFF],
	[acknowledgement => 0x009900],
	[bunit_complex => 0xFF0000],
	[bunit_border => 0x00ff00],
	[example_background => 0xFFCCFF],
    ],
    Font => [
	map(["bunit_$_" => [$_]], qw(
	    bold
	    code
	    italic
	    larger
	    smaller
	    strike
	    underline
        )),
	[bunit_complex => ['family=arial', 'style=text-align: center', 'lowercase']],
	[default => ['family=arial,sans-serif']],
	[error_icon => ['color=error', 'larger', 'bold']],
	[page_heading => ['bold']],
	[[qw(table_heading normal_table_heading)] => ['color=table_heading', 'bold']],
	[form_field_error => ['color=error', 'smaller', 'bold']],
	[error => ['color=error', 'bold']],
	[warning => ['color=warning', 'bold']],
	[form_field_error_label => ['color=error', 'italic']],
	[acknowledgement => ['italic']],
	[['list_error', 'checkbox_error'] => ['color=error', 'smaller']],
	[italic => ['italic']],
	[[qw(strong table_row_title)] => ['bold']],
	[[qw(
	    form_field_description
	    form_field_label
	    table_cell
	    number_cell
	    action_button
	    radio
	    descriptive_page
	    page_legend
	    checkbox
	    page_text
	    input_field
	    search_field
	    mailto
	    link
	    form_submit
	    list_action
	)] => []],
	[menu_link => ['smaller']],
	[heading_link => ['larger', 'bold']],
	[main_description_text => ['smaller']],
	[string_test1 => ['family=', 'class=string_test1']],
    ],
    FormError => [
	[NULL => 'You must supply a value for vs_fe("label");.'],
	['UserLoginForm.RealmOwner.password.NULL' => 'Please enter a password.'],
	['UserCreateForm.no_such_field.NULL' => 'vs_syntax(err or)'],
    ],
    HTML => [
	[want_secure => 0],
	[table_default_align => 'left'],
	[page_left_margin => 20],
    ],
    Task => [
	[CLIENT_REDIRECT => 'goto/*'],
	[HELP => 'help/*'],
	[FAVICON_ICO => 'favicon.ico'],
	[ROBOTS_TXT => 'robots.txt'],
	[TEST_BACKDOOR => '_test_backdoor'],
	[PRODUCTS => 'pub/products'],
	[ITEM_SEARCH => 'pub/item-search'],
	[ITEMS => 'items'],
	[ITEM_DETAIL => 'pub/item-detail'],
	[CART => 'my/cart'],
	[CHECKOUT => 'my/checkout'],
	[PLACE_ORDER => '?/place-order'],
	[SHIPPING_ADDRESS => '?/shipping-address'],
	[ORDER_CONFIRMATION => '?/confirm-order'],
	[ORDER_DETAILS => '?/order-details'],
	[MAIN => sub {
	     shift->get_facade->get('Text')->get_value('home_page_uri');
	}],
	[USER_ACCOUNT_CREATE => 'my/create-account'],
	[USER_ACCOUNT_EDIT => '?/account'],
	[USER_ACCOUNT_EDIT_BY_SUPER_USER => '?/edit-account'],
	[USER_ACCOUNT_DELETE => '?/delete-account'],
	[USER_ACCOUNT_CREATED => '?/account-created'],
	[USER_ACCOUNT_UPDATED => '?/account-updated'],
	[ORDER_COMMIT => '?/commit-order'],
	[DEFAULT_ERROR_REDIRECT_MISSING_COOKIES => 'pub/missing-cookies'],
	[SOURCE => 'src'],
	[ADM_SUBSTITUTE_USER => 'su'],
	[MAIL_RECEIVE_DISPATCH => '_mail_receive/*'],
	[USER_MAIL_RECEIVE => '?/_mail_receive_'],
	[FORUM_MAIL_RECEIVE => '?/_mail_receive_'],
	[FORUM_MAIL_REFLECTOR => undef],
	[USER_MAIL_BOUNCE => sub {
	    '?/_mail_receive_'
	        . Bivio::Biz::Model->get_instance('RealmMailBounce')->TASK_URI;
	}],
	# Only needs to be defined for testing
	[MAIL_RECEIVE_IGNORE => '?/_mail_receive_ignore'],
	[MAIL_RECEIVE_NOT_FOUND => undef],
	[MAIL_RECEIVE_NO_RESOURCES => undef],
	[MAIL_RECEIVE_FORWARD => undef],
	[USER_ACCOUNT_CREATE_AND_PLACE_ORDER => 'my/create-account-and-order'],
	[ORDER_HOME => '?'],
	[WORKFLOW_CALLER => 'pub/workflow-caller'],
	[WORKFLOW_STEP_1 => 'pub/workflow-step-1'],
	[WORKFLOW_STEP_2 => 'pub/workflow-step-2'],
	[USER_REALMLESS_REDIRECT => 'ru/*'],
	[ORDER_REALMLESS_REDIRECT => 'ro/*'],
	[PUBLIC_USER_FILE_READ => '?/public/*'],
	[USER_FILE_READ => '?/file/*'],
	[USER_DAV => '?/dav/*'],
	[DAV => 'dav/*'],
	[FORUM_EASY_FORM => '?/EasyForm/*'],
	[EXAMPLE_EG1 => '/pub/eg1'],
	[FORUM_PUBLIC_EXAMPLE_EG1 => '?/pub/eg1'],
	[USER_ROLE_IN_REALM => '?/role-in-realm'],
	[FORUM_ROLE_IN_REALM => '?/role-in-realm'],
    ],
    Constant => [
	[help_wiki_realm_id => sub {
	     my($req) = shift->get_request;
	     return Bivio::Die->eval(
		 sub {
		     return Bivio::Biz::Model->new($req, 'RealmOwner')
			 ->unauth_load_or_die({name => 'fourem'})
			     ->get('realm_id');
		 },
	     ) || 1;
	}],
	[xlink_bunit1 => {
	    task_id => 'LOGIN',
	    query => undef,
	    no_context => 1,
	}],
	[xlink_bunit2 => {
	    uri => '',
	    anchor => 'a1',
	}],
    ],
    Text => [
	[bunit_simple => 'simple text'],
	[bunit_escape => '"quoted"\backslash'],
	[bunit_newline => "new\nline"],
	# Where to redirect to when coming in via /,
	# i.e. http://petshop.bivio.biz
	[home_page_uri => '/pub'],

	[support_email => 'webmaster@localhost.localdomain'],
	[site_name => 'PetShop'],
	[site_copyright => q{bivio Software, Inc.}],
	# SITE_ROOT task calls View->execute_uri and we look for pages in
	# the "site_root" directory.
	[view_execute_uri_prefix => 'site_root/'],
	[sep => 'foot2_menu_sep'],
	[Address => [
	    street1 => 'Street Address',
	    state => 'State/Province',
	    zip => 'Postal Code',
	]],
	[CartItem => [
	    quantity => 'Quantity',
	    unit_price => 'Unit Price',
	]],
	[ECCreditCardPayment => [
	    card_number => 'Card Number',
	]],
	[Item => [
	    item_id => 'Item ID',
	    list_price => 'Item Price',
	]],
	[Order => [
	    [qw(bill_to_name ship_to_name)] => 'Name',
	]],
	['Phone.phone' => 'Telephone Number'],
	[Product => [
	    description => 'Description',
	    name => 'Product Name',
	    product_id => 'Product ID',
	]],
	[[qw(login Email.email email)] => 'Email'],
	[RealmOwner => [
	    name => 'User ID',
	    password => 'Password',
	]],
	[['User.first_name', 'Order.bill_to_first_name', 'Order.ship_to_first_name'] => 'First Name'],
	[['User.last_name', 'Order.bill_to_last_name', 'Order.ship_to_last_name'] => 'Last Name'],
	[add_to_cart => 'Add to Cart'],
	[card_expire_year => 'Expiration Date'],
	[continue => 'Continue'],
	[in_stock => 'In Stock'],
	[item_name => 'Item Name'],
	[proceed_to_checkout => 'Proceed to Checkout'],
	[remove => 'Remove'],
	[ship_to_billing_address => 'Ship to Billing Address'],
	[total_cost => 'Total Cost'],
	[update_cart => 'Update Cart'],
	[UserPasswordForm => [
	    ok_button => 'Change',
	]],
	[UserLoginForm => [
	    ok_button => '  OK  ',
	]],
	# Table headings
	['ItemListForm.add_to_cart' => ' '],
	['CartItemListForm.remove' => ' '],
	[Image_alt => [
	    bivio_power => 'Powered by bivio Software, Inc.',
	    image_bunit => 'Image.bunit',
	]],
	# Misc Model support
	['MailReceiveDispatchForm.uri_prefix' => '_mail_receive_'],
	['WorkflowCallerForm.prev_task' => 'Previous Task'],
	[test_text => 'Global'],
	[Test_Text_Parent => [
	    test_text => 'Child',
	    test_text_only_child => 'Only Child',
	]],
	[acknowledgement => [
	    SHELL_UTIL => 'shell util ack',
	]],
	[title => [
	    SHELL_UTIL => 'shell util',
	    USER_HOME => 'user home',
	    EXAMPLE_EG1 => 'Example 1',
	    FORUM_PUBLIC_EXAMPLE_EG1 => 'Example 1',
	]],
	[rsspage => [
	    NumberedList => [
		title => 'ht',
		description => 'hd',
	    ],
	]],
	[xlink => [
	    bunit1 => 'one',
	    SITE_ROOT => 'home',
	    bunit2 => 'anchor',
	]],
	[SiteRoot => [
	    hm_bunit1 => 'bunit1',
	]],
    ],
});

1;

