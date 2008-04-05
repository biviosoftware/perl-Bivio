# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleUse;
use strict;
use Bivio::Base 'Model.RealmBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub create_from_label {
    my($self, $label, $tdl) = @_;
    $tdl ||= $self->new_other('TupleDefList')->load_all;
    return $self->create({
	map({
	    $_ =~ s/^TupleDef\.//;
	    $_;
	} %{$tdl->find_row_by_label($label)->get_shallow_copy},
	),
	realm_id => $self->req('auth_id'),
    });
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	table_name => 'tuple_use_t',
	columns => {
	    tuple_def_id => ['TupleDef.tuple_def_id', 'PRIMARY_KEY'],
	    realm_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
	    label => ['TupleLabel', 'NOT_NULL'],
	    moniker => ['TupleLabel', 'NOT_NULL'],
        },
    });
}

sub load_tuple_slot_def_list {
    my($self) = @_;
    # SECURITY: TupleUse can only exist if auth_realm can access TupleDef.
    return $self->new_other('TupleSlotDefList')->load_all({
	parent_id => $self->get('tuple_def_id'),
    });
}

1;
