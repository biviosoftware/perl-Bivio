# Copyright (c) 2005-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::ViewShortcuts;
use strict;
use Bivio::Base 'UIHTML.ViewShortcuts';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FF) = __PACKAGE__->use('HTMLWidget.FormField');
my($_W) = __PACKAGE__->use('UI.Widget');
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
my($_AA) = __PACKAGE__->use('Action.Acknowledgement');
my($_M) = b_use('Biz.Model');
my($_WF) = b_use('UIHTML.WidgetFactory');
my($_SUBMIT_CHAR) = '*';

sub view_autoload {
    my(undef, $method, $args) = @_;
    return Tag($1, @$args ? @$args : ('', {tag_if_empty => 1}))
	->put_unless_exists($2 ? (class => $2) : ())
	if $method =~ /^($_HTML_TAGS)?(?:_([a-z0-9_]{2,}))?$/os;
    return shift->SUPER::view_autoload(@_);
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
			 Bivio::UI::Text->get_value(
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
    my($name, $attrs) = ref($field) ? @$field : $field;
    $attrs ||= {};
    $name =~ /^(\w+)\.(.+)/;
    my($label, $input) = !$attrs->{wf_type}
	&& !$attrs->{wf_class}
	&& Bivio::Biz::Model->get_instance($1)->get_field_type($2)
	    ->isa('Bivio::Type::Boolean') ? (
	    undef,
	    FormField($name, $attrs),
	) : $proto->vs_form_field($name, $attrs);
    return [
	$label ? ($label->put(cell_class => 'label label_ok')) : (),
	Join([
	    $input,
	    [sub {
		 my($req) = shift->get_request;
		 my($proto, $name) = @_;
#TODO: Need to create a separate space for field_descriptions so we don't
#      default to something that we don't expect.
		 my($v) = $req->get_nested('Bivio::UI::Facade', 'Text')
		     ->unsafe_get_value($name, 'desc');
		 return $v ? Join([
		     EmptyTag('BR'),
		     Tag(p => Prose($v), 'desc'),
		 ]) :  '';
	    }, $proto, $name],
	], {
	    cell_class => 'field',
	    $label ? () : (cell_colspan => 2),
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

sub vs_grid3 {
    my(undef, $qualifier) = @_;
    return Grid([[
	map(
	    Join([
		view_widget_value("xhtml_${qualifier}_$_"),
	    ], {cell_class => "${qualifier}_$_"}),
	    qw(left middle right),
	),
    ]], {
	class => $qualifier,
	hide_empty_cells => 1,
    });
}

sub vs_can_group_bulletin_form {
    return [sub {
        my($req) = shift->req;
        return $req->can_user_execute_task('GROUP_BULLETIN_FORM')
	    && $req->can_user_execute_task('FORUM_MAIL_FORM');
    }];
}

sub vs_filter_query_form {
    my($proto, $form, $extra_columns, $attrs) = @_;
    return Form($form || 'FilterQueryForm', Grid([[
	$attrs->{text} || ClearOnFocus(Text({
	    field => 'b_filter',
	    id => 'b_filter',
	    size => int(b_use('Type.Line')->get_width / 2),
	}),
	    ['Model.' . ($form || 'FilterQueryForm'),
		'->clear_on_focus_hint']),
	@{$extra_columns || []},
	ScriptOnly({
	    widget => Simple(''),
	    alt_widget => FormButton('ok_button')->put(label => 'Refresh'),
	}),
    ]]), {
	form_method => 'get',
	want_timezone => 0,
	want_hidden_fields => 0,
    });
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
    my($proto, $form, $fields, $table_attrs) = @_;
    # Elements in $fields which are hash_refs or are "in_list" appear
    # as columns.  Elements which are arrays or are not "in_list" appear
    # as simple form entries.
    my($f) = Bivio::Biz::Model->get_instance($form);
    my($l) = Bivio::Biz::Model->get_instance($f->get_list_class);
    my($list) = [];
    return $proto->vs_simple_form($form => [
	map({
#TODO: Need to enapsulate this!
	    my($d) = $_;
	    my($t);
	    if (defined($d) && (
		ref($d) eq 'HASH' || !ref($d)
	        && $f->has_fields($d) && $f->get_field_info($d, 'in_list'))
	    ) {
		push(@$list, $d);
		$d = undef;
	    }
	    elsif (@$list) {
		$t = Table($form => [
		    map({
#TODO: Need to enapsulate this!
			my($x) = !ref($_) ? {field => $_} : $_;
			$x->{column_class} ||= 'field';
			# So checkboxes don't have labels in the fields, just hdr
			$x->{label} = ''
			    unless exists($x->{label});
			$x;
		    } @$list),
		], $proto->vs_table_attrs($form, list => $table_attrs));
		$list = [];
	    }
	    ($t ? $t : (), $d ? $d : ());
	} @$fields, undef),
    ]);
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

sub vs_prose {
    my(undef, $prose) = @_;
    return Tag(div => Prose($prose), 'prose');
}

sub vs_put_pager {
    my(undef, $model, $attrs) = @_;
    view_put(vs_pager => DIV_pager(Pager({
	list_class => $model,
	$attrs ? %$attrs : (),
    })));
    return;
}

sub vs_simple_form {
    my($proto, $form, $rows, $no_submit) = @_;
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
        unless $no_submit || _has_submit($proto, $rows);
    return Form(
	$form,
	Join([
	    $proto->vs_form_error_title($form),
	    Grid([
		map({
		    my($x);
		    if ($_FF->is_blessed($_)) {
			$_->put_unless_exists(cell_class => 'field'),
			$x = [
			    Simple('', {cell_class => 'label label_ok'}),
			    $_,
			];
		    }
		    elsif ($_W->is_blessed($_)) {
			$x = [$_->put_unless_exists(cell_colspan => 2)];
		    }
		    elsif ($_ =~ s/^-//) {
			$x = [Prose(vs_text($form, 'separator', $_), {
			    cell_colspan => 2,
			    cell_class => 'sep',
			})];
		    }
		    elsif ($_ =~ s/^\Q$_SUBMIT_CHAR//) {
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
	    ], {
		class => 'simple',
	    }),
	]),
    );
}

sub vs_simple_form_submit {
    my(undef, $fields) = @_;
    return $_SUBMIT_CHAR . join(' ', @{$fields || []});
}

sub vs_table_attrs {
    my($proto, $model, $class, $attrs) = @_;
    return {
	class => $class,
	even_row_class => 'even',
	odd_row_class => 'odd',
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
			query => 'THIS_DETAIL',
			task => Bivio::IO::Config->if_version(
			    5 => sub {'SITE_ADMIN_SUBSTITUTE_USER'},
			    sub {'ADM_SUBSTITUTE_USER'},
			),
		    },
		}],
		'Email.email',
		@{$other_cols || []},
	    ]),
    );
    return;
}

sub _has_submit {
    my($proto, $rows) = @_;
    return grep(
	ref($_) ? Bivio::UNIVERSAL->is_blessed($_)
	    ? $_->simple_package_name eq 'StandardSubmit'
	    : ref($_) eq 'ARRAY' && _has_submit($proto, $_)
	    : $_ =~ /^\*/, @$rows) ? 1 : 0;
}

1;
