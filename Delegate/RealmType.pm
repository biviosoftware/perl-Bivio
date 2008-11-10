# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Delegate::RealmType;
use strict;
use Bivio::Base 'Bivio.Delegate';

# C<Bivio::Delegate::RealmType> implements the common RealmTypes in bOP.
#
# You should extend this class if you have new RealmTypes in your application.
# The numbers 0-19 are reserved by this module so your first RealmType would
# look like:
#
#     sub get_delegate_info {
# 	my($proto) = @_;
# 	return [
#             @{$proto->SUPER::get_delegate_info},
# 	    MY_NEW_TYPE => [
# 	        20,
# 		undef,
# 		'access to some new type of realm',
# 	    ],
#         ];
#     }

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_delegate_info {
    return [
	ANY_GROUP => 0,
	GENERAL => 1,
	USER => 2,
	CLUB => 3,
	FORUM => 4,
	CALENDAR_EVENT=> 5,
    ];
}

1;
