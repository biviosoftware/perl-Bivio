# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleSlotChoiceList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_TST) = __PACKAGE__->use('Type.TupleSlotType');

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
    my($self, $source) = @_;
    $self->[$_IDI] = $source ? _list($source) : [];
    return $self->load_all;
}

sub _list {
    my($source) = @_;
    my($c, $tc);
    if ($_TST->is_blessed($source)) {
	($c, $tc) = map($source->get($_), qw(choices class));
    }
    else {
	$tc = Bivio::Type->get_instance(
	    $source->get('TupleSlotType.type_class'));
	$c = $source->get('TupleSlotType.choices');
    }
    return [map(
	$tc->to_literal($_),
	sort {
	    $tc->compare($a, $b)
	} @{$c->as_array},
    )];
}

1;
