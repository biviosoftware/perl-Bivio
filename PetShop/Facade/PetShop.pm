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
    is_production => 0,
    uri => 'petshop',
    Color => {
	initialize => sub {
	    my($fc) = @_;

	    #
	    # Links
	    #
	    $fc->group(page_link => 0x330099);
	    $fc->group(['page_vlink', 'page_alink'] => 0x330099);
            $fc->group(page_link_hover => 0xCC9900);

	    #
	    # Text
	    #
	    $fc->group(page_text => 0x000000);
	    $fc->group(page_bg => 0xFFFFFF);

	    # Basic emphasized text
	    $fc->group(page_heading => 0x111199);

	    $fc->group(['error', 'warning'] => 0x990000);

	    #
	    # Table
	    #
	    $fc->group(table_heading => -1);

            $fc->group(table_even_row_bg => 0xF0F9FF);
	    $fc->group(table_odd_row_bg => 0xD5EEFF);
	    $fc->group(table_separator => 0x000000);
            $fc->group(summary_line => 0x66CC66);

	    # PetShop colors
	    $fc->group(header_background => 0xEDE4B5);
	    $fc->group(category_background => 0xD5EEFF);

	    return;
	},
    },
    Font => {
	initialize => sub {
	    my($fc) = @_;
	    $fc->group(default => [
		'family=arial,sans-serif',
#		'size=x-small',
	    ]);
	    $fc->group(error_icon => ['color=error', 'larger', 'bold']);
	    $fc->group(page_heading => ['bold']);
	    $fc->group([qw(
                    table_heading
		    normal_table_heading
            )],
		    ['color=table_heading', 'bold'],
		   );
	    $fc->group(form_field_error => ['color=error', 'smaller', 'bold']);
	    $fc->group([qw(
		    error
		    warning
            )],
		   ['color=error', 'bold']);
	    $fc->group(form_field_error_label => ['color=error', 'italic']);
	    $fc->group(['list_error', 'checkbox_error'] =>
		   ['color=error', 'smaller']);
	    $fc->group(italic => ['italic']);
	    $fc->group([qw(
                    strong
                    table_row_title
            )],
		   ['bold']);
	    $fc->group([qw(
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
            )],
		   []);

	    $fc->group(menu_link => ['smaller']);
	    $fc->group(heading_link => ['larger', 'bold']);
	    $fc->group(main_description_text => ['smaller']);
	    return;
	}
    },
    Text => {
	initialize => \&_text,
    },
    Task => {
	initialize => \&_task,
    },
    HTML => {
	initialize => sub {
	    my($fc) = @_;
	    $fc->group(want_secure => 0);
	    $fc->group(table_default_align => 'left');
	    return;
	},
    },
});

=head1 METHODS

=cut

#=PRIVATE METHODS

# _task(Bivio::UI::Text t)
#
# Decls here just to be cleaner.
#
sub _task {
    my($t) = @_;

    # The task which utilities run as.
    $t->group(SHELL_UTIL => undef);

    # The task is called to execute views by name.  Bivio::UI::View prefixes
    # any uri with Text.view_uri_prefix, which should be the root of the tree
    # of all directly executed views.  These are views which aren't associated
    # with an explicitly Task.
    $t->group(SITE_ROOT => '/*');

    # Only icons are plain files.  We use /i as the URI, because it is
    # short and we it makes named-based routing easy for multi-tiered
    # systems.  /i must agree with the configured values of Bivio::UI::Icon.
    $t->group(LOCAL_FILE_PLAIN => ['/i/*']);

    $t->group(MY_CLUB_SITE => 'my-club-site/*');
    $t->group(LOGIN => 'pub/login');
    $t->group(LOGOUT => 'pub/logout');
    $t->group(USER_HOME => '?');
    $t->group(CLUB_HOME => '?');
    $t->group(CLIENT_REDIRECT => 'goto/*');
    $t->group(MY_SITE => 'my-site/*');
    $t->group(HELP => 'hp/*');
    $t->group(PRODUCTS => 'pub/products');
    $t->group(PRODUCT_SEARCH => 'pub/search');
    $t->group(ITEMS => 'items');
    $t->group(ITEM_DETAIL => 'pub/item-detail');
    $t->group(CART => 'my/cart');
    $t->group(CHECKOUT => 'my/checkout');
    $t->group(PLACE_ORDER => '?/place-order');
    $t->group(SHIPPING_ADDRESS => '?/shipping-address');
    $t->group(ORDER_CONFIRMATION => '?/confirm-order');
    $t->group(ORDER_DETAILS => '?/order-details');
    $t->group(MAIN => $t->get_facade->get('Text')->get_value('home_page_uri'));
    $t->group(USER_ACCOUNT_CREATE => 'my/create-account');
    $t->group(USER_ACCOUNT_EDIT => '?/account');
    $t->group(USER_ACCOUNT_CREATED => '?/account-created');
    $t->group(USER_ACCOUNT_UPDATED => '?/account-updated');
    $t->group(ORDER_COMMIT => '?/commit-order');
    $t->group(MISSING_COOKIES => 'pub/missing-cookies');
    $t->group(SOURCE => 'src');
    return;
}

# _text(Bivio::UI::Text t)
#
# Decls here just to be cleaner
#
sub _text {
    my($t) = @_;

    # This sets http_host and mail_host.  These are based on Bivio::UI::Text
    # configured values and Request.is_production is true.
    $t->value_host_groups;

    # Where to redirect to when coming in via /, i.e. http://petshop.bivio.net
    $t->group(home_page_uri => '/pub');

    # SITE_ROOT task calls View->execute_uri and we look for pages in
    # the "site_root" directory.
    $t->group(view_execute_uri_prefix => 'site_root/');

    # No label is convenient to have
    $t->group(none => '');

    $t->group('CartItem.quantity' => 'Quantity');
    $t->group('CartItem.unit_price' => 'Unit Price');
    $t->group('Email.email' => 'E-Mail Address');
    $t->group('EntityAddress.addr1' => 'Street Address');
    $t->group('EntityAddress.addr2' => 'Street Address 2');
    $t->group('EntityAddress.city' => 'City');
    $t->group('EntityAddress.country' => 'Country');
    $t->group('EntityAddress.state' => 'State/Province');
    $t->group('EntityAddress.zip' => 'Postal Code');
    $t->group('EntityPhone.phone' => 'Telephone Number');
    $t->group('Item.item_id' => 'Item ID');
    $t->group('Item.list_price' => 'Item Price');
    $t->group('Order.card_type' => 'Credit Card Type');
    $t->group('Order.credit_card' => 'Card Number');
    $t->group('Product.description' => 'Description');
    $t->group('Product.name' => 'Product Name');
    $t->group('Product.product_id' => 'Product ID');
    $t->group('RealmOwner.name' => 'User ID');
    $t->group('RealmOwner.password' => 'Password');
    $t->group(['User.first_name', 'Order.bill_to_first_name',
	'Order.ship_to_first_name'] => 'First Name');
    $t->group(['User.last_name', 'Order.bill_to_last_name',
	'Order.ship_to_last_name'] => 'Last Name');
    $t->group(add_to_cart => 'Add to Cart');
    $t->group(card_expire_year => 'Expiration Date');
    $t->group(continue => 'Continue');
    $t->group(in_stock => 'In Stock');
    $t->group(item_name => 'Item Name');
    $t->group(proceed_to_checkout => 'Proceed to Checkout');
    $t->group(remove => 'Remove');
    $t->group(ship_to_billing_address => 'Ship to Billing Address');
    $t->group(total_cost => 'Total Cost');
    $t->group(update_cart => 'Update Cart');

    # Table headings
    $t->group('ItemListForm.add_to_cart' => ' ');
    $t->group('CartItemListForm.remove' => ' ');

    $t->group(Image_alt => [
	bivio_power => 'Powered by bivio Inc.',
    ]);
    return;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
