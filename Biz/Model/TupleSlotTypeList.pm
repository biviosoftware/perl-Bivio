# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleSlotTypeList;
use strict;
use base 'Bivio::Biz::Model::AscendingAuthList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_TST) = __PACKAGE__->get_instance('TupleSlotType');

sub AUTH_ID_FIELD {
    return 'TupleSlotType.realm_id';
}

sub find_row_by_label {
    return shift->find_row_by('TupleSlotType.label', shift);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	primary_key => ['TupleSlotType.tuple_slot_type_id'],
        order_by => [qw(
	    TupleSlotType.label
	)],
	other => $_TST->LIST_FIELDS,
    });
}

sub label_to_id {
    my($self, $label) = @_;
    return ($self->find_row_by_label($label)
       || $self->die($label, ': no such tuple slot type')
    )->get('TupleSlotType.tuple_slot_type_id');
}

1;
