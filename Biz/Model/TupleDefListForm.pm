# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleDefListForm;
use strict;
use Bivio::Base 'Model.TupleExpandableListForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_TSN) = b_use('Type.TupleSlotNum');

sub MUST_BE_SPECIFIED_FIELDS {
    return [qw(
	TupleSlotDef.label
	TupleSlotDef.tuple_slot_type_id
    )];
}

sub PARENT_LIST {
    return 'TupleDefList';
}

sub execute_empty_start {
    my($self) = @_;
    $self->load_from_model_properties($self->req('Model.TupleDef'))
	if $self->req->unsafe_get('Model.TupleDef');
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
    $self->internal_put_field(
	 'TupleSlotDef.tuple_slot_num' => $self->[$_IDI]++);

    if (_is_new_row($self)) {
	$self->new_other('TupleSlotDef')
	    ->create($self->get_model_properties('TupleSlotDef'));

	if ($self->get('TupleSlotDef.is_required')
	    && _is_editing($self)) {
 	    _iterate_tuples($self, sub {
	        my($t) = @_;
		$t->update({
		    _slot_field($self) => _slot_type($self)
		        ->get('default_value'),
		});
		return 1;
	    });
	}
    }
    else {

	if (_has_type_changed($self)) {
	    my($type) = _slot_type($self);
	    _iterate_tuples($self, sub {
	        my($t) = @_;
		my($v, $e) = $type->validate_slot($t->get(_slot_field($self)));
		Bivio::Die->die('invalid slot value: ', $e->get_name)
		    if $e;
		$t->update({
		    _slot_field($self) => $v,
		});
		return 1;
	    });
	}
	$self->get_list_model->get_model('TupleSlotDef')
	    ->update($self->get_model_properties('TupleSlotDef'));
    }
    return;
}

sub execute_ok_start {
    my($self) = @_;
    $self->[$_IDI] = $_TSN->get_min;
    my($is_editing) = _is_editing($self);
    $self->new_other('TupleDef')->create(
	$self->get_model_properties('TupleDef'))
	unless $is_editing;
    $self->internal_put_field('TupleSlotDef.tuple_def_id' =>
	$self->req(qw(Model.TupleDef tuple_def_id)));
    $self->req('Model.TupleDef')->delete_from_request
	unless $is_editing;
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
	    map({name => $_, in_list => 1},
		@{$self->MUST_BE_SPECIFIED_FIELDS},
		'TupleSlotDef.is_required',
	    ),
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

sub internal_initialize_this_list {
    my($self, $parent_list, $this_list) = @_;
    $this_list->load_all({
	parent_id => $parent_list->get_model('TupleDef')->get('tuple_def_id'),
    });
    return;
}

sub validate_row {
    my($self) = @_;
    shift->SUPER::validate_row(@_);
    return unless $self->get('TupleSlotDef.tuple_slot_type_id');

    if (_is_new_row($self)) {
	# if required, make sure type has default if has existing rows
	return unless _is_editing($self)
	    && $self->get('TupleSlotDef.is_required')
	    && $self->req('Model.TupleDefList')->get('use_count');

	_err($self, tuple_slot_type_id => 'EXISTS')
	    unless defined(_slot_type($self)->get('default_value'));
    }
    else {
	_err($self, label => 'UNSPECIFIED')
	    unless $self->get('TupleSlotDef.label');

	if (_has_type_changed($self)) {
	    # if type changes, ensure existing values parse OK
	    my($type) = _slot_type($self);
	    _iterate_tuples($self, sub {
	        my($t) = @_;
		return 1 unless ($type->validate_slot(
		    $t->get(_slot_field($self))))[1];
		_err($self, tuple_slot_type_id => 'SYNTAX_ERROR');
		return 0;
	    });
	}
    }
    return;
}

sub _err {
    my($self, $field, $err) = @_;
    $self->internal_put_error("TupleSlotDef.$field" => $err);
    return;
}

sub _has_type_changed {
    my($self) = @_;
    return ($self->get('TupleSlotDef.tuple_slot_type_id') || '')
	eq $self->get_list_model->get('TupleSlotDef.tuple_slot_type_id')
	    ? 0 : 1;
}

sub _is_editing {
    my($self) = @_;
    return $self->req->unsafe_get('Model.TupleDef') ? 1 : 0;
}

sub _is_new_row {
    my($self) = @_;
    return $self->get_list_model->get('TupleSlotDef.tuple_slot_num')
	eq $self->get_list_model->EMPTY_KEY_VALUE ? 1 : 0;
}

sub _iterate_tuples {
    my($self, $op) = @_;

    foreach my $m (qw(Tuple TupleTag)) {
	$self->new_other($m)->do_iterate($op);
    }
    return;
}

sub _slot_field {
    my($self) = @_;
    return $_TSN->field_name($self->get('TupleSlotDef.tuple_slot_num'));
}

sub _slot_type {
    my($self) = @_;
    return $self->req('Model.TupleSlotTypeList')
	->find_row_by_id($self->get('TupleSlotDef.tuple_slot_type_id'))
	    ->get_model('TupleSlotType');
}

1;
