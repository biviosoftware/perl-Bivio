# Copyright (c) 2005-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::ViewShortcuts;
use strict;
use Bivio::Base 'UIXHTML';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_FF) = b_use('HTMLWidget.FormField');
my($_W) = b_use('UI.Widget');
my($_AA) = b_use('Action.Acknowledgement');
my($_M) = b_use('Biz.Model');
my($_WF) = b_use('UIHTML.WidgetFactory');
my($_ELFM) = b_use('Biz.ExpandableListFormModel');
my($_HTML_TAGS) = join('|', qw(
    A
    ABBR
    ACRONYM
    ADDRESS
    APPLET
    AREA
    B
    BASE
    BASEFONT
    BDO
    BIG
    BLOCKQUOTE
    BODY
    BR
    BUTTON
    CANVAS
    CAPTION
    CENTER
    CITE
    CODE
    COL
    COLGROUP
    DD
    DEL
    DFN
    DIR
    DIV
    DL
    DT
    EM
    FIELDSET
    FONT
    FORM
    FRAME
    FRAMESET
    H1
    H2
    H3
    H4
    H5
    H6
    HEAD
    HR
    HTML
    I
    IFRAME
    IMG
    INPUT
    INS
    ISINDEX
    KBD
    LABEL
    LEGEND
    LI
    LINK
    MAP
    MENU
    META
    NAV
    NOFRAMES
    NOSCRIPT
    OBJECT
    OL
    OPTGROUP
    OPTION
    P
    PARAM
    PRE
    Q
    S
    SAMP
    SCRIPT
    SELECT
    SMALL
    SPAN
    STRIKE
    STRONG
    STYLE
    SUB
    SUP
    TABLE
    TBODY
    TD
    TEXTAREA
    TFOOT
    TH
    THEAD
    TITLE
    TR
    TT
    U
    UL
    VAR
));
my($_SUBMIT_CHAR) = '*';
my($_LM) = b_use('Biz.ListModel');
my($_DYNAMIC_QUERY_KEYS) = [
    b_use('Biz.FormModel')->FORM_CONTEXT_QUERY_KEY,
    map(
	b_use('SQL.ListQuery')->to_char($_),
	qw(order_by search),
    ),
];

sub view_autoload {
    my($proto, $method, $args, $simple_method, $suffix) = @_;
    return shift->SUPER::view_autoload(@_)
	unless $simple_method =~ /^($_HTML_TAGS)$/os;
    my($w) = Tag(lc($simple_method), @$args ? @$args : ('', {tag_if_empty => 1}));
    $w->put_unless_exists(class => $suffix)
	if $suffix;
    return $w->b_widget_label($method);
}

sub vs_acknowledgement {
    my($proto, $die_if_not_found) = @_;
    return $proto->vs_call(
	'If',
	[sub {$_AA->extract_label(shift->get_request)}],
	$proto->vs_call(
	    'Tag',
	    'p',
	    [sub {
		 my($req) = shift->get_request;
		 return __PACKAGE__->vs_call(
		     'String',
		     __PACKAGE__->vs_call(
			 'Prose',
			 b_use('FacadeComponent.Text')->get_value(
			     'acknowledgement',
			     $req->get_nested(
				 'Action.Acknowledgement', 'label'),
			     $req,
			 ),
		     ),
		 );
	     }],
	    'ack',
	),
    );
}

sub vs_actions_column {
    my($self, $actions) = @_;
    return {
	column_heading => 'actions',
	column_widget => ListActions($actions),
    };
}

sub vs_alphabetical_chooser {
    my($self, $list_model) = @_;
    $list_model = "Model.$list_model";
    my($all) = $self->use($list_model)->LOAD_ALL_SEARCH_STRING;
    return Tag(div => Join([
	map(
	    Link(
	        String($_),
		URI({
		    query => [
			$list_model, '->format_query',
			'ANY_LIST', {search => $_ eq 'All' ? $all : $_},
		    ],
		}),
		[sub {
		     my(undef, $a, $search) = @_;
		     $a = lc($a);
		     return join(' ',
			  $a eq lc($all) ? 'all' : (),
			  $a eq 'a' ? () : 'want_sep',
			  lc($search || $all) eq $a ? 'selected' : (),
		     );
		},
		    $_,
		    [[$list_model, '->get_query'], 'search'],
	        ],
	    ),
	    'A'..'Z', 'All',
	),
    ]), 'alphabetical_chooser');
}

sub vs_descriptive_field {
    my($proto, $field) = @_;
    my($name, $attrs) = ref($field) eq 'HASH'
	? ($field->{field}, $field)
        : ref($field) ? @$field : $field;
    $attrs ||= {};
    $name =~ /^(\w+)\.(.+)/;
    my($label, $input) = !$attrs->{wf_class}
	&& ($attrs->{wf_type} || 
	    Bivio::Biz::Model->get_instance($1)->get_field_type($2))
	    ->isa('Bivio::Type::Boolean') ? (
	    undef,
	    FormField($name, $attrs),
	) : $proto->vs_form_field($name, $attrs);
    $label = undef
	if $attrs->{vs_descriptive_field_no_label};
    return [
	$label
	    ? ($label->put(cell_class => 'label label_ok'))
	    : vs_blank_cell(),
	Join([
	    $input,
            $attrs->{vs_descriptive_field_no_description}
                ? ()
	        : $proto->vs_field_description($name),
	], {
	    cell_class => 'field',
#TODO: Should this be on label, since it is the first cell in the row?
	    map(($_ => $attrs->{$_}), grep(/^row_\w+$/, keys(%$attrs))),
	}),
    ];
}

sub vs_empty_list_prose {
    my($self, $model) = @_;
    return DIV_empty_list(Prose(vs_text("$model.empty_list_prose")));
}

sub vs_form_error_title {
    my($proto, $form) = @_;
    return Join([
	DIV_err_title(String(vs_text('form_error_title')), {
	    control => [['->req'], "Model.$form", '->in_error'],
	}),
	DIV_err_title(String(vs_text('form_stale_data_title')), {
	    control => [['->req'], "Model.$form", '->has_stale_data'],
	}),
    ]);
}

sub vs_can_group_bulletin_form {
    return [sub {
        my($req) = shift->req;
        return $req->can_user_execute_task('GROUP_BULLETIN_FORM')
	    && $req->can_user_execute_task('FORUM_MAIL_FORM');
    }];
}

sub vs_field_description {
    my(undef, $field_name) = @_;
    return [sub {
        my($source, $fn) = @_;
	return ''
	    unless my $v = $source->req('Bivio::UI::Facade', 'Text')
	    ->unsafe_get_value($fn, 'desc');
	return DIV_desc(Prose($v));
    }, $field_name];
}

sub vs_file_versions_actions_column {
    return ['actions', {
	column_data_class => 'list_action',
	column_control => [sub {
	    my($source) = @_;
	    return ! $_LM->new_anonymous({
		primary_key => [
		    [qw(RealmFile.realm_file_id RealmFileLock.realm_file_id)],
		],
		other => [['RealmFile.path', [$source->req->get('path_info')]]],
	    })->set_ephemeral->unsafe_load_this_or_first;
	}],
	column_widget => ListActions([
	    map({
		my($task) = $_;
		[
		    vs_text_as_prose("RealmFileVersionsList.list_action.$_"),
		    $task,
		    URI({
			task_id => $task,
			query => {
			    'ListQuery.this' => ['RealmFile.realm_file_id'],
			},
			path_info => [qw(->req path_info)],
		    }),
		    Not(Equals([['->get_list_model'], 'revision_number'], 'current')),
		];
	    }
		    'FORUM_FILE_REVERT_FORM',
	    ),
	]),
    }];
}

sub vs_filter_query_form {
    my($proto, $form, $extra_columns, $attrs) = @_;
    return $proto->vs_selector_form(
	$form ||= 'FilterQueryForm',
	[
	    $attrs->{text} || Join([ClearOnFocus(
		Text({
  		    field => 'b_filter',
  		    size => int(b_use('Type.Line')->get_width / 2),
  		}),
		[['->req', "Model.$form"], '->clear_on_focus_hint'],
	    )]),
	    @{$extra_columns || []},
	],
	1,
    );
}

sub vs_header_su_link {
    my(undef, $normal_widget) = @_;
    return DIV_logo_su(If(
	['->is_substitute_user'],
	Link(
	    RoundedBox(Join([
		'Acting as User:',
		BR(),
		String(['auth_user', 'display_name']),
		BR(),
		'Click here to exit.',
	    ])),
	    b_use('IO.Config')->if_version(10,
		sub {
		    return URI({
			task_id => 'SITE_ADMIN_SUBSTITUTE_USER_DONE',
			realm => vs_constant('site_admin_realm_name'),
			query => undef,
		    });
		},
		sub {'LOGOUT'},
	    ),
	    'su',
	),
	$normal_widget,
    ));
}

sub vs_inline_form {
    my($self, $model, $cols, $attrs) = @_;
    return Form(
	$model,
	Join($cols),
	{
	    form_method => 'get',
	    want_timezone => 0,
	    want_hidden_fields => 0,
	    $attrs ? %$attrs : (),
	},
    );
}

sub vs_label_cell {
    my($self, $model_field) = @_;
    return (FormField("$model_field")->get_label_and_field)[0]
	->get('label')
#TODO: Encapsulate in FormFieldLabel
	->put(cell_class => 'label label_ok');
}

sub vs_list {
    my($proto, $model, $columns, $attrs) = @_;
    return Table(
	$model,
	$columns,
	$proto->vs_table_attrs($model, list => $attrs),
    );
}

sub vs_list_form {
    my($proto, $form, $fields, $table_attrs, $options) = @_;
    $options = defined($options) && ref($options) eq 'HASH'
	? $options
	: {
	    list_first => $options,
	};
    # Elements in $fields which are hash_refs or are "in_list" appear
    # as columns.  Elements which are arrays or are not "in_list" appear
    # as simple form entries.
    my($fm) = $_M->get_instance($form);
    my($lm) = $_M->get_instance($fm->get_list_class);
    my($list) = [];
    my($submit);
    my(@form_fields) = (map(
	{
	    my($d) = $_;
	    my($field) = ref($d) eq 'HASH'
		? $d
		: ref($d) eq 'ARRAY'
		? {
		    field => $d->[0],
		    %{$d->[1] || {}},
		}
		: !ref($d)
		? {
		    field => ($d =~ /^\w+\.(\w+\.\w+)$/)[0] || $d,
		}
		: b_die($d, ': unknown field format');
	    if (!$field->{field} || $field->{column_widget}) {
		push(@$list, $field);
		$d = undef;
	    }
	    elsif ($fm->has_fields($field->{field})) {
		if ($fm->get_field_info($field->{field}, 'in_list')) {
		    push(@$list, $field);
		    $d = undef;
		}
	    }
	    elsif ($lm->has_fields($field->{field})) {
		push(
		    @$list,
		    {
			%$field,
			wf_want_display => 1,
			column_widget => $_WF->create(
			    $lm->simple_package_name . ".$field->{field}",
			    {
				source_is_list_model => 1,
				field => $field->{field},
				%$field,
			    },
			),
		    },
		);
		$d = undef;
	    }
	    elsif ($field->{field} =~ /^\*/) {
		if (@$list) {
		    $submit = $field->{field};
		    $d = undef;
		}
	    }
	    $d ? $d : ();
	}
	@$fields,
    ));
    my($list_form) = @$list ? Table(
	$form,
	[map(
	    {
		my($x) = !ref($_) ? {field => $_} : $_;
		$x->{column_class} ||= 'field';
		# So checkboxes don't have labels in the fields, just hdr
		$x->{label} = ''
		    unless exists($x->{label});
		$x;
	    }
		@$list,
	)],
	$proto->vs_table_attrs($form, list => $table_attrs),
    ) : ();
    if ($options->{indent_list} && $list_form) {
	$list_form = [vs_blank_cell(), $list_form];
    }
    return $proto->vs_simple_form(
	$form,
	[
	        $options->{list_first}
		    ? ($list_form, @form_fields)
		    : (@form_fields, $list_form),
	    $submit ? $submit : (),
	],
	$options,
    );
}

sub vs_paged_detail {
    my(undef, $model, $list_uri_args, $detail) = @_;
    my($x) = "Model.$model";
    my($p) = "$model.paged_detail.";
    view_put(vs_pager => Tag(div => Join([
	map(
	    Link(
		vs_text("$p$_"),
		$_ eq 'list'
		    ? (
			[
			    $x,
			    '->format_uri',
			    @$list_uri_args,
			],
			$_,
		    ) : (
			[$x, '->format_uri', uc($_) . '_DETAIL'],
			{
			    control =>
				[[$x, '->get_query'], "has_$_"],
			    control_off_value => Tag(
				span => String(
				    vs_text("$p$_")), "$_ off"),
			    class => $_,
			},
		    ),
	    ),
	    qw(prev next list)
	),
    ]), 'pager'));
    return Tag(div => $detail, 'paged_detail');
}

sub vs_paged_list {
    my($proto, $model, $columns, $attrs) = @_;
    $proto->vs_put_pager($model, $attrs)
	unless delete($attrs->{no_pager});
    return (ref($columns) eq 'ARRAY' ? Table($model, $columns) : $columns)
	->put(%{$proto->vs_table_attrs($model, paged_list => $attrs)});
}

sub vs_phone {
    my($proto) = @_;
    return $proto->vs_call(Join => [$proto->vs_text('support_phone')]);
}

sub vs_placeholder_form {
    my($proto) = @_;
    return shift->vs_simple_form(@_);
}

sub vs_prose {
    my(undef, $prose) = @_;
    return Tag(div => Prose($prose), 'prose');
}

sub vs_put_pager {
    my($proto, $model, $attrs) = @_;
    view_put(vs_pager => DIV_pager(Pager({
	list_class => $model,
	$attrs ? %$attrs : (),
    })));
    $proto->vs_put_seo_list_links($model);
    return;
}

sub vs_put_seo_list_links {
    my($self, $model) = @_;
    my($value) = ref($model)
	? $model
	: ["Model.$model", '->get_list_model'];
    view_put(
	xhtml_seo_head_links => Join([
	    map(
		If(
		    [[$value, '->get_query'], "has_$_"],
		    LINK({
			REL => $_,
			HREF => URI({
			    require_absolute => 1,
			    query => [
				$value,
				'->format_query',
				uc($_) . '_LIST',
			    ],
			}),
		    }),
		),
		qw(prev next),
	    ),
	    _canonical_link(),
	]),
    );
    return;
}

sub vs_rss_task_in_head {
    my($self) = @_;
    return EmptyTag(link => {
	control => view_widget_value('xhtml_rss_task'),
	html_attrs => [qw(rel type title href)],
	rel => 'alternate',
	type => 'application/atom+xml',
	title => Prose(
	    vs_text(
		'rsslink', 'title', view_widget_value('xhtml_rss_task')),
	   ),
	href => URI({
	    task_id => view_widget_value('xhtml_rss_task'),
	    query => undef,
	}),
    });
}

sub vs_selector_form {
    my($proto, $model, $widgets, $is_get) = @_;
    return Form(
	$model,
	Join([
	    map(DIV_b_item($_->put_unless_exists(auto_submit => 1)), @$widgets),
	    ScriptOnly({
		widget => Simple(''),
		alt_widget => FormButton({
		    field => 'ok_button',
		    label => $proto
			->vs_text_as_prose('vs_selector_form.ok_button'),
		}),
	    }),
	]),
	{
	    class => 'b_selector',
	    !$is_get ? () : (
		form_method => 'get',
		want_timezone => 0,
		want_hidden_fields => 0,
	    ),
	},
    );
}

sub vs_simple_form {
    my($proto, $form, $rows, $attrs) = @_;
    $attrs ||= {};
    unless (ref($attrs)) {
	b_die('expected boolean')
	    unless $attrs =~ /^(1|0)$/;
	$attrs = {no_submit => 1};
    }
    my($have_submit) = 0;
    my($m) = Bivio::Biz::Model->get_instance($form);
    unshift(@$rows, q{'prologue})
        unless grep(!ref($_) && $_ eq q{'prologue}, @$rows);
    splice(
	@$rows,
	$#$rows + (_has_submit([$rows->[$#$rows]]) ? 0 : 1),
	0,
	q{'epilogue},
    ) unless grep(!ref($_) && $_ eq q{'epilogue}, @$rows);
    push(@$rows, $proto->vs_simple_form_submit)
        unless $attrs->{no_submit} || _has_submit($proto, $rows);
    return Form(
	$form,
	Join([
	    $proto->vs_form_error_title($form),
	    $proto->vs_simple_form_container([
		map({
		    my($x);
		    if ($_FF->is_blesser_of($_)) {
			$_->put_unless_exists(cell_class => 'field'),
			$x = [
			    Simple('', {cell_class => 'label label_ok'}),
			    $_,
			];
		    }
		    elsif ($_W->is_blesser_of($_)) {
			$x = [$_->put_unless_exists(cell_colspan => 2)];
		    }
		    elsif ($_ =~ s/^-//) {
			$x = [Prose(vs_text($form, 'separator', $_), {
			    cell_colspan => 2,
			    cell_class => 'sep',
			})];
		    }
		    elsif ($_ =~ s/^\Q$_SUBMIT_CHAR//) {
			$_ = 'ok_button add_rows cancel_button'
			    if !$_ && $_ELFM->is_blesser_of($m);
			$x = [StandardSubmit({
			    cell_colspan => 2,
			    $_ ? (buttons => $_) : (),
			})];
		    }
		    elsif ($_ =~ s/^'//) {
			$x = [Prose(vs_text($form, 'prose', $_), {
			    cell_colspan => 2,
			    cell_class => 'form_prose',
			})];
		    }
		    elsif (ref($_) eq 'ARRAY' && ref($_->[0])) {
			$x = $_;
		    }
		    else {
			$x = $proto->vs_descriptive_field($_);
		    }
		    $x;
		} @$rows),
	    ], $attrs),
	]),
    );
}

sub vs_simple_form_container {
    my($self, $values, $form_attrs) = @_;
    return Grid($values, {
	class => 'simple',
    });
}

sub vs_simple_form_submit {
    my(undef, $fields) = @_;
    return $_SUBMIT_CHAR . join(' ', @{$fields || []});
}

#TODO: clean up, make into widget
sub vs_smart_date {
    my($self, $field) = @_;
    my($value) = ref($field)
	? $field
	: [$field || 'RealmFile.modified_date_time'];
    return SPAN_bivio_smart_date(Simple([
	sub {
	    my($source, $dt) = @_;
	    return ''
		if !defined($dt);
	    my($now) = Type_DateTime()->now;
	    return DateTime($value, 'FULL_MONTH_DAY_AND_YEAR')
		if Type_DateTime()->get_part(
		    Type_DateTime()->to_local($dt), 'year')
		    != Type_DateTime()->get_part(
			Type_DateTime()->to_local($now), 'year');
	    my($dd) = Type_DateTime()->delta_days(
		Type_DateTime()->set_local_end_of_day($dt),
		Type_DateTime()->local_end_of_today,
	    );
	    return DateTime($value, 'MONTH_NAME_AND_DAY_NUMBER')
		if $dd > 7;
	    return Type_DateTime()->english_day_of_week(
		Type_DateTime()->to_local($dt),
	    ) if $dd > 1;
	    my($ds) = Type_DateTime()->diff_seconds($now, $dt);
	    return _format_integer_ago(
		Type_Integer()->round($ds / 60 / 60), 'hour')
		if $ds > Type_DateTime()->SECONDS_IN_DAY / 24
			&& $ds < Type_DateTime()->SECONDS_IN_DAY;
	    return _format_integer_ago(
		Type_Integer()->round($ds / 60), 'minute')
		if $ds > 60 && $ds < Type_DateTime()->SECONDS_IN_DAY / 24;
	    return Join([
		'Yesterday',
		DateTime($value, 'HOUR_MINUTE_AM_PM_LC'),
	    ], ' ')
		if $dd > 0;
	    return DateTime($value, 'HOUR_MINUTE_AM_PM_LC')
		if $ds > Type_DateTime()->SECONDS_IN_DAY / 24;
	    return 'Just now';
	},
	$value,
    ]));
}

sub vs_table_attrs {
    my($proto, $model, $class, $attrs) = @_;
    return {
	class => $class,
	empty_list_widget => $proto->vs_empty_list_prose($model),
	%{$attrs || {}},
    };
}

sub vs_tree_list {
    my($proto, $model, $columns, $attrs) = @_;
    $columns->[0] = $proto->vs_tree_list_control($model, $columns->[0]);
    return Table(
	$model,
	$columns,
	$proto->vs_table_attrs($model, tree_list => {
	    %{$attrs || {}},
	    want_sorting => 0,
	}),
    );
}

sub vs_tree_list_control {
    my($proto, $model, $c) = @_;
    $c = ref($c) ? {field => $c->[0], %{$c->[1] || {}}} : {field => $c}
	unless ref($c) eq 'HASH';
    return {
	%$c,
	column_widget => Join([
	    Replicator([['->get_list_model'], 'node_level'], SPAN_sp()),
	    If([['->get_list_model'], 'node_uri'],
	       map({
		   my($x) = Join([
		       Image(vs_text(
			   $_M->get_instance($model)->get_list_class,
			   [['->get_list_model'], 'node_state', '->get_name'],
		       )),
		       Tag(span =>
		           ($c->{column_widget}
			       || $_WF->create($model . '.' . $c->{field}, $c)),
			   'name',
		       ),
		   ]);
		   $_ ? Link($x, [['->get_list_model'], 'node_uri']) : $x;
	       } 1, 0),
	    ),
	    $c->{tree_list_control_suffix_widget}
	        ? (vs_blank_cell(2), $c->{tree_list_control_suffix_widget})
	        : (),
	]),
	column_data_class => 'node',
    };
}

sub vs_trimmed_text_column {
    my(undef, $field, $attr) = @_;
    my($id) = $field =~ /\.(\w+)/;
    $id ||= $field;
    return [$field, {
	column_widget => TrimmedText(String([$field]), {
	    ID => Join([
		$id,
		['->get_cursor'],
	    ]),
	}),
	column_data_class => 'small_boxed_text',
	$attr ? %$attr : (),
    }];
}

sub vs_tuple_use_list_as_task_menu_list {
    my(undef, $req) = @_;
    return @{
	# TupleUseList could be loaded with this so iterate, and
	# this doesn't modify $req's value of Model.TupleUseList
	Bivio::Biz::Model->new($req, 'TupleUseList')->map_iterate(
	    sub {
		my($it) = @_;
		return {
		    task_id => 'FORUM_TUPLE_LIST',
		    label => String($it->get('TupleUse.label')),
		    query => {
			'ListQuery.parent_id' => $it->get(
			    'TupleUse.tuple_def_id'),
		    },
		};
	    }
	),
    };
}

sub vs_user_email_list {
    my($proto, $model, $other_cols, $other_tools) = @_;
    view_put(
        $other_tools ? (xhtml_tools => Join([@$other_tools])) : (),
	xhtml_body => $proto->vs_paged_list(
	    $model => [
		[display_name => {
		    column_order_by => Bivio::Biz::Model->get_instance($model)
			->NAME_SORT_COLUMNS,
		    want_sorting => 1,
		    wf_list_link => {
			href => URI({
			    query => [qw(->format_query THIS_DETAIL)],
			    task_id => Bivio::IO::Config->if_version(10,
				sub {If(
				    [['->req'], '->is_super_user'],
				    'ADM_SUBSTITUTE_USER',
				    'SITE_ADMIN_SUBSTITUTE_USER',
				)},
				sub {'ADM_SUBSTITUTE_USER'},
			    ),
			    realm => vs_constant('site_admin_realm_name'),
			}),
			control => Or(
			    [['->req'], '->is_super_user'],
			    ['->can_substitute_user'],
			),
		    },
		}],
		'Email.email',
		@{$other_cols || []},
	    ]),
    );
    return;
}

sub vs_xhtml_title {
    return Join(
	[
	    SPAN_realm(
		String([qw(auth_realm owner display_name)]),
		{
		    control => vs_realm_type('forum'),
		},
	    ),
	    vs_text_as_prose('xhtml_title'),
	],
	{join_separator => ' '},
    );
}

sub _canonical_link {
    return LINK({
	REL => 'canonical',
	HREF => URI({
	    require_absolute => 1,
	    query => [
		sub {
		    my($source) = @_;
		    my($query) = $source->ureq('query');
		    if (ref($query) eq 'HASH') {
			foreach my $key (@$_DYNAMIC_QUERY_KEYS) {
			    delete($query->{$key});
			}
		    }
		    return $query;
		},
	    ],
	}),
    });
}

sub _format_integer_ago {
    my($int, $unit) = @_;
    return join(' ', $int, $int == 1 ? $unit : $unit . 's', 'ago');
}

sub _has_submit {
    my($proto, $rows) = @_;
    return grep(
	ref($_) ? Bivio::UNIVERSAL->is_blesser_of($_)
	    ? $_->simple_package_name eq 'StandardSubmit'
	    : ref($_) eq 'ARRAY' && _has_submit($proto, $_)
	    : $_ =~ /^\*/, @$rows) ? 1 : 0;
}

1;
