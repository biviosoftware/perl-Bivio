# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::t::PropertyModel::Cascade1;
use strict;
use Bivio::Base 'Bivio::Biz::PropertyModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	table_name => 't_cascade1_t',
        cascade_delete_children => 1,
	columns => {
	    k1 => ['Integer', 'PRIMARY_KEY'],
	},
    });
}

1;
