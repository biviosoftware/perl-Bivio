# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::SQL::t::Support::T1Form;
use strict;
use Bivio::Base 'Biz.FormModel';


sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
	    'Address_1.city',
	    {
		name => 'Address_1.state',
		constraining_field => 'User.first_name',
	    },
	    'User.last_name',
	],
	hidden => [
	    [
		{
		    name => 'RealmOwner.realm_id',
		    constraint => 'NONE',
		},
		'Address_1.realm_id',
		'RealmUser.realm_id',
	    ],
	],
    });
}

1;
