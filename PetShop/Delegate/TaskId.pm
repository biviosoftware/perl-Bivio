# Copyright (c) 2001-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Delegate::TaskId;
use strict;
use Bivio::Base 'Delegate';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_delegate_info {
    my($proto) = @_;
    return $proto->merge_task_info(@{$proto->standard_components}, 'otp', [
	{
	    name => 'LOGIN',
	    items => [qw(
		Action.UserLogout
		Model.UserLoginForm
		View.login
	    )],
	    next => 'CART',
	},
	{
	    name => 'LOGOUT',
	    next => 'MAIN',
	},
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
            SOURCE
            519
	    GENERAL
	    ANYBODY
	    View.Source->show_module
	)],
#520-524
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
            USER_MAIL_RECEIVE
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
	    Action.RealmFile->execute_public
        )],
	[qw(
            USER_FILE_READ
            535
            USER
            DATA_READ
	    Action.RealmFile->execute_private
        )],
	[qw(
	    USER_DAV
	    536
	    USER
	    ANYBODY
	    Action.DAV
	    next=USER_DAV_TASKS
	    want_basic_authorization=1
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
	    next=USER_DAV_ORDER
	)],
	[qw(
	    USER_DAV_ORDER
	    540
	    ORDER
	    DATA_READ
	    Model.UserTaskDAVList
	    detail_html_task=ORDER_COMMIT
	)],
	[qw(
	    EXAMPLE_EG1
	    541
	    GENERAL
	    ANYBODY
	    View.Example->eg1
	)],
	[qw(
	    FORUM_PUBLIC_EXAMPLE_EG1
	    542
	    FORUM
	    ANYBODY
	    View.Example->eg1
	)],
	[qw(
            USER_ROLE_IN_REALM
	    543
	    USER
	    ANYBODY
	    Action.ClientRedirect->execute_unauth_role_in_realm
	    just_visitor_task=USER_ACCOUNT_CREATE
	    guest_task=EXAMPLE_EG1
	    administrator_task=USER_ACCOUNT_EDIT
	    next=SITE_ROOT
        )],
	[qw(
            FORUM_ROLE_IN_REALM
	    544
	    FORUM
	    ANYBODY
	    Action.ClientRedirect->execute_unauth_role_in_realm
	    just_visitor_task=USER_ACCOUNT_CREATE
	    member_task=USER_ACCOUNT_EDIT
	    administrator_task=USER_ACCOUNT_EDIT
	    next=SITE_ROOT
        )],
	[qw(
	    FORM_MODEL_BUNIT_LOGIN
	    545
	    GENERAL
	    ANYBODY
	    Action.UserLogout
	    Model.UserLoginForm
	    View.login
	    next=CART
	    form_error_task=SITE_ROOT
	)],
	[qw(
	    FIELD_TEST_FORM
	    546
	    GENERAL
	    ANYBODY
	    Model.FieldTestForm
	    Action.EmptyReply
	    next=FIELD_TEST_FORM
	)],
	[qw(
	    TEST_MULTI_ROLES1
	    547
	    GENERAL
	    TEST_PERMISSION1
	    Action.EmptyReply
	)],
	[qw(
	    TEST_MULTI_ROLES2
	    548
	    GENERAL
	    TEST_PERMISSION2
	    Action.EmptyReply
	)],
	[qw(
	    TEST_TASK2_BUNIT_1
	    549
	    GENERAL
	    ANYBODY
	), sub {die}],
	[qw(
	    TEST_TASK2_BUNIT_2
	    550
	    GENERAL
	    ANYBODY
	), sub {Bivio::Die->throw_die('SERVER_REDIRECT_TASK')}],
    ]);
}

1;
