# Copyright (c) 1999 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::Phone;
use strict;
use Bivio::Base 'Model.LocationBase';


sub internal_initialize {
    return {
        version => 1,
        table_name => 'phone_t',
        columns => {
            realm_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
            location => ['Location', 'PRIMARY_KEY'],
            phone => ['Phone', 'NONE'],
        },
        auth_id => 'realm_id',
    };
}

1;
