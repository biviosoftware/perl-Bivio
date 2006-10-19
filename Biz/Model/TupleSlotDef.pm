# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleSlotDef;
use strict;
use base 'Bivio::Biz::Model::RealmBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_TL) = Bivio::Type->get_instance('TupleLabel');

sub create_from_array {
    my($self, $tuple_def, $slots) = @_;
    my($tsn) = 1;
    my($tstl) = $self->new_other('TupleSlotTypeList')->load_all;
    foreach my $s (@$slots) {
	$self->create({
	    tuple_slot_num => $tsn++,
	    tuple_def_id => $tuple_def->get('tuple_def_id'),
	    realm_id => $tuple_def->get('realm_id'),
	    label => $_TL->from_literal_or_die($s->[0]),
	    tuple_slot_type_id => $tstl->find_row_by_label($s->[1])->get('tuple_slot_type_id'),
	});
    }
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'tuple_slot_def_t',
	columns => {
	    tuple_def_id => ['Tuple.tuple_def_id', 'PRIMARY_KEY'],
	    tuple_slot_num => ['TupleSlotNum', 'PRIMARY_KEY'],
	    label => ['TupleLabel', 'NOT_NULL'],
	    tuple_slot_type_id => ['TupleSlotType.tuple_slot_type_id', 'NOT_NULL'],
        },
    });
}

1;
