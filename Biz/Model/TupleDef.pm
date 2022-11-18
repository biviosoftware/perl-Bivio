# Copyright (c) 2006-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleDef;
use strict;
use Bivio::Base 'Model.RealmBase';


sub create_from_hash {
    my($self, $defs) = @_;
    while (my($k, $slots) = each(%$defs)) {
        my($moniker, $label) = split(m{#}, $k);
        $self->create({
            moniker => $moniker,
            label => $label,
        });
        $self->new_other('TupleSlotDef')->create_from_array($self, $slots),
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
            moniker => ['TupleMoniker', 'NOT_NULL'],
        },
    });
}

1;
