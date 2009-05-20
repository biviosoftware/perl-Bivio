# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::t::ListModel::T1List;
use strict;
use Bivio::Base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    # Simple list of users.
    return {
	version => 1,
	primary_key => ['RealmOwner.realm_id'],
	can_iterate => 1,
	other => [
	    # used by WidgetFactory.bunit
	    map(+{
		name => lc($_),
		type => $_,
		constraint => 'NONE',
	    }, qw(Year Integer Amount PrimaryId Percent)),
	],
	order_by => [
	    'RealmOwner.name',
        ],
    };
}

sub internal_pre_load {
    my($self, undef, undef, $params) = @_;
    push(@$params, 3);
    return 'realm_id = ?';
}

1;
