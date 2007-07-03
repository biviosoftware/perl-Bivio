# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleSlotDefList;
use strict;
use base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_TST) = __PACKAGE__->get_instance('TupleSlotType');
my($_TSD) = __PACKAGE__->get_instance('TupleSlotDef');
my($_TSN) = Bivio::Type->get_instance('TupleSlotNum');
my($_EK) = __PACKAGE__->get_instance('TupleSlotChoiceSelectList')
    ->EMPTY_KEY_VALUE;

sub EMPTY_KEY_VALUE {
    #NOTE: You have to relax constraint on tuple_slot_num if you use this
    return -1;
}

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
        parent_id => ['TupleSlotDef.tuple_def_id'],
	primary_key => ['TupleSlotDef.tuple_slot_num'],
	order_by => ['TupleSlotDef.tuple_slot_num'],
	other => [
	    [qw(TupleSlotDef.tuple_slot_type_id TupleSlotType.tuple_slot_type_id)],
	    @{$_TSD->LIST_FIELDS},
	],
    });
}

sub type_class_instance {
    my($self) = @_;
    return $_TST->type_class_instance($self, 'TupleSlotType.');
}

sub validate_slot {
    my($self, $value) = @_;
    $value = undef
	if $value && $self->get('TupleSlotType.choices')->is_specified
	&& $value eq $_EK;
    my($v, $e)
	= $_TST->validate_slot($value, $self, 'TupleSlotType.');
    return $e ? ($v, $e)
	: defined($v)
	|| !$self->get('TupleSlotDef.is_required')
	? ($v, undef)
	: (undef, Bivio::TypeError->NULL);
}

1;
