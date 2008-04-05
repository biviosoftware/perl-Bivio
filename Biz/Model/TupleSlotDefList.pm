# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleSlotDefList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_EK) = __PACKAGE__->use('Model.TupleSlotChoiceSelectList')->EMPTY_KEY_VALUE;
my($_TSD) = __PACKAGE__->use('Model.TupleSlotDef');
my($_TSN) = __PACKAGE__->use('Type.TupleSlotNum');
my($_TST) = __PACKAGE__->use('Model.TupleSlotType');
my($_TTST) = __PACKAGE__->use('Type.TupleSlotType');
my($_NOT_NULL) = __PACKAGE__->use('SQL.Constraint')->NOT_NULL;
my($_NONE) = $_NOT_NULL->NONE;
my($_MISSING) = {
    type => $_TTST->new(
	$_TTST->DEFAULT_CLASS,
	__PACKAGE__->use('Type.TupleSlotArray')->new([]),
    ),
    constraint => $_NONE,
};

sub EMPTY_KEY_VALUE {
    #NOTE: You have to relax constraint on tuple_slot_num if you use this
    return -1;
}

sub MISSING_SLOT_INFO {
    return $_MISSING;
}

sub field_from_num {
    my($self) = @_;
    return $_TSN->field_name($self->get('TupleSlotDef.tuple_slot_num'));
}

sub find_row_by_field_name {
    my($self, $field) = @_;
    return $self->find_row_by_num($_TSN->field_name_to_num($field));
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
	    {
		name => 'tuple_slot_info',
		type => 'Hash',
		constraint => $_NONE,
	    },
	],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    $row->{tuple_slot_info} = {
	type => $_TTST->new(
	    $row->{'TupleSlotType.type_class'},
	    $row->{'TupleSlotType.choices'},
	),
	constraint => $row->{'TupleSlotDef.is_required'} ? $_NOT_NULL : $_NONE,
    };
    return 1;
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
