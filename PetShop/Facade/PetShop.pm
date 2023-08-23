# Copyright (c) 2000-2023 bivio Software, Inc.  All Rights Reserved.
package Bivio::PetShop::Facade::PetShop;
use strict;
use Bivio::Base 'UI.FacadeBase';

my($_SHARED_VALUES) = [
    [qw(shared_value1 shared_value2)] => 'PetShop',
    [qw(shared_value3 shared_value4)] => 'PetShop',
    table_default_align => 'left',
    page_left_margin => 20,
];

__PACKAGE__->new({
    uri => 'petshop',
    http_host => 'petshop.bivio.biz',
    mail_host => 'bivio.biz',
    is_production => 1,
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
        [category_background => 0xF0F9FF],
        [acknowledgement => 0x009900],
        [bunit_complex => 0xFF0000],
        [bunit_border => 0x00ff00],
        [example_background => 0xFFFFFF],
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
        [th => ['center', 'style=padding: .5em']],
        [th_a => ['center']],
        [string_test1 => ['family=', 'class=string_test1']],
    ],
    FormError => [
        ['UserLoginForm.RealmOwner.password.NULL' => 'Please enter a password.'],
        ['UserCreateForm.no_such_field.NULL' => 'vs_syntax(err or)'],
    ],
    HTML => __PACKAGE__->make_groups(__PACKAGE__->bunit_shared_values),
    Task => [
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
        [MAIN => '/pub'],
        [USER_ACCOUNT_CREATE => 'my/create-account'],
        [USER_ACCOUNT_EDIT => '?/account'],
        [USER_ACCOUNT_EDIT_BY_SUPER_USER => '?/edit-account'],
        [USER_ACCOUNT_DELETE => '?/delete-account'],
        [USER_ACCOUNT_CREATED => '?/account-created'],
        [USER_ACCOUNT_UPDATED => '?/account-updated'],
        [ORDER_COMMIT => '?/commit-order'],
        [SOURCE => 'src/*'],
        __PACKAGE__->mail_receive_task_list(
            'MAIL_RECEIVE_IGNORE',
            'USER_MAIL_RECEIVE',
            'GROUP_MAIL_RECEIVE_NIGHTLY_TEST_OUTPUT',
            'GROUP_MAIL_RECEIVE_WEEKLY_BUILD_OUTPUT',
        ),
        [USER_ACCOUNT_CREATE_AND_PLACE_ORDER => 'my/create-account-and-order'],
        [ORDER_HOME => '?'],
        [WORKFLOW_CALLER => 'pub/workflow-caller'],
        [WORKFLOW_STEP_1 => 'pub/workflow-step-1'],
        [WORKFLOW_STEP_2 => 'pub/workflow-step-2'],
        [USER_REALMLESS_REDIRECT => 'ru/*'],
        [ORDER_REALMLESS_REDIRECT => 'ro/*'],
        [PUBLIC_USER_FILE_READ => '?/public-file/*'],
        [USER_FILE_READ => '?/file/*'],
        [USER_DAV => '?/dav/*'],
        [EXAMPLE_EG1 => '/pub/eg1'],
        [FORUM_PUBLIC_EXAMPLE_EG1 => '?/pub/eg1'],
        [USER_ROLE_IN_REALM => '?/role-in-realm'],
        [FORUM_ROLE_IN_REALM => '?/role-in-realm'],
        [FIELD_TEST_FORM => 'pub/field-test-form'],
        [TEST_MULTI_ROLES1 => undef],
        [TEST_MULTI_ROLES2 => undef],
         [CLIENT_REDIRECT_PERMANENT_MAP => 'permanent-redirect/*'],
        [TEST_WANT_INSECURE => '/pub/test-want-insecure'],
        [TEST_REQUIRE_SECURE => '/pub/test-require-secure'],
        [TEST_JOB_QUEUE => '/pub/test-job-queue'],
    ],
    Constant => __PACKAGE__->make_groups([
        @{__PACKAGE__->bunit_shared_values},
        xlink_bunit1 => {
            task_id => 'LOGIN',
            query => undef,
            no_context => 1,
        },
        xlink_bunit2 => {
            uri => '',
            anchor => 'a1',
        },
        xlink_bunit3 => {
            uri => [sub {shift->req('bunit3')}],
        },
        view_shortcuts1 => 'one',
        my_site_redirect_map => sub {[
            [qw(GENERAL ADMINISTRATOR ADM_SUBSTITUTE_USER)],
            [qw(guest ADMINISTRATOR USER_PASSWORD)],
             [qw(USER ADMINISTRATOR SITE_ROOT)],
        ]},
        threepartpage_want_ForumDropDown => 1,
        ThreePartPage_want_dock_left_standard => 1,
        constant_bunit => [
            undef => undef,
            three => 3,
            empty_sub => sub {},
        ],
    ]),
    CSS => [
        [b_logo_su_logo => ''],
        [b_td_header_left => ''],
    ],
    Text => [
        @{__PACKAGE__->make_groups(__PACKAGE__->bunit_shared_values)},
        [bunit_simple => 'simple text'],
        [bunit_escape => '"quoted"\backslash'],
        [bunit_newline => "new\nline"],
        [realm_owner_demo => [
            bunit_level1 => [
                '' => 'demo_1',
                bunit_level2 => [
                    bunit_level3 => 'demo_3',
                ],
            ],
        ]],
        [bunit_level1 => [
            '' => 'anon_1',
            bunit_level2 => [
                bunit_level3 => 'anon_3',
            ],
        ]],
        # Where to redirect to when coming in via /,
        # i.e. http://petshop.bivio.biz
        [home_page_uri => '/pub'],

        [site_name => 'PetShop'],
        [site_copyright => q{bivio Software, Inc.}],
        # SITE_ROOT task calls View->execute_uri and we look for pages in
        # the "site_root" directory.
        [view_execute_uri_prefix => 'site_root/'],
        [sep => 'foot2_menu_sep'],
        [separator => [
            credit_card => 'Credit Card Information',
            billing_address => 'Billing Address',
            shipping_address => 'Shipping Address',
            account_information => 'Account Information',
            address => 'Address',
        ]],
        [[qw(Address Address_2)] => [
            street1 => 'Street',
            state => 'State/Province',
            zip => 'Postal Code',
        ]],
        [CartItem => [
            quantity => 'Quantity',
            unit_price => 'Unit Price',
        ]],
        [ECCreditCardPayment => [
            card_number => 'Card Number',
            card_expiration_date => 'Card Expiration Date',
        ]],
        [Item => [
            item_id => 'Item ID',
            list_price => 'Item Price',
        ]],
        [Order => [
            [qw(bill_to_name ship_to_name)] => 'Name',
        ]],
        [[qw(Phone.phone Phone_2.phone)] => 'Phone'],
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
        [CartItemListForm => [
            ok_button => 'Proceed to Checkout',
            remove => 'Remove',
        ]],
        [[qw(ConfirmationForm OrderForm ShippingAddressForm)] => [
            ok_button => 'Continue',
        ]],
        [ItemForm => [
            ok_button => 'Add to Cart',
        ]],
        [UserAccountForm => [
            new_password => 'Password',
            ok_button => q{If(['auth_user_id'], 'Update MyAccount', 'Create MyAccount');},
        ]],
        [UserPasswordForm => [
            ok_button => 'Change',
        ]],
        [UserLoginForm => [
            ok_button => 'Sign In',
            'StandardSubmit.bunit' => 'bunit',
            prose => [
                prologue => q{String('Please sign into the bOP Pet Shop Demo', 'page_heading');},
                epilogue => '',
            ],
        ]],
        # Table headings
        [Image_alt => [
            bivio_power => 'Powered by bivio Software, Inc.',
            image_bunit => 'Image.bunit',
        ]],
        ['WorkflowCallerForm.prev_task' => 'Previous Task'],
        [test_text => 'Global'],
        [Test_Text_Parent => [
            test_text => 'Child',
            test_text_only_child => 'Only Child',
        ]],
        [acknowledgement => [
            SHELL_UTIL => 'shell util ack',
        ]],
        [[qw(page3.title xhtml.title)] => [
            LOGIN => 'Sign In',
        ]],
        [title => [
            WORKFLOW_CALLER => 'Workflow Caller',
            WORKFLOW_STEP_1 => 'Workflow Step 1',
            WORKFLOW_STEP_2 => 'Workflow Step 2',
            USER_ACCOUNT_CREATE_AND_PLACE_ORDER => 'Account Created',
            USER_ACCOUNT_CREATED => 'Account Created',
            USER_ACCOUNT_UPDATED => 'Account Updated',
            USER_ACCOUNT_CREATE => 'Account',
            LOGIN => 'Sign In',
            CART => 'Cart',
            CHECKOUT => 'Check Out',
            PLACE_ORDER => 'Enter Your Information',
            MAIN => 'Welcome to the bOP Pet Shop Demo',
            ORDER_CONFIRMATION => 'Confirm Shipping Data',
            ORDER_COMMIT => 'Order Shipped',
            ITEM_SEARCH => 'Search Results',
            PRODUCTS => 'Product Category',
            ITEMS => 'Product Category',
            ITEM_DETAIL => 'Product Information',
            SHIPPING_ADDRESS => 'Enter Shipping Information',
            SHELL_UTIL => 'shell util',
            USER_HOME => 'user home',
            EXAMPLE_EG1 => 'Example 1',
            SOURCE => '',
            FORUM_PUBLIC_EXAMPLE_EG1 => 'Example 1',
        ]],
        [xlink => [
            bunit1 => 'one',
            SITE_ROOT => 'home',
            bunit2 => 'anchor',
            xhtml_logo_normal => q{If(view_widget_value('is_petshop'), Join([SPAN_logo_title('bOP Pet Shop'), BR(), SPAN_logo_demo('demo')]), ' ');},
        ]],
        [[qw(xlink title)] => [
            SITE_WIKI_VIEW => 'Groupware',
            CART => 'Cart',
            USER_ACCOUNT_EDIT => 'MyAccount',
            LOGIN => 'Sign-in',
            LOGOUT => 'Sign-out',
            USER_ACCOUNT_CREATE => 'New User',
            GENERAL_USER_PASSWORD_QUERY => 'Forgot Password?',
        ]],
        [SiteRoot => [
            hm_bunit1 => 'bunit1',
        ]],
        ['Email.want_bulletin' => 'want_bulletin'],
        [realm_id => 'realm_id'],
        ['FormField2Form' => [
            'Email_99.want_bulletin' => 'Email_99',
            'Email.realm_id' => 'Email.realm_id',
        ]],
        [FieldTestForm => [
            boolean => 'Boolean',
            date => 'Date',
            date_time => 'DateTime',
            realm_name => 'RealmName',
            line => 'Line',
            text => 'Text',
        ]],
        [Bivio => [
            DieCode => [
                DIE => 'Internal server error',
            ],
        ]],
        [Type => [
            HTTPStatus => [
                303 => 'BUNIT found',
            ],
        ]],
    ],
    b_use('FacadeComponent.Enum')->make_facade_decl([
        Type => [
            BunitEnum => [
                [UNKNOWN => 'Undetermined', 'Undetermined Description'],
                [NAME1 => '1st', 'First Description'],
                [NAME2 => '2nd'],
            ],
        ],
    ]),
    b_use('FacadeComponent.WidgetSubstitute')->make_facade_decl([
        [qw(Simple bunit_label1 bunit_v1)],
    ]),
});

sub bunit_shared_values {
    return $_SHARED_VALUES;
}

1;
