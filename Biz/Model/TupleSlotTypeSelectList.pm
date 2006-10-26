# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleSlotTypeSelectList;
use strict;
use base 'Bivio::Biz::Model::TupleSlotTypeList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_load_rows {
    my($self) = shift;
    return [
	{
	    map(($_ => undef), @{$self->get_info('column_names')}),
	    'TupleSlotType.label' => 'Select Type',
	    'TupleSlotType.tuple_slot_type_id' => $self->EMPTY_KEY_VALUE,
	},
	@{$self->SUPER::internal_load_rows(@_)},
    ];
}

1;
