# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleDef;
use strict;
use base 'Bivio::Biz::Model::RealmBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_TL) = Bivio::Type->get_instance('TupleLabel');

sub create_from_hash {
    my($self, $defs, $tstl) = @_;
    $tstl ||= $self->new_other('TupleSlotTypeList')->load_all;
    while (my($k, $slots) = each(%$defs)) {
	my($moniker, $label) = split(m{#}, $k);
	$self->create({
	    moniker => $moniker,
	    label => $label,
	});
	my($i) = 1;
	foreach my $s (@$slots) {
	    $self->new_other('TupleSlotDef')->create({
		map(($_ => $self->get($_)), qw(realm_id tuple_def_id)),
		label => $_TL->from_literal_or_die($s->[0]),
		tuple_slot_num => $i++,
		tuple_slot_type_id => $tstl->label_to_id($s->[1]),
	    });
	}
    }
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'tuple_def_t',
	columns => {
	    tuple_def_id => ['PrimaryId', 'PRIMARY_KEY'],
	    label => ['TupleLabel', 'NOT_NULL'],
	    moniker => ['TupleLabel', 'NOT_NULL'],
        },
    });
}

1;
