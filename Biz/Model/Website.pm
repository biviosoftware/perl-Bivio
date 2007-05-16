# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::Website;
use strict;
use Bivio::Base 'Model.LocationBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    return {
	version => 1,
	table_name => 'website_t',
	columns => {
            realm_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
            location => ['Location', 'PRIMARY_KEY'],
            url => ['HTTPURI', 'NONE'],
        },
	auth_id => 'realm_id',
    };
}

1;
