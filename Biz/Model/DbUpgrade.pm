# Copyright (c) 1999-2019 Bivio Software, Inc.  All rights reserved.
package Bivio::Biz::Model::DbUpgrade;
use strict;

use Bivio::Base 'Biz.PropertyModel';

sub internal_initialize {
    return {
	version => 1,
	table_name => 'db_upgrade_t',
	columns => {
	    # Which version, can be anything, but must be unique
            version => ['Name', 'PRIMARY_KEY'],
	    # When did the upgrade run?
	    run_date_time => ['DateTime', 'NOT_NULL'],
        },
    };
}

1;
