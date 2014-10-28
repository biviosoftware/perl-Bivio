# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::DefaultBConf;
use strict;
use base 'Bivio::BConf';


sub merge_overrides {
    my($proto) = @_;
    return Bivio::IO::Config->merge_list(
	{
	    $proto->merge_class_loader({
		delegates => {
		    'Bivio::Agent::TaskId' => 'Bivio::Delegate::DefaultTaskId',
		    'Bivio::Auth::Support' => 'Bivio::Delegate::NoDbAuthSupport',
		},
		maps => {
		    Facade => ['Bivio::UI::Facade'],
		},
	    }),
	    $proto->merge_http_log,
	    'Bivio::Ext::DBI' => {
		database => 'none',
		user => 'none',
		password => 'none',
		connection => 'Bivio::SQL::Connection::None',
	    },
	    'Bivio::UI::Facade' => {
		default => 'Default',
		http_host => 'default.bivio.biz',
		mail_host => 'default.bivio.biz',
	    },
	},
	$proto->default_merge_overrides({
	    version => $proto->CURRENT_VERSION,
	    root => 'Bivio',
	    prefix => 'b',
	    owner => 'bivio Software, Inc.',
	}),
	shift->SUPER::merge_overrides(@_),
    );
}

1;
