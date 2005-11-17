# Copyright (c) 2001-2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Delegate::TaskId;
use strict;
$Bivio::PetShop::Delegate::TaskId::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Delegate::TaskId::VERSION;

=head1 NAME

Bivio::PetShop::Delegate::TaskId - demo tasks

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Delegate::TaskId;

=cut

use Bivio::Delegate::SimpleTaskId;
@Bivio::PetShop::Delegate::TaskId::ISA = ('Bivio::Delegate::SimpleTaskId');

=head1 DESCRIPTION

C<Bivio::PetShop::Delegate::TaskId>

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
	[qw(
	    PRODUCTS
	    500
	    GENERAL
	    ANYBODY
	    Model.ProductList->execute_load_all_with_query
	    View.products
	)],
	[qw(
	    ITEM_SEARCH
	    501
	    GENERAL
	    ANYBODY
	    Model.ItemSearchList->execute_load_page
            Model.ItemSearchListForm
	    View.search
            next=CART
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
	)],
	[qw(
	    CHECKOUT
	    505
	    GENERAL
	    ANYBODY
	    Model.CartItemList->execute_load_all
	    View.checkout
	)],
	[qw(
	    PLACE_ORDER
	    506
	    USER
	    DATA_WRITE&DATA_READ
	    Model.OrderForm
	    View.place-order
	    next=ORDER_COMMIT
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
	    ORDER
	    DATA_READ
	    Model.Order->execute_load
	    Model.CartItemList->execute_load_for_order
            Model.ECPayment->execute_load
            Model.ECCreditCardPayment->execute_load
	    View.order-commit
	)],
	[qw(
            DEFAULT_ERROR_REDIRECT_MISSING_COOKIES
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
	[qw(
	    USER_ACCOUNT_CREATE_AND_PLACE_ORDER
	    524
	    GENERAL
	    ANYBODY
	    Model.UserAccountForm
	    View.account
	    next=PLACE_ORDER
	)],
	[qw(
	    USER_ACCOUNT_EDIT_BY_SUPER_USER
	    525
	    USER
	    SUPER_USER_TRANSIENT
	    Model.UserAccountForm
	    View.account
	    next=SITE_ROOT
	)],
	# This isn't fully implemented
	[qw(
	    USER_ACCOUNT_DELETE
	    526
	    USER
	    DATA_READ&DATA_WRITE&SUBSTITUTE_USER_TRANSIENT
	    View.account
	    next=SITE_ROOT
	)],
	# used by Model.RealmOwner
	[qw(
	    ORDER_HOME
	    527
	    ORDER
	    DATA_READ
	    Action.ClientRedirect->execute_next
	    next=SITE_ROOT
	)],
	[qw(
	    WORKFLOW_CALLER
	    528
	    GENERAL
	    ANYBODY
	    Model.WorkflowCallerForm
	    View.workflow-caller
	    next=CART
	    cancel=SITE_ROOT
	)],
	[qw(
	    WORKFLOW_STEP_1
	    529
	    GENERAL
	    ANYBODY
	    Model.WorkflowStepForm
	    View.workflow-step
	    next=WORKFLOW_STEP_2
	    cancel=USER_ACCOUNT_CREATE
	    want_workflow=1
	)],
	[qw(
	    WORKFLOW_STEP_2
	    530
	    GENERAL
	    ANYBODY
	    Model.WorkflowStepForm
	    View.workflow-step
	    next=LOGIN
	    cancel=USER_ACCOUNT_CREATE
	)],
	[qw(
	    USER_REALMLESS_REDIRECT
	    531
	    GENERAL
	    ANYBODY
	    Action.RealmlessRedirect
	    visitor_task=USER_ACCOUNT_CREATE
	    home_task=USER_ACCOUNT_EDIT
	    unauth_task=SITE_ROOT
	)],
	[qw(
	    ORDER_REALMLESS_REDIRECT
	    532
	    GENERAL
	    ANYBODY
	    Action.RealmlessRedirect
	    visitor_task=ORDER_COMMIT
	    home_task=ORDER_COMMIT
	    unauth_task=SITE_ROOT
	)],
	[qw(
            MAIL_RECEIVE
            533
            USER
            ANYBODY
            Action.MailReceiveStatus->execute
        )],
	[qw(
            PUBLIC_USER_FILE_READ
            534
            USER
            ANYBODY
	    Type.FileVolume->execute_plain
	    Action.RealmFile->execute_public
        )],
	[qw(
            USER_FILE_READ
            535
            USER
            DATA_READ
	    Type.FileVolume->execute_plain
	    Action.RealmFile
        )],
	[qw(
	    USER_DAV
	    536
	    USER
	    ANYBODY
	    Action.BasicAuthorization
	    Action.DAV
	    next=USER_DAV_TASKS
	)],
	[qw(
	    USER_DAV_TASKS
	    537
	    USER
	    DATA_READ
	    Model.UserTaskDAVList
	    files_task=USER_DAV_FILE
	    orders_task=USER_DAV_ORDER_LIST
	)],
	[qw(
	    USER_DAV_FILE
	    538
	    USER
	    DATA_READ
	    Model.RealmFileDAVList
	    require_dav=1
	)],
	[qw(
	    USER_DAV_ORDER_LIST
	    539
	    USER
	    ADMIN_READ
	    Model.UserRealmDAVList
	    realm_task=USER_DAV_ORDER
	)],
	[qw(
	    USER_DAV_ORDER
	    540
	    ORDER
	    DATA_READ
	    Model.UserTaskDAVList
	    detail_html_task=ORDER_COMMIT
	)],
    ]);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001-2005 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
