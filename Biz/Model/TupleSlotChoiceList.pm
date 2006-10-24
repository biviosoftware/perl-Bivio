# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleSlotChoiceList;
use strict;
use base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub EMPTY_KEY_VALUE {
    return ' ';
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	primary_key => [{
	    name => 'value',
	    type => 'TupleSlot',
	    constraint => 'NOT_NULL',
	}],
    });
}

sub internal_load_rows {
    my($self) = @_;
    return [map(+{
	value => $_,
    }, sort(@{$self->[$_IDI]}))];
}

sub load_all_from_slot_type {
    my($self, $list) = @_;
    my($tc) = Bivio::Type->get_instance($list->get('TupleSlotType.type_class'));
    $self->[$_IDI] = [sort {
	$tc->compare($a, $b)
    } @{$list->get('TupleSlotType.choices')->as_array}];
    return $self->load_all;
}

1;
