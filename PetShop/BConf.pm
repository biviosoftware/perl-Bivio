# Copyright (c) 2001-2013 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::BConf;
use strict;
use base 'Bivio::BConf';


sub merge_overrides {
    my($proto) = @_;
    return Bivio::IO::Config->merge_list({
	'Bivio::Biz::Action::ClientRedirect' => {
	    permanent_map => {
		'/permanent-redirect' => '/pub/products',
	    },
	},
	'Bivio::Biz::Model::UserCreateForm' => {
	    unapproved_applicant_mode => 1,
	},
	'Bivio::Biz::Model::MailReceiveDispatchForm' => {
	    filter_spam => 1,
	},
	'Bivio::Ext::DBI' => {
	    database => 'pet',
	    user => 'petuser',
	    password => 'petpass',
	    connection => 'Bivio::SQL::Connection::Postgres',
	},
	$proto->merge_class_loader({
	    delegates => [
		'Bivio::Agent::TaskId',
		'Bivio::Auth::RealmType',
		'Bivio::Auth::Support',
		'Bivio::Auth::Permission',
		'Bivio::Auth::Role',
		'Bivio::Type::ECService',
		'Bivio::Type::Location',
		'Bivio::TypeError',
	    ],
	    maps => {
		Action => ['Bivio::PetShop::Action'],
		Delegate => ['Bivio::PetShop::Delegate'],
		Facade => ['Bivio::PetShop::Facade'],
		PetShopWidget => ['Bivio::PetShop::Widget', 'Bivio::UI::XHTML::Widget', 'Bivio::UI::HTML::Widget', 'Bivio::UI::Widget'],
		Model => ['Bivio::PetShop::Model'],
		ShellUtil => ['Bivio::PetShop::Util'],
		TestLanguage => ['Bivio::PetShop::Test'],
		Type => ['Bivio::PetShop::Type'],
		Util => ['Bivio::PetShop::Util'],
		View => ['Bivio::PetShop::View'],
		UICSS => ['Bivio::PetShop::UICSS'],
	    },
	}),
	'Bivio::Test::HTMLParser::Forms' => {
	    error_color => '#993300',
	},
	'Bivio::UI::Facade' => {
	    default => 'PetShop',
	    http_host => 'bivio.biz',
	    mail_host => 'bivio.biz',
	    is_html5 => 1,
	},
	'Bivio::UI::View::ThreePartPage' => {
	    center_replaces_middle => 1,
	},
	'Bivio::Util::RealmUser' => {
	    audit_map => [
		'site-admin' => [
		    USER => [
		    ],
		    MEMBER => [
			[[qw(site site-help site-contact)] => [qw(MEMBER MAIL_RECIPIENT FILE_WRITER)]],
		    ],
		    ADMINISTRATOR => [
			[[qw(site site-help site-contact)] => [qw(MAIL_RECIPIENT FILE_WRITER ADMINISTRATOR)]],
		    ],
		],
		realm_user_util1 => [
		    MEMBER => [
			[realm_user_util2 => [qw(MEMBER MAIL_RECIPIENT)]],
		    ],
		    ADMINISTRATOR => [
			[realm_user_util2 => [qw(MAIL_RECIPIENT ADMINISTRATOR FILE_WRITER)]],
			[realm_user_util3 => [qw(MAIL_RECIPIENT ADMINISTRATOR FILE_WRITER)]],
			['realm_user_util4 EXPLICIT' => 'GUEST'],
		    ],
		],
		realm_user_util5 => [
		    MEMBER => [
			[FORUM => [qw(WITHDRAWN)]],
		    ],
		],
	    ],
	},
    },
    $proto->default_merge_overrides({
	version => 10,
	root => 'Bivio/PetShop',
	prefix => 'pet',
	owner => 'bivio Software, Inc.',
    }));
}

1;
