# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
use strict;
use ExtUtils::MakeMaker;

my($_PREFIX) = 'perl/Bivio/';
my($_MODULES) = [qw(
    Agent/Dispatcher
    Agent/HTTP/Dispatcher
    Agent/HTTP/Cookie
    Agent/HTTP/Form
    Agent/HTTP/Query
    Agent/HTTP/Reply
    Agent/HTTP/Request
    Agent/Job/Dispatcher
    Agent/Job/Request
    Agent/Reply
    Agent/Request
    Agent/Task
    Agent/TaskId
    Auth/Permission
    Auth/PermissionSet
    Auth/Realm
    Auth/Realm/Club
    Auth/Realm/General
    Auth/Realm/User
    Auth/RealmType
    Auth/Role
    Auth/RoleSet
    Biz/Accounting/Ratio
    Biz/Action
    Biz/Action/ClientRedirect
    Biz/Action/HTTPDocument
    Biz/FormContext
    Biz/FormModel
    Biz/ListFormModel
    Biz/ListModel
    Biz/Model
    Biz/Model/Club
    Biz/Model/Email
    Biz/Model/LocationBase
    Biz/Model/Lock
    Biz/Model/RealmOwner
    Biz/Model/RealmRole
    Biz/Model/RealmUser
    Biz/Model/SummaryList
    Biz/Model/User
    Biz/Model/UserRealmList
    Biz/PropertyModel
    Biz/QueryType
    Collection/Attributes
    Collection/SingletonMap
    Delegator
    Die
    DieCode
    Ext/ApacheConstants
    Ext/DBI
    HTML
    IO/Alert
    IO/ClassLoader
    IO/Config
    IO/File
    IO/Trace
    MIME/Base64
    MIME/Type
    Mail/Address
    Mail/Common
    Mail/Message
    Mail/RFC822
    PetStore/Cookie
    PetStore/files/plain/i
    PetStore/files/view
    PetStore/Model/Cart
    PetStore/Model/CartItem
    PetStore/Model/CartItemList
    PetStore/Model/CartItemListForm
    PetStore/Model/Category
    PetStore/Model/Entity
    PetStore/Model/EntityAddress
    PetStore/Model/EntityPhone
    PetStore/Model/Inventory
    PetStore/Model/Item
    PetStore/Model/ItemForm
    PetStore/Model/ItemList
    PetStore/Model/ItemListForm
    PetStore/Model/Order
    PetStore/Model/OrderConfirmationForm
    PetStore/Model/OrderForm
    PetStore/Model/OrderStatus
    PetStore/Model/Product
    PetStore/Model/ProductList
    PetStore/Model/ProductSearchList
    PetStore/Model/ShippingAddressForm
    PetStore/Model/SimpleLoginForm
    PetStore/Model/Supplier
    PetStore/Model/UserAccount
    PetStore/Model/UserAccountForm
    PetStore/SimpleLogout
    PetStore/TaskId
    PetStore/Type/CardType
    PetStore/Type/Category
    PetStore/Type/CreditCard
    PetStore/Type/CreditCardMonth
    PetStore/Type/CreditCardYear
    PetStore/Type/EntityLocation
    PetStore/Type/ItemStatus
    PetStore/Type/OrderStatus
    PetStore/Type/Price
    PetStore/Type/StockStatus
    PetStore/Type/SupplierStatus
    PetStore/Type/UserStatus
    PetStore/Type/UserType
    PetStore/TypeError
    PetStore/UI/CreditCardExpiration
    PetStore/UI/Facade/PetStore
    PetStore/UI/FacadeChildType
    PetStore/UI/FormErrors
    PetStore/UI/Search
    PetStore/UI/ViewShortcuts
    PetStore/UserRedirect
    SQL/Connection
    SQL/Constraint
    SQL/FormSupport
    SQL/ListQuery
    SQL/ListSupport
    SQL/PropertySupport
    SQL/Support
    Type
    Type/Amount
    Type/Array
    Type/Boolean
    Type/CancelButton
    Type/Country
    Type/Date
    Type/DateInterval
    Type/DateTime
    Type/Email
    Type/Enum
    Type/EnumSet
    Type/FileName
    Type/FormButton
    Type/Gender
    Type/Honorific
    Type/Integer
    Type/Line
    Type/Location
    Type/LoginCookie
    Type/Name
    Type/Number
    Type/OKButton
    Type/PageSize
    Type/Password
    Type/Phone
    Type/PrimaryId
    Type/RealmName
    Type/String
    Type/Text
    Type/TextArea
    Type/UserAgent
    Type/UserState
    TypeError
    TypeValue
    UI/Align
    UI/Color
    UI/DateTimeMode
    UI/Facade
    UI/FacadeChildType
    UI/FacadeComponent
    UI/Font
    UI/HTML
    UI/HTML/FormErrors
    UI/HTML/Format
    UI/HTML/Format/Amount
    UI/HTML/Format/Date
    UI/HTML/Format/DateTime
    UI/HTML/Format/Link
    UI/HTML/ViewShortcuts
    UI/HTML/Widget/AmountCell
    UI/HTML/Widget/Checkbox
    UI/HTML/Widget/ClearDot
    UI/HTML/Widget/DateField
    UI/HTML/Widget/DateTime
    UI/HTML/Widget/Enum
    UI/HTML/Widget/Form
    UI/HTML/Widget/FormButton
    UI/HTML/Widget/FormFieldError
    UI/HTML/Widget/Grid
    UI/HTML/Widget/Icon
    UI/HTML/Widget/Image
    UI/HTML/Widget/ImageFormButton
    UI/HTML/Widget/JavaScript
    UI/HTML/Widget/LineCell
    UI/HTML/Widget/Link
    UI/HTML/Widget/MailTo
    UI/HTML/Widget/Page
    UI/HTML/Widget/Radio
    UI/HTML/Widget/RadioGrid
    UI/HTML/Widget/Search
    UI/HTML/Widget/Select
    UI/HTML/Widget/String
    UI/HTML/Widget/Table
    UI/HTML/Widget/TableSummaryCell
    UI/HTML/Widget/Text
    UI/HTML/Widget/TextArea
    UI/HTML/Widget/TimezoneField
    UI/HTML/Widget/Title
    UI/HTML/WidgetFactory
    UI/Icon
    UI/Task
    UI/Text
    UI/View
    UI/ViewLanguage
    UI/ViewShortcuts
    UI/ViewShortcutsBase
    UI/Widget
    UI/Widget/ControlBase
    UI/Widget/Director
    UI/Widget/Join
    UNIVERSAL
)];
my($_SCRIPTS) = [qw(
)];

# _cvs_checkout()
#
# CVS checkout everything, move to proper places.
#
sub _cvs_checkout {
    my($s) = '';
    # Put scripts into current directory
    foreach my $f (@$_SCRIPTS) {
        $s .= 'cvs co -l '.$_PREFIX.$f.';mv '.$_PREFIX.$f.' .;';
    }
    system($s);
    # Put modules into "lib" subdirectory
    $s = 'cvs co -l ';
    foreach my $f (@$_MODULES) {
        $s .= _to_path($f);
    }
    $s .= ';rm -rf lib; mv perl lib';
    system($s);
    # Remove unneeded CVS directories
    system('find . -type d -name CVS|xargs rm -rf');
}

# _to_path(string f) : string
#
# Prepend $_PREFIX to I<f> and add extension ".pm" unless it's a directory.
#
sub _to_path {
    my($f) = @_;
    return $_PREFIX.$f.($f =~ m!/$! ? ' ' : '.pm ');
}

_cvs_checkout() unless -d 'lib';
WriteMakefile(
    'NAME'	   => 'Bivio-BOP',
    'VERSION' => '1.0',
    #'EXE_FILES'    => [ qw( b-release ) ],
    'PREREQ_PM'    => {
        'HTML::Parser' => 0,
        'HTTP::Request' => 0,
        'LWP::UserAgent' => 0,
    },
    #'clean'        => { FILES => 'b-release' },
    'realclean'     => { FILES => 'lib Bivio' },
    'dist'         => { COMPRESS => 'gzip -f', SUFFIX => 'gz', },
);
