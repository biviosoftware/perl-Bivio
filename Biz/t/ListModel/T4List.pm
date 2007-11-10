# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::t::ListModel::T4List;
use strict;
use Bivio::Base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    return {
	version => 1,
	primary_key => ['RealmOwner.realm_id'],
	order_by => [
	    'RealmOwner.name',
        ],
    };
}

sub internal_load {
    my($self, $rows, $query) = @_;
    my(@res) = shift->SUPER::internal_load(@_);
    @$rows = splice(@$rows, 0, 1);
    return @res;
}

sub internal_post_load_row {
    return 1;
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    $stmt->where($stmt->IN('RealmOwner.realm_id', [1 .. 3]));
    return;
}

1;
