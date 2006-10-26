# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleSlotListForm;
use strict;
use base 'Bivio::Biz::ListFormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_T) = __PACKAGE__->get_instance('Tuple');
my($_TSN) = Bivio::Type->get_instance('TupleSlotNum');
my($_UNDEF) = undef;

sub execute_empty_row {
    my($self) = @_;
    $self->internal_put_field(
	slot => $self->get_list_model->empty_slot(
	    ${_slot_value($self) || \$_UNDEF}));
    return;
}

sub execute_ok_end {
    my($self) = @_;
    my($req) = $self->get_request;
    $self->internal_put_field(slot_headers => $self->[$_IDI]);
    $self->internal_put_field(
	'RealmMail.subject' => $self->get_request->unsafe_get_nested(
	    'Model.RealmMail', 'subject'
	) || ($req->unsafe_get('Model.Tuple') || $_T)
	->mail_subject($req->get('Model.TupleUse')));
    $self->internal_put_field('RealmMail.from_email' =>
        $self->new_other('Email')->unauth_load_or_die({
	    realm_id => $self->get_request->get('auth_user_id'),
	})->get('email'),
    );
    return 'server_redirect.next';
}

sub execute_ok_row {
    my($self) = @_;
    my($lm) = $self->get_list_model;
    # Never want blanks so never "null_ok" on this form
    my($v, $e) = $lm->validate_slot($self->get('slot'));
    if ($e) {
	$self->internal_put_error(slot => $e);
	return;
    }
    my($tsv) = _slot_value($self);
    $self->[$_IDI] .= $_T->mail_slot($lm->get('TupleSlotDef.label'), $v)
	unless $tsv && $lm->type_class_instance->is_equal($v, $$tsv);
    return;
}

sub execute_ok_start {
    my($self) = @_;
    $self->[$_IDI] = '';
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        list_class => 'TupleSlotDefList',
	visible => [
	    {
		name => 'comment',
		type => 'Text64K',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'slot',
		type => 'TupleSlot',
		constraint => 'NONE',
		in_list => 1,
	    },
	],
	other => [
	    'RealmMail.from_email',
	    'RealmMail.subject',
	    {
		name => 'slot_headers',
		type => 'Text64K',
		constraint => 'NONE',
	    },
	    {
		name => 'choice_list',
		type => $self->get_instance('TupleSlotChoiceSelectList')
		    ->package_name,
		in_list => 1,
		constraint => 'NONE',
	    },
	],
    });
}

sub internal_initialize_list {
    my($self) = @_;
    my($q) = $self->new_other('TupleList')->parse_query_from_request;
    my($tdid, $tn) = $q->unsafe_get(qw(parent_id this));
    # AUTH: Make sure this realm can use this schema
    $self->new_other('TupleUse')->load({
	tuple_def_id => $tdid,
    });
    $self->new_other('TupleSlotDefList')->load_all({
	parent_id => $tdid,
    });
    if ($tn) {
	my($trid) = $self->new_other('Tuple')->load({
	    tuple_def_id => $tdid,
	    tuple_num => $tn,
	})->get('thread_root_id');
	$self->new_other('RealmMail')->load({
	    realm_file_id => $trid,
	}) if $trid;
    }
    return shift->SUPER::internal_initialize_list(@_);
}

sub internal_post_execute {
    my($self, $method) = @_;
    _put_choice_lists($self)
#TODO: Generalize this
	if $self->in_error || $method eq 'execute_empty';
    return shift->SUPER::internal_post_execute(@_);
}

sub _put_choice_lists {
    my($self) = @_;
    $self->reset_cursor;
    my($lm) = $self->get_list_model;
    while ($self->next_row) {
	$self->internal_put_field(
	    choice_list => $lm->get('TupleSlotType.choices')
		? $self->new_other('TupleSlotChoiceSelectList')
		    ->load_all_from_slot_type($lm)
		: undef,
	);
    }
    return;
}

sub _slot_value {
    my($self) = @_;
    my($t) = $self->get_request->unsafe_get('Model.Tuple');
    return undef
	unless $t && $t->is_loaded;
    my($v) = $t->get(
	$_TSN->field_name($self->get('TupleSlotDef.tuple_slot_num')));
    return \$v;
}

1;
