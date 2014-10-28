# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleTag;
use strict;
use Bivio::Base 'Model.RealmBase';

my($_TSN) = b_use('Type.TupleSlotNum');

sub LIST_FIELDS {
    return $_TSN->map_list(sub {'Tuple.' . shift(@_)});
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'tuple_tag_t',
	columns => {
	    tuple_def_id => ['TupleUse.tuple_def_id', 'PRIMARY_KEY'],
	    primary_id => ['PrimaryId', 'PRIMARY_KEY'],
	    @{$_TSN->map_list(sub {shift(@_) => ['TupleSlot', 'NONE']})},
        },
    });
}

1;
