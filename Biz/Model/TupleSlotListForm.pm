# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleSlotListForm;
use strict;
use Bivio::Base 'Biz.ListFormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_ARM) = b_use('Action.RealmMail');
my($_EK) = b_use('Model.TupleSlotChoiceSelectList')->EMPTY_KEY_VALUE;
my($_T) = b_use('Model.Tuple');
my($_TSN) = b_use('Type.TupleSlotNum');
my($_V) = b_use('UI.View');

sub execute_empty_row {
    my($self) = @_;
    my($lm) = $self->get_list_model;
    my($v) = _slot_value($self);
    $v = $v ? $$v : $lm->get('TupleSlotType.default_value');
    $self->internal_put_field(
	slot => defined($v) || !$lm->get('TupleSlotType.choices')->is_specified
	    ? $v : $_EK,
    );
    return;
}

sub execute_ok_end {
    my($self) = @_;
    $self->internal_put_field(slot_headers => $self->[$_IDI]->{headers});
    _validate_subject($self);
    $self->internal_put_field('RealmMail.subject' => $self->[$_IDI]->{subject});
    $self->internal_put_field('RealmMail.from_email' =>
        $self->new_other('Email')->unauth_load_or_die({
	    realm_id => $self->req('auth_user_id'),
	})->get('email'),
    );
    $_ARM->execute_receive($self->req,
	$_V->render('Tuple->edit_imail', $self->req));
    return;
}

sub execute_ok_row {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    my($lm) = $self->get_list_model;
    my($v, $e) = $lm->validate_slot($self->get('slot'));
    if ($e) {
	$self->internal_put_error(slot => $e);
	return;
    }
    my($tsv) = _slot_value($self);
    $fields->{headers} .= $_T->mail_slot(
	$lm->get('TupleSlotDef.label'),
        $lm->type_class_instance->to_literal(
	    defined($v) || $fields->{is_update} ? $v
		: $lm->get('TupleSlotType.default_value')),
    ) unless $tsv && $lm->type_class_instance->is_equal($v, $$tsv);
    _set_subject_if_string_slot($self, $lm, $v);
    return;
}

sub execute_ok_start {
    my($self) = @_;
    $self->[$_IDI] = {
	is_update => $self->req->has_keys('Model.Tuple') ? 1 : 0,
	headers => '',
    };
    return;
}

sub get_field_info {
    my($self, $field, $which) = @_;
    return shift->SUPER::get_field_info(@_)
	unless $which && $which eq 'type' && $field =~ /^slot(?:_(\d+))?$/;
    my($n) = $1;
    my($lm) = $self->get_list_model;
    return $lm->type_class_instance
	unless defined($n) && (my $c = $lm->get_cursor || -1) ne $n;
    $lm->set_cursor($n);
    my($res) = $lm->type_class_instance;
    $lm->internal_set_cursor($c);
    return $res;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        list_class => 'TupleSlotDefList',
	require_context => 1,
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
    $self->new_other('TupleUseList')->load_this({
	this => $tdid,
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
	    choice_list => $lm->get('TupleSlotType.choices')->is_specified
		? $self->new_other('TupleSlotChoiceSelectList')
		    ->load_all_from_slot_type($lm)
		: undef,
	);
    }
    return;
}

sub _get_subject_prefix {
    my($self) = @_;
    return ($self->req->unsafe_get('Model.Tuple') || $_T)->mail_subject(
	$self->req('Model.TupleUseList')->get_model('TupleUse'));
}

sub _set_subject_if_string_slot {
    # Set the subject line based on the first 'string' slot
    my($self, $lm, $v) = @_;
    my($fields) = $self->[$_IDI];
    if ($lm->type_class_instance eq Bivio::Type->get_instance('TupleSlot')) {
	$fields->{subject} = _get_subject_prefix($self)
	    . ' - ' . $lm->type_class_instance->to_literal(
		defined($v) || $fields->{is_update} ? $v
		    : $lm->get('TupleSlotType.default_value'))
		unless $fields->{subject};
    }
    return;
}

sub _slot_value {
    my($self) = @_;
    my($t) = $self->req->unsafe_get('Model.Tuple');
    return undef
	unless $t && $t->is_loaded;
    my($v) = $t->get(
	$_TSN->field_name($self->get('TupleSlotDef.tuple_slot_num')));
    return \$v;
}

sub _validate_subject {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    $fields->{subject} = _get_subject_prefix($self)
	unless $fields->{subject};
#TODO: Do we need to ensure that long lines don't present a problem to
# subject in mail header
#
# Use Text::Wrap? e.g.:
#   use Text::Wrap
#   $Text::Wrap::columns = 72;
#   print wrap('', '', @text);
#
# RFC2822 addressed the lack of clarity on this basic point:
#   2.1.1. Line Length Limits
#   There are two limits that this standard places on the number of characters
#   in a line. Each line of characters MUST be no more than 998 characters, and
#   SHOULD be no more than 78 characters, excluding the CRLF.
    return;
}

1;
