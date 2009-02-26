# Copyright (c) 2001-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::BConf;
use strict;
use base 'Bivio::BConf';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub dev_overrides {
    my($proto, $pwd, $host) = @_;
    return {
	'Bivio::UI::HTML::Widget::SourceCode' => {
	    source_dir => "$pwd/src",
	},
    };
}

sub merge_overrides {
    my($proto) = @_;
    return Bivio::IO::Config->merge_list({
	'Bivio::Biz::Model::UserCreateForm' => {
	    unapproved_applicant_mode => 1,
	},
	'Bivio::Ext::DBI' => {
	    database => 'pet',
	    user => 'petuser',
	    password => 'petpass',
	    connection => 'Bivio::SQL::Connection::Postgres',
	},
	$proto->merge_class_loader({
	    delegates => {
		'Bivio::Agent::TaskId' => 'Bivio::PetShop::Delegate::TaskId',
		'Bivio::Agent::HTTP::Cookie' => 'Bivio::Delegate::Cookie',
		'Bivio::Auth::RealmType'
		    => 'Bivio::PetShop::Delegate::RealmType',
		'Bivio::Auth::Support' => 'Bivio::Delegate::SimpleAuthSupport',
		'Bivio::Auth::Permission'
		    => 'Bivio::PetShop::Delegate::Permission',
		'Bivio::Auth::Role' => 'Bivio::PetShop::Delegate::Role',
		'Bivio::Type::ECService'
		    => 'Bivio::PetShop::Delegate::ECService',
		'Bivio::Type::Location'
		    => 'Bivio::PetShop::Delegate::Location',
		'Bivio::TypeError' => 'Bivio::PetShop::Delegate::TypeError',
		'Bivio::UI::HTML::FormErrors'
		    => 'Bivio::PetShop::Delegate::FormErrors',
	    },
	    maps => {
		Action => ['Bivio::PetShop::Action'],
		Delegate => ['Bivio::PetShop::Delegate'],
		Facade => ['Bivio::PetShop::Facade'],
		HTMLWidget => ['Bivio::PetShop::Widget'],
		Model => ['Bivio::PetShop::Model'],
		ShellUtil => ['Bivio::PetShop::Util'],
		TestLanguage => ['Bivio::PetShop::Test'],
		Type => ['Bivio::PetShop::Type'],
		View => ['Bivio::PetShop::View'],
	    },
	}),
	'Bivio::Test::HTMLParser::Forms' => {
	    error_color => '#993300',
	},
	'Bivio::SQL::PropertySupport' => {
	    unused_classes => [],
	},
	'Bivio::UI::Facade' => {
	    default => 'PetShop',
	    http_suffix => 'bivio.biz',
	    mail_host => 'bivio.biz',
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
			'+MEMBER',
			[[qw(site site-help site-contact)] => [qw(ADMINISTRATOR)]],
		    ],
		],
		realm_user_util1 => [
		    MEMBER => [
			[realm_user_util2 => [qw(MEMBER MAIL_RECIPIENT)]],
		    ],
		    ADMINISTRATOR => [
			'+MEMBER',
			[realm_user_util2 => [qw(ADMINISTRATOR FILE_WRITER)]],
			[realm_user_util3 => [qw(MEMBER MAIL_RECIPIENT ADMINISTRATOR FILE_WRITER)]],
		    ],
		],
	    ],
	},
    },
    $proto->default_merge_overrides({
	version => 9,
	root => 'Bivio/PetShop',
	prefix => 'pet',
	owner => 'bivio Software, Inc.',
    }));
}

1;
