# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleTagForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FS) = __PACKAGE__->use('SQL.FormSupport');
my($_TSN) = __PACKAGE__->use('Type.TupleSlotNum');
my($_TST) = __PACKAGE__->use('Type.TupleSlotType');
my($_MISSING) = __PACKAGE__->use('Model.TupleSlotDefList')->MISSING_SLOT_INFO;
my($_IDI) = __PACKAGE__->instance_data_index;

sub execute_empty {
    my(undef, $delegator) = shift->delegated_args(@_);
    _setup(
	$delegator,
	sub {
	    my($model) = @_;
	    return 0
		unless $delegator->unsafe_get_model($model)->is_loaded;
	    $delegator->load_from_model_properties($model);
	    return 1;
	},
	sub {
	    my($model) = @_;
	    $_TSN->map_list(sub {
	        my($field) = "$model." . shift;
		return unless my $d = _defs($delegator, $field);
		$delegator->internal_put_field(
		    $field => $d->get('TupleSlotType.default_value'));
		return;
	    });
	},
    );
    return;
}

sub execute_ok {
    my(undef, $delegator) = shift->delegated_args(@_);
    _setup($delegator, sub {
	$delegator->create_or_update_model_properties(shift);
	return 1;
    });
    return;
}

sub get_field_info {
    my($delegation, $delegator, $field, $which) = shift->delegated_args(@_);
    my($info) = $delegation->call_delegator_super(get_field_info => [$field]);
    if ($info->{type}->isa($_TST)) {
	my($d) = _defs($delegator, $info->{name});
	$info = {
	    %$info,
	    %{$d ? $d->get('tuple_slot_info') : $_MISSING},
	};
    }
    return $info
	unless $which;
    Bivio::Die->die($info->{name}, '.', $which, ': no such attribute')
	unless exists($info->{$which});
    return $info->{$which};
}

sub internal_initialize {
    my($delegation, $delegator, $info) = shift->delegated_args(@_);
    return $delegator->merge_initialize_info(
	{
	    visible => _fields($delegator, sub {
		my($field, $id) = @_;
		return {
		    name => $field,
		    type => $_TST,
		    $_FS->extract_column_from_classes($info, $id)->{in_list}
			? (in_list => 1) : (),
		};
	    }),
	    other => _ids($delegator, sub {
	        my($id, $model) = @_;
		return ("$model.primary_id", "$model.tuple_def_id");
	    }),
	},
	$info || $delegator->merge_initialize_info(
	    $delegation->call_delegator_super(internal_initialize => []),
	    {version => 1},
	),
   );
}

sub tuple_tag_find_slot_type {
    my(undef, $delegator, $model_label) = shift->delegated_args(@_);
    return $delegator->get_field_type(
	_find_model_label($delegator, $model_label));
}

sub tuple_tag_find_slot_value {
    my(undef, $delegator, $model_label) = shift->delegated_args(@_);
    return $delegator->get(
	_find_model_label($delegator, $model_label));
}

sub tuple_tag_form_state {
    return shift->[$_IDI] ||= {};
}

sub tuple_tag_map_slots {
    my(undef, $delegator, $op) = shift->delegated_args(@_);
    return _fields($delegator, sub {$op->(shift)});
}

sub tuple_tag_slot_choice_select_list {
    my(undef, $delegator, $field) = shift->delegated_args(@_);
    return $delegator->new_other('TupleSlotChoiceSelectList')
	->load_all_from_slot_type(
	    (_field_def_value($delegator, $field, 'tuple_slot_info') || {})
		->{type},
	);
}

sub tuple_tag_slot_has_choices {
    my(undef, $delegator, $field) = shift->delegated_args(@_);
    return 0
	unless my $i = _field_def_value($delegator, $field, 'tuple_slot_info');
    return $i->{type}->get('choices')->is_specified;
}

sub tuple_tag_slot_label {
    my(undef, $delegator, $field) = shift->delegated_args(@_);
    (my $x = _field_def_value($delegator, $field, 'TupleSlotDef.label') || '')
	=~ s/_/ /g;
    return $x;
}

sub _find_model_label {
    my($delegator, $model_label) = @_;
#TODO: This needs encapsulation
    $delegator->die($model_label, ': TupleUse not found')
	unless my $d = _defs($delegator, ($model_label =~ /^(\w+\.\w+)/)[0]);
    $delegator->die($model_label, ': TupleDef not found')
	unless $d->find_row_by_label(($model_label =~ /(\w+)$/)[0]);
    return "b_ticket.TupleTag." . $_TSN->field_name($d->get('TupleSlotDef.tuple_slot_num'));
}

sub _defs {
    my($delegator, $field) = @_;
    my($prefix) = $_FS->extract_qualified_prefix($field);
    return undef
	unless ref(my $d = $delegator->tuple_tag_form_state->{$prefix}
	||= (sub {
	    my($tu) = $delegator->new_other('TupleUse');
	    return $tu->unsafe_load({moniker => $prefix})
		? $tu->load_tuple_slot_def_list : -1;
	})->());
    return $field =~ /TupleTag$/ ? $d : $d->find_row_by_field_name($field);
}

sub _field_def_value {
    my($delegator, $field, $which) = @_;
    return undef
	unless my $d = _defs($delegator, $field);
    return undef
	unless $d->find_row_by_field_name($field);
    return $d->get($which);
}

sub _fields {
    my($delegator, $op, $id) = @_;
    return _ids($delegator, sub {
	my($id, $model) = @_;
        @{$_TSN->map_list(sub {
	    my($slot) = @_;
	    return $op->("$model.$slot", $id);
	})};
    }, $id);
}

sub _ids {
    my($delegator, $op, $id) = @_;
    return [map(
	$op->($_, $_FS->extract_qualified_prefix($_) . '.TupleTag'),
	$id ? $id : @{$delegator->TUPLE_TAG_IDS},
    )];
}

sub _setup {
    my($delegator, $if, $else) = @_;
    _ids($delegator, sub {
        my($id, $model) = @_;
	return unless my $d = _defs($delegator, $model);
	$delegator->internal_put_field(
	    "$model.tuple_def_id" => $d->get_query->get('parent_id'));
	return $else->($model)
	    unless $id = $delegator->unsafe_get($id);
	$delegator->internal_put_field("$model.primary_id" => $id);
	$if->($model) || $else->($model);
	return;
    });
    return;
}

1;
