# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleDefListForm;
use strict;
use base 'Bivio::Biz::Model::TupleExpandableListForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_TSN) = Bivio::Type->get_instance('TupleSlotNum');
my($_IDI) = __PACKAGE__->instance_data_index;

sub MUST_BE_SPECIFIED_FIELDS {
    return [qw(
	TupleSlotDef.label
	TupleSlotDef.tuple_slot_type_id
	TupleSlotDef.is_required
    )];
}

sub PARENT_LIST {
    return 'TupleDefList';
}

sub execute_empty_start {
    my($self) = @_;
    my($req) = $self->get_request;
    if (my $m = $req->unsafe_get('Model.TupleDef')) {
	$self->load_from_model_properties($m);
    }
    return;
}

sub execute_ok_end {
    my($self) = @_;
    $self->internal_put_error('TupleSlotDef.label_0' => 'NOT_FOUND')
	unless $self->[$_IDI] > $_TSN->get_min;
    return;
}

sub execute_ok_row {
    my($self) = @_;
    return if $self->is_empty_row || $self->in_error;
    return _err($self, tuple_slot_type_id => 'NOT_FOUND')
	unless $self->get_request->get('Model.TupleSlotTypeList')
	->find_row_by_id($self->get('TupleSlotDef.tuple_slot_type_id'));
    $self->internal_put_field(
	'TupleSlotDef.tuple_slot_num' => $self->[$_IDI]++);
    $self->new_other('TupleSlotDef')
	->create($self->get_model_properties('TupleSlotDef'));
    return;
}

sub execute_ok_start {
    my($self) = @_;
    if (my $o = $self->get_request->unsafe_get('Model.TupleDef')) {
#TODO: Handle updates more gracefully.  As long as there aren't any uses,
#      you can update.	
	$self->new_other('TupleSlotDef')->delete_all({
	    tuple_def_id => $o->get('tuple_def_id'),
	});
	$o->delete;
    }
#TODO: Unique for whole TupleDefList
    $self->internal_put_field(
	'TupleSlotDef.tuple_def_id' => $self->new_other('TupleDef')
	    ->create($self->get_model_properties('TupleDef'))
	    ->get('tuple_def_id'),
    );
    $self->[$_IDI] = $_TSN->get_min;
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	list_class => 'TupleSlotDefList',
	visible => [
	    'TupleDef.label',
	    'TupleDef.moniker',
	    map({name => $_, in_list => 1}, @{$self->MUST_BE_SPECIFIED_FIELDS}),
	],
	other => [
	    'TupleSlotDef.tuple_def_id',
	    {
		name => 'TupleSlotDef.tuple_slot_num',
		type => 'Integer',
		in_list => 1,
	    },
	],
    });
}

sub internal_initialize_list {
    my($self) = shift;
    $self->new_other('TupleSlotTypeList')->load_all;
    return $self->SUPER::internal_initialize_list(@_);
}

sub internal_initialize_this_list {
    my($self, $parent_list, $this_list) = @_;
    $this_list->load_all({
	parent_id => $parent_list->get_model('TupleDef')->get('tuple_def_id'),
    });
    return;
}

sub _err {
    my($self, $field, $err) = @_;
    $self->internal_put_error("TupleSlotDef.$field" => $err);
    return;
}

1;
