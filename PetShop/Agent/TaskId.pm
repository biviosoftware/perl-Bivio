# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Agent::TaskId;
use strict;
$Bivio::PetShop::Agent::TaskId::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Agent::TaskId::VERSION;

=head1 NAME

Bivio::PetShop::Agent::TaskId - demo tasks

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Agent::TaskId;

=cut

use Bivio::Delegate::SimpleTaskId;
@Bivio::PetShop::Agent::TaskId::ISA = ('Bivio::Delegate::SimpleTaskId');

=head1 DESCRIPTION

C<Bivio::PetShop::Agent::TaskId>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_delegate_info"></a>

=head2 static get_delegate_info() : array_ref

Returns the task declarations.

=cut

sub get_delegate_info {
    my($proto) = @_;
    return $proto->merge_task_info($proto->SUPER::get_delegate_info, [
	# Overwrite default MY_SITE which is a no-op
	[qw(
	    MY_SITE
	    4
	    GENERAL
	    ANY_USER
	    Action.UserRedirect
	    next=USER_ACCOUNT_EDIT
	)],
	# Overwrite default ADM_SUBSTITUTE_USER
	[qw(
	    ADM_SUBSTITUTE_USER
	    11
	    GENERAL
	    ADMIN_READ&ADMIN_WRITE
	    Model.AdmSubstituteUserForm
            View.adm-substitute-user
	    next=USER_ACCOUNT_EDIT
	)],
	[qw(
	    PRODUCTS
	    500
	    GENERAL
	    ANYBODY
	    Model.ProductList->execute_load_all_with_query
	    View.products
	)],
	[qw(
	    PRODUCT_SEARCH
	    501
	    GENERAL
	    ANYBODY
	    Model.ProductSearchList->execute_load_page
	    View.search
	)],
	[qw(
	    ITEMS
	    502
	    GENERAL
	    ANYBODY
	    Model.ItemList->execute_load_all_with_query
	    Model.ItemListForm
	    View.items
	    next=CART
	    MISSING_COOKIES=MISSING_COOKIES
	)],
	[qw(
	    ITEM_DETAIL
	    503
	    GENERAL
	    ANYBODY
	    Model.Item->execute_load_parent
	    Model.Inventory->execute_load_parent
	    Model.ItemForm
	    View.item
	    next=CART
	    MISSING_COOKIES=MISSING_COOKIES
	)],
	[qw(
	    CART
	    504
	    GENERAL
	    ANYBODY
	    Model.CartItemList->execute_load_all
	    Model.CartItemListForm
	    View.cart
	    next=CART
	    want_query=0
	    MISSING_COOKIES=MISSING_COOKIES
	)],
	[qw(
	    CHECKOUT
	    505
	    GENERAL
	    ANYBODY
	    Model.CartItemList->execute_load_all
	    View.checkout
	    MISSING_COOKIES=MISSING_COOKIES
	)],
	[qw(
	    PLACE_ORDER
	    506
	    USER
	    DATA_WRITE&DATA_READ
	    Model.OrderForm
	    View.place-order
	    next=ORDER_COMMIT
	    MISSING_COOKIES=MISSING_COOKIES
	)],
	[qw(
	    SHIPPING_ADDRESS
	    507
	    USER
	    DATA_WRITE&DATA_READ
	    Model.ShippingAddressForm
	    View.shipping-address
	    next=PLACE_ORDER
	)],
	[qw(
	    ORDER_CONFIRMATION
	    508
	    USER
	    DATA_WRITE&DATA_READ
	    Model.OrderConfirmationForm
	    View.order-confirmation
	    next=ORDER_DETAILS
	)],
	[qw(
	    ORDER_DETAILS
	    509
	    USER
	    DATA_READ
	    Action.LocalFilePlain
	)],
	[qw(
	    MAIN
	    510
	    GENERAL
	    ANYBODY
	    View.main
	)],
	[qw(
	    USER_ACCOUNT_CREATE
	    511
	    GENERAL
	    ANYBODY
	    Action.UserLogout
	    Model.UserAccountForm
	    View.account
	    next=USER_ACCOUNT_CREATED
	    MISSING_COOKIES=MISSING_COOKIES
	)],
	[qw(
	    USER_ACCOUNT_EDIT
	    512
	    USER
	    DATA_WRITE&DATA_READ
	    Model.UserAccountForm
	    View.account
	    next=USER_ACCOUNT_UPDATED
	)],
	[qw(
	    USER_ACCOUNT_CREATED
	    513
	    USER
	    DATA_READ
	    View.account-created
	)],
	[qw(
	    USER_ACCOUNT_UPDATED
	    514
	    USER
	    DATA_READ
	    View.account-updated
	)],
	[qw(
	    ORDER_COMMIT
	    515
	    USER
	    DATA_READ
	    Model.Order->execute_load_parent
	    Model.OrderStatus->execute_load_parent
	    Model.CartItemList->execute_load_for_order
	    View.order-commit
	    MISSING_COOKIES=MISSING_COOKIES
	)],
	[qw(
	    MISSING_COOKIES
	    516
	    GENERAL
	    ANYBODY
	    View.missing-cookies
	)],
	[qw(
	    LOGIN
	    517
	    GENERAL
	    ANYBODY
	    Action.UserLogout
	    Model.UserLoginForm
	    View.login
	    next=CART
	    MISSING_COOKIES=MISSING_COOKIES
	)],
	[qw(
	    LOGOUT
	    518
	    GENERAL
	    ANYBODY
	    Action.UserLogout->execute
	    Action.ClientRedirect->execute_next
	    next=MAIN
	)],
	[qw(
            SOURCE
            519
	    GENERAL
	    ANYBODY
	    View.source
	)],
	[qw(
            MAIL_RECEIVE_DISPATCH
            520
	    GENERAL
	    ANYBODY
	    Model.MailReceiveDispatchForm
            next=MAIL_RECEIVE_NOT_FOUND
            NOT_FOUND=MAIL_RECEIVE_NOT_FOUND
            NO_RESOURCES=MAIL_RECEIVE_NO_RESOURCES
	)],
	[qw(
            MAIL_RECEIVE_NO_RESOURCES
            521
            GENERAL
            ANYBODY
            Action.MailReceiveStatus->execute_no_resources
        )],
	[qw(
            MAIL_RECEIVE_NOT_FOUND
            522
            GENERAL
            ANYBODY
            Action.MailReceiveStatus->execute_not_found
        )],
	[qw(
            MAIL_RECEIVE_IGNORE
            523
            USER
            ANYBODY
            Action.MailReceiveStatus->execute
        )],
    ]);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
