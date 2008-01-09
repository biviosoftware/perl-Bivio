# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::SQL::t::Support::T1Form;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
	    'Address_1.city',
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
