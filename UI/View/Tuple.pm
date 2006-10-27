# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::View::Tuple;
use strict;
use base 'Bivio::UI::View::Method';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub def_edit {
    view_put(body => vs_list_form(TupleDefListForm => [qw(
	TupleDefListForm.TupleDef.label
	TupleDefListForm.TupleDef.moniker
	TupleSlotDef.label
	TupleSlotDef.is_required
    ),
	{
	    field => 'TupleSlotDef.tuple_slot_type_id',
	    choices => ['Model.TupleSlotTypeSelectList'],
	    list_display_field => 'TupleSlotType.label',
	},
    ]));
    return;
}

sub def_list {
    view_put(body => vs_list(TupleDefList => [qw(
	TupleDef.label
	TupleDef.moniker
    ),
	_list_actions(TupleSlotTypeList => [{
	   task_id => 'FORUM_TUPLE_DEF_EDIT',
	   controls => [
	       ['!', 'use_count'],
	   ],
	}]),
    ]));
    return;
}

sub edit {
    view_put(body => [sub {
	my($req) = shift->get_request;
	my($lfm) = $req->get('Model.TupleSlotListForm');
	my($lm) = $lfm->get_list_model;
	return vs_simple_form(TupleSlotListForm => [
	    !$req->unsafe_get('Model.Tuple') ? () : [
		String(vs_text('TupleSlotListForm.Tuple.tuple_num'), {
		    cell_class => 'label',
		}),
		String([qw(Model.Tuple tuple_num)], {
		    cell_class => 'field',
		}),
	    ],
	    @{$lfm->map_rows(sub {
		my($it) = @_;
		my($label) = $lm->get('TupleSlotDef.label');
		my($field) = $it->get_field_name_in_list('slot');
		return [
		    FormFieldLabel({
			field => $field,
			label => String("$label:", 0),
			cell_class => 'label',
		    }),
		    Join([
			FormFieldError({
			    field => $field,
			    label => $label,
			}),
			$lfm->get('choice_list') ? Select({
			    field => $field,
			    choices => [
				'Model.TupleSlotListForm',
				$lfm->get_field_name_in_list('choice_list'),
			    ],
			    list_id_field => 'choice',
			    list_display_field => 'choice',
			}) : vs_display("TupleSlotListForm.$field", {
			    wf_type => $it->get_list_model->type_class_instance,
			}),
		    ], {cell_class => 'field'}),
		];
	    })},
	    'TupleSlotListForm.comment',
	]);
    }]);
    return;
}

sub edit_mail {
    view_put(
	mail_to => Mailbox(['->format_email']),
	mail_from => Mailbox(['Model.TupleSlotListForm', 'RealmMail.from_email']),
	mail_subject => Mailbox(['Model.TupleSlotListForm', 'RealmMail.subject']),
	mail_body => Prose(<<'EOF'),
String(['Model.TupleSlotListForm', 'slot_headers']);

String(['Model.TupleSlotListForm', 'comment']);
EOF
    );
    return;
}

sub history_list {
    view_put(body => vs_list(TupleHistoryList => [qw(
        RealmFile.modified_date_time
        RealmMail.from_email
        slot_headers
        comment
    )]));
    return;
}

sub list {
    vs_put_pager('TupleList');
    view_put(body => [sub {
	my($req) = @_;
	return vs_paged_list(TupleList => [qw(
	    Tuple.tuple_num
	    Tuple.modified_date_time
	),
	@{$req->get('Model.TupleSlotDefList')->map_rows(
	    sub {
		my($it) = @_;
		my($field) = 'Tuple.' . $it->field_from_num;
		return [$field => {
		    column_heading =>
			String($it->get('TupleSlotDef.label')),
		    column_widget => vs_display('TupleList.'. $field => {
			wf_type => $it->type_class_instance
		    }),
		}];
	    },
	)},
	    _list_actions(TupleList => [
		'FORUM_TUPLE_HISTORY',
                'FORUM_TUPLE_EDIT',
	    ]),
	], {
	    no_pager => 1,
	}),
    }]);
    return;
}

sub pre_compile {
    my($self) = @_;
    if ($self->get('view_method') =~ /_mail$/) {
	view_parent('mail');
	return;
    }
    my(@res) = shift->SUPER::pre_compile(@_);
    view_put(base_tools => TaskMenu([map(+{
	task_id => $_,
	($_ =~ /(.+)_(\w+)$/)[1] eq 'LIST' ? ()
	    : (control =>
	    ['task_id', lc("->eq_${1}_list")]),
    }, qw(
	FORUM_TUPLE_USE_LIST
	FORUM_TUPLE_DEF_LIST
	FORUM_TUPLE_SLOT_TYPE_LIST
	FORUM_TUPLE_USE_EDIT
	FORUM_TUPLE_DEF_EDIT
	FORUM_TUPLE_SLOT_TYPE_EDIT
    )),
        {
	    task_id => 'FORUM_TUPLE_EDIT',
	    label => 'TupleHistoryList.FORUM_TUPLE_EDIT',
	    control => ['task_id', '->eq_forum_tuple_history'],
	    query => {
		'ListQuery.parent_id' => [qw(Model.TupleList Tuple.tuple_def_id)],
		'ListQuery.this' => [qw(Model.TupleList Tuple.tuple_num)],
	    },
	},
        {
	    task_id => 'FORUM_TUPLE_EDIT',
	    control => ['task_id', '->eq_forum_tuple_list'],
	    query => {
		'ListQuery.parent_id'
		    => [[qw(Model.TupleList ->get_query)], 'parent_id'],
	    },
	},
        {
	    label => 'TupleHistoryList.FORUM_TUPLE_LIST',
	    task_id => 'FORUM_TUPLE_LIST',
	    control => Or(
		[qw(task_id ->eq_forum_tuple_edit)],
		[qw(task_id ->eq_forum_tuple_history)],
	    ),
	    query => {
		'ListQuery.parent_id'
		    => [qw(Model.TupleUseList TupleUse.tuple_def_id)],
	    },
	},
    ]));
    return @res;
}

sub slot_type_edit {
    view_put(body => vs_list_form(TupleSlotTypeListForm => [
	'TupleSlotTypeListForm.TupleSlotType.label',
	['TupleSlotTypeListForm.TupleSlotType.type_class' => {
	    wf_class => 'Select',
	    choices => ['Model.TupleSlotTypeClassList'],
	    list_display_field => 'TupleSlotType.type_class',
	    list_id_field => 'TupleSlotType.type_class',
	}],
	'TupleSlotTypeListForm.TupleSlotType.default_value',
	'choice',
    ]));
    return;
}

sub slot_type_list {
    view_put(body => vs_list(TupleSlotTypeList => [qw(
	TupleSlotType.label
	TupleSlotType.choices
	TupleSlotType.default_value
    ),
	_list_actions(TupleSlotTypeList => [qw(
	    FORUM_TUPLE_SLOT_TYPE_EDIT
	)]),
    ]));
    return;
}

sub use_edit {
    view_put(body => vs_simple_form(TupleUseForm => [
	['TupleUseForm.TupleUse.tuple_def_id' => {
	    choices => ['Model.TupleDefSelectList'],
	    list_display_field => 'TupleDef.label',
	}], qw(
	-optional
	TupleUseForm.TupleUse.label
	TupleUseForm.TupleUse.moniker
    )]));
    return;
}

sub use_list {
    view_put(body => vs_list(TupleUseList => [
	['TupleUse.label', => {
	    wf_list_link => {
		query => 'THIS_CHILD_LIST',
		task => 'FORUM_TUPLE_LIST',
	    },
	}],
	'TupleUse.moniker',
	'TupleDef.label',
	_list_actions(TupleUseList => [
	    'FORUM_TUPLE_USE_EDIT',
	    {
		task_id => 'FORUM_TUPLE_EDIT',
		query => 'THIS_CHILD_LIST',
	    }, {
		task_id => 'FORUM_TUPLE_LIST',
		query => 'THIS_CHILD_LIST',
	    },
	]),
    ]));
    return;
}

sub _list_actions {
    my($model, $tasks) = @_;
    my($r) = Bivio::Biz::Model->get_instance($model)
	->has_fields(qw(RealmOwner.name RealmOwner.realm_type));
    return {
	column_heading => String(vs_text("$model.list_actions")),
	column_widget => ListActions([
	    map({
		my($t, $c, $q) = ref($_) ? @$_{qw(task_id controls query)} : $_;
		push(@{$c ||= []}, ['RealmOwner.realm_type', '->eq_forum'])
		    if $r;
		[
		    vs_text("$model.list_action.$t"),
		    $t,
		    URI({
			task_id => $t,
			$r ? (realm => ['RealmOwner.name']) : (),
			query => ref($q) ? $q
			    : ['->format_query', $q || 'THIS_DETAIL'],
		    }),
		    $c && (@$c > 1 ? And(@$c) : $c->[0]),
		    $r ? ['RealmOwner.name'] : (),
		];
	    } @$tasks),
	]),
	column_data_class => 'list_actions',
    };
}

1;
