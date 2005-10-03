# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Facade::PetShop;
use strict;
$Bivio::PetShop::Facade::PetShop::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Facade::PetShop::VERSION;

=head1 NAME

Bivio::PetShop::Facade::PetShop - main production and default facade

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Facade::PetShop;

=cut

=head1 EXTENDS

L<Bivio::UI::Facade>

=cut

use Bivio::UI::Facade;
@Bivio::PetShop::Facade::PetShop::ISA = ('Bivio::UI::Facade');

=head1 DESCRIPTION

C<Bivio::PetShop::Facade::PetShop> is the main production and default Facade.

=cut

#=IMPORTS
use Bivio::UI::HTML::ViewShortcuts;

#=VARIABLES
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

my($_SELF) = __PACKAGE__->new({
    clone => undef,
    is_production => 1,
    uri => 'petshop',
    http_host => 'petshop.bivio.biz',
    mail_host => 'bivio.biz',
    Color => __PACKAGE__->make_groups([
	page_link => 0x330099,
	['page_vlink', 'page_alink'] => 0x330099,
	page_link_hover => 0xCC9900,
	page_text => 0x000000,
	page_bg => 0xFFFFFF,
	page_heading => 0x111199,
	error => 0x993300,
	warning => 0x993301,
	table_heading => -1,
	table_even_row_bg => 0xF0F9FF,
	table_odd_row_bg => 0xD5EEFF,
	table_separator => 0x000000,
	summary_line => 0x66CC66,
	header_background => 0xEDE4B5,
	category_background => 0xD5EEFF,
    ]),
    Font => __PACKAGE__->make_groups([
	default => ['family=arial,sans-serif'],
	error_icon => ['color=error', 'larger', 'bold'],
	page_heading => ['bold'],
	[qw(table_heading normal_table_heading)] =>
            ['color=table_heading', 'bold'],
	form_field_error => ['color=error', 'smaller', 'bold'],
	error => ['color=error', 'bold'],
	warning => ['color=warning', 'bold'],
	form_field_error_label => ['color=error', 'italic'],
	['list_error', 'checkbox_error'] =>
	       ['color=error', 'smaller'],
	italic => ['italic'],
	[qw(strong table_row_title)] => ['bold'],
	[qw(
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
	)] => [],
	menu_link => ['smaller'],
	heading_link => ['larger', 'bold'],
	main_description_text => ['smaller'],
	string_test1 => ['family=', 'class=string_test1'],
    ]),
    FormError => __PACKAGE__->make_groups([
	NULL => 'You must supply a value for vs_fe("label");.',
	'UserLoginForm.RealmOwner.password.NULL' => 'Please enter a password.',
	'UserCreateForm.no_such_field.NULL' => 'vs_syntax(err or)',
    ]),
    HTML => __PACKAGE__->make_groups([
	want_secure => 0,
	table_default_align => 'left',
	page_left_margin => 20,
    ]),
    Task => sub {
	my($fc) = @_;
	$fc->map_invoke(group => __PACKAGE__->make_groups([
	    # The task which utilities run as.
	    SHELL_UTIL => undef,

	    # The task is called to execute views by name.  Bivio::UI::View
	    # prefixes any uri with Text.view_uri_prefix, which should be the
	    # root of the tree of all directly executed views.  These are views
	    # which aren't associated with an explicitly Task.
	    SITE_ROOT => '/*',

	    # Only icons are plain files.  We use /i as the URI, because it is
	    # short and we it makes named-based routing easy for multi-tiered
	    # systems.  /i must agree with the configured values
            # of Bivio::UI::Icon.
	    LOCAL_FILE_PLAIN => '/i/*',

	    MY_CLUB_SITE => 'my-club-site/*',
	    LOGIN => 'pub/login',
	    LOGOUT => 'pub/logout',
	    USER_HOME => '?',
	    CLUB_HOME => '?',
	    CLIENT_REDIRECT => 'goto/*',
	    DEFAULT_ERROR_REDIRECT_FORBIDDEN => undef,
	    FORBIDDEN => undef,
	    MY_SITE => 'my-site/*',
	    HELP => 'hp/*',
	    FAVICON_ICO => 'favicon.ico',
	    ROBOTS_TXT => 'robots.txt',
	    TEST_BACKDOOR => '_test_backdoor',
	    PRODUCTS => 'pub/products',
	    ITEM_SEARCH => 'pub/search',
	    ITEMS => 'items',
	    ITEM_DETAIL => 'pub/item-detail',
	    CART => 'my/cart',
	    CHECKOUT => 'my/checkout',
	    PLACE_ORDER => '?/place-order',
	    SHIPPING_ADDRESS => '?/shipping-address',
	    ORDER_CONFIRMATION => '?/confirm-order',
	    ORDER_DETAILS => '?/order-details',
	    MAIN => $fc->get_facade->get('Text')->get_value('home_page_uri'),
	    USER_ACCOUNT_CREATE => 'my/create-account',
	    USER_ACCOUNT_EDIT => '?/account',
	    USER_ACCOUNT_EDIT_BY_SUPER_USER => '?/edit-account',
	    USER_ACCOUNT_DELETE => '?/delete-account',
	    USER_ACCOUNT_CREATED => '?/account-created',
	    USER_ACCOUNT_UPDATED => '?/account-updated',
	    ORDER_COMMIT => '?/commit-order',
	    DEFAULT_ERROR_REDIRECT_MISSING_COOKIES => 'pub/missing-cookies',
	    SOURCE => 'src',
	    ADM_SUBSTITUTE_USER => 'su',
	    MAIL_RECEIVE_DISPATCH => 'mail-handler',
	    MAIL_RECEIVE_IGNORE => '?/mail-handler-ignore',
	    MAIL_RECEIVE => '?/mail-handler-',
	    USER_ACCOUNT_CREATE_AND_PLACE_ORDER =>
		'my/create-account-and-order',
	    ORDER_HOME => '?',
	    WORKFLOW_CALLER => 'pub/workflow-caller',
	    WORKFLOW_STEP_1 => 'pub/workflow-step-1',
	    WORKFLOW_STEP_2 => 'pub/workflow-step-2',
	    USER_REALMLESS_REDIRECT => 'ru/*',
	    ORDER_REALMLESS_REDIRECT => 'ro/*',
        ]));
	return;
    },
    Text => __PACKAGE__->make_groups([
	# Where to redirect to when coming in via /,
	# i.e. http://petshop.bivio.biz
	home_page_uri => '/pub',

	# SITE_ROOT task calls View->execute_uri and we look for pages in
	# the "site_root" directory.
	view_execute_uri_prefix => 'site_root/',
	favicon_uri => '/i/favicon.ico',

	# No label is convenient to have
	none => '',

	Address => [
	    street1 => 'Street Address',
	    city => 'City',
	    state => 'State/Province',
	    country => 'Country',
	    zip => 'Postal Code',
	],
	CartItem => [
	    quantity => 'Quantity',
	    unit_price => 'Unit Price',
	],
	ECCreditCardPayment => [
	    card_number => 'Card Number',
	],
	'Email.email' => 'E-Mail Address',
	Item => [
	    item_id => 'Item ID',
	    list_price => 'Item Price',
	],
	Order => [
	    [qw(bill_to_name ship_to_name)] => 'Name',
	],
	'Phone.phone' => 'Telephone Number',
	Product => [
	    description => 'Description',
	    name => 'Product Name',
	    product_id => 'Product ID',
	],
	'login' => 'Email',
	RealmOwner => [
	    name => 'User ID',
	    password => 'Password',
	],
	['User.first_name', 'Order.bill_to_first_name',
	    'Order.ship_to_first_name'] => 'First Name',
	['User.last_name', 'Order.bill_to_last_name',
	    'Order.ship_to_last_name'] => 'Last Name',
	add_to_cart => 'Add to Cart',
	card_expire_year => 'Expiration Date',
	continue => 'Continue',
	in_stock => 'In Stock',
	item_name => 'Item Name',
	proceed_to_checkout => 'Proceed to Checkout',
	remove => 'Remove',
	ship_to_billing_address => 'Ship to Billing Address',
	total_cost => 'Total Cost',
	update_cart => 'Update Cart',

	# Table headings
	'ItemListForm.add_to_cart' => ' ',
	'CartItemListForm.remove' => ' ',
	Image_alt => [
	    bivio_power => 'Powered by bivio Inc.',
	],

	# Misc Model support
	'MailReceiveDispatchForm.uri_prefix' => 'mail-handler-',
	'WorkflowCallerForm.prev_task' => 'Previous Task',
	test_text => 'Global',
	Test_Text_Parent => [
	    test_text => 'Child',
	    test_text_only_child => 'Only Child',
	],
	ok_button => ' OK ',
	cancel_button => 'Cancel',
    ]),
});

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
