# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleSlotChoiceList;
use strict;
use base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub EMPTY_KEY_VALUE {
    return -1;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	primary_key => [{
	    name => 'key',
	    type => 'Integer',
	    constraint => 'NOT_NULL',
	}],
	order_by => [{
	    name => 'choice',
	    type => 'TupleSlot',
	    constraint => 'NOT_NULL',
	}],
    });
}

sub internal_load_rows {
    my($self) = @_;
    my($k) = 1;
    return [map(+{
	choice => $_,
	key => $k++,
    }, sort(@{$self->[$_IDI]}))];
}

sub load_all_from_slot_type {
    my($self, $list) = @_;
    $self->[$_IDI] = $list ? _list($list) : [];
    return $self->load_all;
}

sub _list {
    my($list) = @_;
    my($tc) = Bivio::Type
	->get_instance($list->get('TupleSlotType.type_class'));
    my($c) = $list->get('TupleSlotType.choices');
    return [map(
	$tc->to_literal($_),
	sort {
	    $tc->compare($a, $b)
	} @{$c ? $c->as_array : []},
    )];
}

1;
