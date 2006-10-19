# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleSlotDefList;
use strict;
use base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_TST) = $self->get_instance('TupleSlotType');
my($_TSN) = Bivio::Type->get_instance('TupleSlotNum');

sub field_from_num {
    my($self) = @_;
    return  $_TSN->field_name($self->get('TupleSlotDef.tuple_slot_num'));
}

sub find_row_by_num {
    return shift->find_row_by('TupleSlotDef.tuple_slot_num', shift);
}

sub find_row_by_label {
    return shift->find_row_by('TupleSlotDef.label', shift);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        parent_id => 'TupleSlotDef.tuple_def_id',
	primary_key => 'TupleSlotDef.tuple_slot_num',
	order_by => ['TupleSlotDef.tuple_slot_num'],
	other => [
	    [qw(TupleSlotDef.tuple_slot_type_id TupleSlotType.tuple_slot_type_id)],
	    @{$_TST->LIST_FIELDS},
	],
    });
}

sub validate_slot {
    my($self, $value) = @_;
    return $_TST->validate_slot($value, $self, 'TupleSlotType.');
}

1;
