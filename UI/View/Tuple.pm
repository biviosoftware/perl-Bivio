# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::Tuple;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub def_edit {
    return shift->internal_body(vs_list_form(TupleDefListForm => [qw(
	TupleDefListForm.TupleDef.label
	TupleDefListForm.TupleDef.moniker
	TupleSlotDef.label
	TupleSlotDef.is_required
    ),
	{
	    field => 'TupleSlotDef.tuple_slot_type_id',
	    choices => ['Model.TupleSlotTypeList'],
	    list_display_field => 'TupleSlotType.label',
	    unknown_label => 'Select Type',
	},
    ]));
}

sub def_list {
    return shift->internal_body(vs_list(TupleDefList => [qw(
	TupleDef.label
	TupleDef.moniker
    ),
	_list_actions(TupleSlotTypeList => [
	    'FORUM_TUPLE_DEF_EDIT',
	]),
    ]));
}

sub edit {
    return shift->internal_body([sub {
	my($req) = shift->get_request;
	my($lfm) = $req->get('Model.TupleSlotListForm');
	my($lm) = $lfm->get_list_model;
	return vs_simple_form(TupleSlotListForm => [
	    !$req->unsafe_get('Model.Tuple') ? () : [
		String(vs_text('TupleSlotListForm.Tuple.tuple_num'), {
		    cell_class => 'label label_ok',
		}),
		String([qw(Model.Tuple tuple_num)], {
		    cell_class => 'field',
		}),
	    ],
	    @{$lfm->map_rows(sub {
		my($it) = @_;
		my($label) = _sub_spaces($lm->get('TupleSlotDef.label'));
		my($field) = $it->get_field_name_in_list('slot');
		return [
		    FormFieldLabel({
			field => $field,
			label => String("$label:", 0),
			cell_class => 'label label_ok',
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
			}) : vs_edit("TupleSlotListForm.$field", {
			    wf_type => $it->get_list_model->type_class_instance,
			    allow_undef => 1,
			}),
		       $lm->get('TupleSlotDef.is_required') ? SPAN_required(
			   String('*'),
		       ) : (),
		    ], {cell_class => 'field'}),
		];
	    })},
	    [
		FormFieldLabel({
		    field => 'comment',
		    label => String('Comment:', 0),
		    cell_class => 'label label_ok',
		}),
		Join([
		    FormFieldError({
			field => 'comment',
			label => 'Comment',
		    }),
		    vs_edit('TupleSlotListForm.comment'),
		    SPAN_required(String('*')),
		], {cell_class => 'field'}),
	    ],
	    DIV_footer(Join([
		SPAN_required(String('*')),
		String(' marks fields that are required'),
	    ])),
	]);
    }]);
}

sub edit_mail {
#TODO: Support up to three file attachments
    view_put(
	mail_to => Mailbox(['->format_email']),
	mail_from => Mailbox(['Model.TupleSlotListForm', 'RealmMail.from_email']),
	mail_subject => String(['Model.TupleSlotListForm', 'RealmMail.subject']),
	mail_body => Prose(<<'EOF'),
String(['Model.TupleSlotListForm', 'slot_headers']);

String(['Model.TupleSlotListForm', 'comment']);
EOF
    );
    return;
}

sub history_list {
    _meta_info();
    return shift->internal_body(vs_list(TupleHistoryList => [qw(
        RealmFile.modified_date_time
	RealmMail.from_email
	slot_headers
    ), [
	comment => {
	    column_widget => Join([
		String({
		    field => 'comment',
		    value => [['comment']],
		}),
		[sub {
		     my($source) = @_;
		     my($thl) = $source->get_list_model();
		     $thl->new_other('MailPartList')
			 ->execute_from_realm_file_id(
			     $source->get_request,
			     $thl->get('RealmMail.realm_file_id'));
		     return '';
		}],
		DIV_tuple(List('MailPartList', [
		    DIV_part(Director(
			['mime_type'] => {
			    'text/plain' =>
				String(''),
			    'text/html' =>
				String(''),
			    'x-message/rfc822-headers' =>
				String(''),
			    map(
				("image/$_" => Link(
				    Image(['->format_uri_for_part',
					   'FORUM_MAIL_MSG_PART']),
				    ['->format_uri_for_part',
				     'FORUM_MAIL_MSG_PART']),
			     ), qw(png jpeg gif)),
			},
			Link(
			    Join([
				'Attachment: ',
				String(['->get_file_name']),
			    ]),
			    ['->format_uri_for_part',
			     'FORUM_MAIL_MSG_PART']),
		    )),
		])),
	    ]),
	},
    ]]));
}

sub history_list_csv {
    view_main(CSV(TupleHistoryList => [qw(
        RealmFile.modified_date_time
	RealmMail.from_email
	slot_headers
	comment
    )]));
    return;
}

sub list {
    vs_put_pager('TupleList');
    _meta_info();
    return shift->internal_body([
	sub {
	    my($req) = @_;
	    return vs_paged_list(TupleList => [
		_list_columns($req, 1),
		_list_actions(TupleList => [
		    {
			task_id => 'FORUM_TUPLE_HISTORY',
			controls => undef,
			query => {
			    'ListQuery.parent_id'
				=> ['Tuple.thread_root_id'],
			},
		    },
		    'FORUM_TUPLE_EDIT',
		]),
	    ], {
		no_pager => 1,
	    }),
	}
    ]);
}

sub list_csv {
    view_main(SimplePage({
	content_type => 'text/csv',
	value => [sub {
		      my($req) = @_;
		      return CSV(TupleList => [_list_columns($req)]);
		  }],
    }));
    return;
}

sub pre_compile {
    my($self) = shift;
    my(@res) = $self->SUPER::pre_compile(@_);
#TODO: Remove "base" is deprecated
    return @res
	unless $self->internal_base_type =~ /^(xhtml|base)$/;
    $self->internal_put_base_attr(tools => TaskMenu([
        {
	    task_id => 'FORUM_TUPLE_EDIT',
	    label => 'TupleHistoryList.FORUM_TUPLE_EDIT',
	    control => ['task_id', '->eq_forum_tuple_history'],
	    query => {
		'ListQuery.parent_id'
		    => [qw(Model.TupleList Tuple.tuple_def_id)],
		'ListQuery.this' => [qw(Model.TupleList Tuple.tuple_num)],
	    },
	},
        {
	    task_id => 'FORUM_TUPLE_HISTORY_CSV',
	    control => ['task_id', '->eq_forum_tuple_history'],
	    query => {
		'ListQuery.parent_id'
		    => [qw(Model.TupleList Tuple.thread_root_id)],
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
	    task_id => 'FORUM_TUPLE_LIST_CSV',
	    control => ['task_id', '->eq_forum_tuple_list'],
	    query => {
		'ListQuery.parent_id'
		    => [qw(Model.TupleUseList TupleUse.tuple_def_id)],
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
	map(+{
	    task_id => $_,
	    ($_ =~ /(.+)_(\w+)$/)[1] eq 'LIST' ? ()
		: (control => ['task_id', lc("->eq_${1}_list")]),
	}, qw(
	    FORUM_TUPLE_SLOT_TYPE_EDIT
	    FORUM_TUPLE_DEF_EDIT
	    FORUM_TUPLE_USE_EDIT
	    FORUM_TUPLE_SLOT_TYPE_LIST
	    FORUM_TUPLE_DEF_LIST
	    FORUM_TUPLE_USE_LIST
	)),
    ]));
    return @res;
}

sub slot_type_edit {
    return shift->internal_body(vs_list_form(TupleSlotTypeListForm => [
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
}

sub slot_type_list {
    return shift->internal_body(vs_list(TupleSlotTypeList => [qw(
	TupleSlotType.label
	TupleSlotType.choices
	TupleSlotType.default_value
    ),
	_list_actions(TupleSlotTypeList => [qw(
	    FORUM_TUPLE_SLOT_TYPE_EDIT
	)]),
    ]));
}

sub use_edit {
    return shift->internal_body(vs_simple_form(TupleUseForm => [
	['TupleUseForm.TupleUse.tuple_def_id' => {
	    choices => ['Model.TupleDefSelectList'],
	    list_display_field => 'TupleDef.label',
	}], qw(
	-optional
	TupleUseForm.TupleUse.label
	TupleUseForm.TupleUse.moniker
    )]));
}

sub use_list {
    return shift->internal_body(vs_list(TupleUseList => [
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

sub _list_columns {
    my($req, $html) = @_;
    return (
	qw(Tuple.tuple_num Tuple.modified_date_time),
	@{$req->get('Model.TupleSlotDefList')->map_rows(
	    sub {
		my($it) = @_;
		my($field) = 'Tuple.' . $it->field_from_num;
		my($label) = _sub_spaces($it->get('TupleSlotDef.label'));
		return [$field => {
		    column_heading => $html ? String($label) : $label,
		    $html ? (
			column_widget => vs_display('TupleList.' . $field => {
			    wf_type => $it->type_class_instance})
		    ) : (
			type => $it->type_class_instance,
		    ),
		}];
	    },
	)}
    );
}



sub _meta_info {
#TODO: Primitive hack to account for mail not being persisted in the db
#      initially, resulting in client visible lag time.
    view_put(page3_meta_info => If(
	[['->get_request'], '->unsafe_get', 'Action.Acknowledgement'],
	MetaTags({
	    html_attrs => [qw(http-equiv content)],
	    'http-equiv' => 'Refresh',
	    content => '5',
	}),
    ));
    return;
}

sub _sub_spaces {
    my($label) = @_;
    $label =~ s/[_-]/ /g;
    return $label;
}

1;
