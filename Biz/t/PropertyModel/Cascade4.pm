# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::t::PropertyModel::Cascade4;
use strict;
use Bivio::Base 'Bivio::Biz::PropertyModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	table_name => 't_cascade4_t',
	columns => {
	    k1 => ['Cascade3.k1', 'PRIMARY_KEY'],
	    k2 => ['Cascade3.k2', 'PRIMARY_KEY'],
	    k3 => ['Cascade3.k3', 'PRIMARY_KEY'],
	    k4 => ['Integer', 'PRIMARY_KEY'],
	},
    });
}

1;
