# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::t::ListModel::T2List;
use strict;
use Bivio::Base 'Bivio::Biz::t::ListModel::T1List';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    # Simple list of users.
    return {
	version => 1,
	primary_key => ['RealmOwner.realm_id'],
	can_iterate => 1,
	order_by => [
	    'RealmOwner.name',
        ],
    };
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    $stmt->where(['RealmOwner.realm_id', [3]]);
}

1;
