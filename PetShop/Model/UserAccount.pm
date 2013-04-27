# Copyright (c) 2001-2013 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::UserAccount;
use strict;
use Bivio::Base 'Biz.PropertyModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    return {
	version => 1,
	table_name => 'user_account_t',
	columns => {
            user_id => ['User.user_id', 'PRIMARY_KEY'],
	    status => ['UserStatus', 'NOT_NULL'],
	    user_type => ['UserType', 'NOT_NULL'],
	},
	auth_id => 'user_id',
    };
}

1;
