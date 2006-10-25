# Copyright (c) 2000-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Facade::PetShop;
use strict;
use base 'Bivio::UI::FacadeBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

my($_SELF) = __PACKAGE__->new({
    clone => undef,
    is_production => 1,
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
    ],
    Font => [
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
	# The task which utilities run as.
	[SHELL_UTIL => undef],

	# The task is called to execute views by name.  Bivio::UI::View
	# prefixes any uri with Text.view_uri_prefix, which should be the
	# root of the tree of all directly executed views.  These are views
	# which aren't associated with an explicitly Task.
	[SITE_ROOT => '/*'],

	# Only icons are plain files.  We use /i as the URI, because it is
	# short and we it makes named-based routing easy for multi-tiered
	# systems.  /i must agree with the configured values
	# of Bivio::UI::Icon.
	[LOCAL_FILE_PLAIN => '/i/*'],

	[MY_CLUB_SITE => 'my-club-site/*'],
	[LOGIN => 'pub/login'],
	[LOGOUT => 'pub/logout'],
	[USER_HOME => '?'],
	[CLUB_HOME => '?'],
	[CLIENT_REDIRECT => 'goto/*'],
	[DEFAULT_ERROR_REDIRECT_FORBIDDEN => undef],
	[FORBIDDEN => undef],
	[MY_SITE => 'my-site/*'],
	[HELP => 'help/*'],
	[FAVICON_ICO => 'favicon.ico'],
	[ROBOTS_TXT => 'robots.txt'],
	[TEST_BACKDOOR => '_test_backdoor'],
	[GENERAL_USER_PASSWORD_QUERY => '/pub/forgot-password'],
	[GENERAL_USER_PASSWORD_QUERY_MAIL => undef],
	[GENERAL_USER_PASSWORD_QUERY_ACK => '/pub/forgot-password-ack'],
	[USER_PASSWORD_RESET => '?/new-password'],
	[USER_PASSWORD => '?/change-password'],
	[PRODUCTS => 'pub/products'],
	[ITEM_SEARCH => 'pub/search'],
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
	[FORUM_PUBLIC_FILE => '?/pub/*'],
	[FORUM_FILE_READ => '?/file/*'],
	[FORUM_WIKI_VIEW => '?/wiki/*'],
	[EXAMPLE_EG1 => '/pub/eg1'],
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
    ],
    Text => [
	# Where to redirect to when coming in via /,
	# i.e. http://petshop.bivio.biz
	[home_page_uri => '/pub'],

	[support_email => 'webmaster@localhost.localdomain'],
	[site_name => 'PetShop'],
	[site_copyright => q{bivio Software, Inc.}],
	# SITE_ROOT task calls View->execute_uri and we look for pages in
	# the "site_root" directory.
	[view_execute_uri_prefix => 'site_root/'],
	[favicon_uri => '/i/favicon.ico'],

	[form_error_title => 'Please correct the errors below:'],

	# No label is convenient to have
	[none => ''],

	[[qw(paged_detail paged_list)] => [
	    prev => 'back',
	    next => 'next',
	    list => 'back to list',
	]],
	[sep => 'foot2_menu_sep'],
	[Address => [
	    street1 => 'Street Address',
	    city => 'City',
	    state => 'State/Province',
	    country => 'Country',
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
	[[qw(login email)] => 'Email'],
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
	[UserPasswordQueryForm => [
	    ok_button => 'Reset Password',
	]],
	[UserPasswordForm => [
	    old_password => 'Current Password',
	    new_password => 'New Password',
	    confirm_new_password => 'Re-enter New Password',
	    ok_button => 'Change',
	]],
	[ForumList => [
	    'RealmOwner.name' => 'Forum',
	    'RealmOwner.display_name' => 'Title',
	    'Forum.want_reply_to' => 'Reply-To List?',
	    'admin_only_forum_email' => 'Admin Only Email?',
	    'system_user_forum_email' => 'System User Email?',
	    'public_forum_email' => 'Public Email?',
	    'Forum.forum_id' => 'Database Key',
	]],
	[ForumUserList => [
	    'Email.email' => 'Email',
	    mail_recipient => 'Subscribed?',
	    file_writer => 'Write Files?',
	    administrator => 'Administrator?',
	    'RealmUser.user_id' => 'Database Key',
	]],
	[EmailAliasList => [
	    'EmailAlias.incoming' => 'From Email',
	    'EmailAlias.outgoing' => 'To Email or Forum',
	    'primary_key' => 'Database Key',
	]],

	# Table headings
	['ItemListForm.add_to_cart' => ' '],
	['CartItemListForm.remove' => ' '],
	[Image_alt => [
	    bivio_power => 'Powered by bivio Software, Inc.',
	    image_bunit => 'Image.bunit',
	    sort_up => 'This column sorted in descending order',
	    sort_down => 'This column sorted in ascending order',
	]],
	[HelpWiki => [
	    header => 'Help',
	    footer => '',
	]],

	# Misc Model support
	['MailReceiveDispatchForm.uri_prefix' => '_mail_receive_'],
	['WorkflowCallerForm.prev_task' => 'Previous Task'],
	[test_text => 'Global'],
	[Test_Text_Parent => [
	    test_text => 'Child',
	    test_text_only_child => 'Only Child',
	]],
	[ok_button => ' OK '],
	[cancel_button => 'Cancel'],
	[acknowledgement => [
	    SHELL_UTIL => 'shell util ack',
	    GENERAL_USER_PASSWORD_QUERY => q{An email has been sent to String([qw(Model.UserPasswordQueryForm Email.email)], 'strong'); with a link to reset your password.},
	    USER_PASSWORD => q{Your password has been changed.},
	    password_nak => q{We're sorry, but the link you clicked on is no longer valid.  Please enter your email address and send again.},
	]],
	[title => [
	    SHELL_UTIL => 'shell util',
	    USER_HOME => 'user home',
	    SITE_ROOT => 'home',
	    ADM_SUBSTITUTE_USER => 'su',
	    EXAMPLE_EG1 => 'Example 1',
	]],
	[rsspage => [
	    NumberedList => [
		title => 'ht',
		description => 'hd',
	    ],
	]],
    ],
});

1;
