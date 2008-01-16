# Copyright (c) 2000-2006 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::NumberedList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub PAGE_SIZE {
    return 10;
}

sub internal_initialize {
    return {
	version => 1,
	primary_key => [
	    {
		name => 'index',
		type => 'Integer',
		constraint => 'NOT_NULL',
	    },
	],
    };
}

sub internal_load_rows {
    my($self, $query, $where, $params, $sql_support) = @_;
    return [map(+{index => $_}, 0..($query->get('count')-1))];
}

1;
