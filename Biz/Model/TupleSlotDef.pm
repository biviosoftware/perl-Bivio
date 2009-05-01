# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleSlotDef;
use strict;
use base 'Bivio::Biz::Model::RealmBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_TST) = __PACKAGE__->get_instance('TupleSlotType');

sub LIST_FIELDS {
    return [map(
	"TupleSlotDef.$_", qw(label is_required)),
	@{$_TST->LIST_FIELDS},
    ];
}

sub create_from_array {
    my($self, $tuple_def, $slots, $tstl) = @_;
    my($tsn) = 1;
    $tstl ||= $self->new_other('TupleSlotTypeList')->load_all;
    my($n) = 1;
    foreach my $s (@$slots) {
	$self->die($s->{type}, ': no such type')
	    unless $tstl->find_row_by_label($s->{type});
	$self->create({
	    tuple_slot_num => $n++,
	    tuple_def_id => $tuple_def->get('tuple_def_id'),
	    realm_id => $tuple_def->get('realm_id'),
	    tuple_slot_type_id => $tstl->get('TupleSlotType.tuple_slot_type_id'),
	    map(($_ =>
	        $self->get_field_type($_)->from_literal_or_die($s->{$_})),
		qw(label is_required)),
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
	    label => ['TupleSlotLabel', 'NOT_NULL'],
	    tuple_slot_type_id => ['TupleSlotType.tuple_slot_type_id', 'NOT_NULL'],
	    is_required => ['Boolean', 'NOT_NULL'],
        },
    });
}

1;
