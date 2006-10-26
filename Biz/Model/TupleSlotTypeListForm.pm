# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleSlotTypeListForm;
use strict;
use base 'Bivio::Biz::Model::TupleExpandableListForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub MUST_BE_SPECIFIED_FIELDS {
    return [qw(choice)];
}

sub PARENT_LIST {
    return 'TupleSlotTypeList';
}

sub execute_empty_end {
    my($self) = @_;
    my($req) = $self->get_request;
    if (my $m = $req->unsafe_get('Model.TupleSlotType')) {
	$self->load_from_model_properties($m);
    }
    else {
	$self->internal_put_field('TupleSlotType.type_class' =>
            $self->get_instance('TupleSlotTypeClassList')->DEFAULT);
    }
    return;
}

sub execute_ok_end {
    my($self) = @_;
    my($req) = $self->get_request;
    my($v) = {
	%{$self->get_model_properties('TupleSlotType')},
	choices => $self->get_field_type('TupleSlotType.choices')
	    ->new($self->[$_IDI]),
    };
    my($tstcl) = $req->get('Model.TupleSlotTypeClassList');
    return _err($self, 'TupleSlotType.type_class', 'NOT_FOUND')
	unless $tstcl->find_row_by_class($v->{type_class});
    my($m) = $req->unsafe_get('Model.TupleSlotType');
    _err($self, 'type_class' => 'MUTUALLY_EXCLUSIVE')
	if $m && $tstcl->is_upgrade($m->get('type_class'), $v->{type_class});
    my($method) = $m ? 'update' : 'create';
    ($m || $self->new_other('TupleSlotType'))->$method($v);
    return;
}

sub execute_ok_row {
    my($self) = @_;
    return if $self->is_empty_row;
    my($v) = $self->get('choice');
    return _err($self, choice => 'EXISTS')
	if grep($v eq $_, @{$self->[$_IDI]});
    push(@{$self->[$_IDI]}, $v);
    return;
}

sub execute_ok_start {
    my($self) = @_;
    $self->[$_IDI] = [];
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        list_class => 'TupleSlotChoiceList',
	visible => [
	    'TupleSlotType.label',
	    'TupleSlotType.type_class',
	    'TupleSlotType.default_value',
	    {
		name => 'choice',
		type => 'TupleSlot',
		constraint => 'NONE',
		in_list => 1,
	    },
	],
	other => [
	    'TupleSlotType.choices',
	],
    });
}

sub internal_initialize_list {
    my($self) = shift;
    $self->new_other('TupleSlotTypeClassList')->load_all;
    return $self->SUPER::internal_initialize_list(@_);
}

sub internal_initialize_this_list {
    my($self, $parent_list, $this_list) = @_;
    $parent_list->get_model('TupleSlotType');
    $this_list->load_all_from_slot_type($parent_list);
    return;
}

sub _err {
    my($self, $field, $err) = @_;
    $self->internal_put_error(
	$field eq 'choice' ? $field : "TupleSlotType.$field" => $err);
    return;
}

1;
