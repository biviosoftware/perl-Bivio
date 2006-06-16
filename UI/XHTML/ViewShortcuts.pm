# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::ViewShortcuts;
use strict;
use base 'Bivio::UI::HTML::ViewShortcuts';
use Bivio::UI::HTML::WidgetFactory;
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
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
	[sub {
	     return Bivio::Biz::Action->get_instance('Acknowledgement')
		 ->extract_label(shift->get_request);
	}],
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
    my(undef, $list_model) = @_;
    return Tag(div => Join([
	map(
	    Link(
	        String($_),
		URI({
		    query => ["Model.$list_model", '->format_query', 'ANY_LIST',
			      $_ eq 'All' ? () : {search => $_}],
		}),
		[sub {
		     my(undef, $a, $search) = @_;
		     return join(' ',
			  $a eq 'All' ? 'all' : $a eq 'a' ? '' : 'want_sep',
			  (lc($search || '') || 'All') eq $a ? 'selected' : (),
		     );
		},
		    $_,
		    [["Model.$list_model", '->get_query'], 'search'],
	        ],
	    ),
	    'a'..'z', 'All',
	),
    ]), 'alphabetical_chooser');
}

sub vs_descriptive_field {
    my($proto, $field) = @_;
    my($name, $attrs) = ref($field) ? @$field : $field;
    $attrs ||= {};
    $name =~ /^(\w+)\.(.+)/;
    my($label, $input) = UNIVERSAL::isa(
	Bivio::Biz::Model->get_instance($1)->get_field_type($2),
	'Bivio::Type::Boolean',
    ) ? (Simple(''), FormField($name))
	: $proto->vs_form_field($name, $attrs);
    return [
	$label->put(cell_class => 'label'),
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
		     '<br />',
		     Tag(p => Prose($v), 'desc'),
		 ]) :  '';
	    }, $proto, $name],
	], {
	    cell_class => 'field',
	    $attrs->{row_control} ? (row_control => $attrs->{row_control})
		: (),
	}),
    ];
}

sub vs_empty_list_prose {
    my($self, $model) = @_;
    return Tag(
	div => Prose(vs_text("$model.empty_list_prose")), 'empty_list');
}

sub vs_form_error_title {
    my($proto, $form) = @_;
    return Tag(
	div => String(vs_text('form_error_title')),
	'err_title',
	{control => [['->get_request'], "Model.$form", '->in_error']},
    );
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
    my($proto, $form, $columns, $empty_list, $buttons, $table_attrs) = @_;
    my($f) = Bivio::Biz::Model->get_instance($form);
    my($l) = Bivio::Biz::Model->get_instance($f->get_list_class);
    my($res) = Form(
	$form,
	Join([
	    $proto->vs_form_error_title($form),
	    Table($form => [
		map({
		    $_ = ref($_) eq 'ARRAY' ? {
			field => $_->[0],
			$_->[1] ? %{$_->[1]} : (),
		    } : {field => $_}
			unless ref($_) eq 'HASH';
		    $_->{column_class} ||= 'field';
		    # So checkboxes don't have labels in the fields, just hdr
		    $_->{label} = ''
			unless exists($_->{label});
		    $_;
		} @$columns),
	    ], $proto->vs_table_attrs($form, list => $table_attrs),
	    ),
	    $buttons ? $buttons : Tag(
		'div',
		# cell_class tells StandardSubmit to produce XHTML
		StandardSubmit({cell_class => 'button'}),
		'submit',
	    ),
	])
    );
    return $empty_list ? If(
	[$f->get_list_class, '->get_result_set_size'],
	$res,
	Tag(div => $empty_list, 'empty_list'),
    ) : $res;
}

sub vs_paged_detail {
    my(undef, $model, $list_uri_args, $detail) = @_;
    my($x) = "Model.$model";
    my($p) = "$model.paged_detail.";
    view_put(pager => Tag(div => Join([
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
    my($x) = "Model.$model";
    my($p) = "$model.paged_list.";
    view_put(pager => Tag(div => Join([
	map(
	    Link(
		vs_text("$p$_"),
		[$x, '->format_uri', uc($_) . '_LIST'], {
		    control => [[$x, '->get_query'], "has_$_"],
		    control_off_value => Tag(
			span => String(vs_text("$p$_")), "$_ off"),
		    class => $_,
		},
	    ),
	    qw(prev next)
	),
    ]), 'pager'));
    return Table(
	$model,
	$columns,
	$proto->vs_table_attrs($model, paged_list => $attrs),
    ),
}

sub vs_phone {
    my($proto) = @_;
    return $proto->vs_call(Join => [$proto->vs_text('support_phone')]);
}

sub vs_prose {
    my(undef, $prose) = @_;
    return Tag(div => Prose($prose), 'prose');
}

sub vs_simple_form {
    my($proto, $form, $rows) = @_;
    my($have_submit) = 0;
    my($m) = Bivio::Biz::Model->get_instance($form);
    return Form(
	$form,
	Join([
	    $proto->vs_form_error_title($form),
	    Grid([
		map({
		    my($x);
		    if (UNIVERSAL::isa($_, 'Bivio::UI::Widget')
			&& $_->simple_package_name eq 'FormField'
		    ) {
			$_->put_unless_exists(cell_class => 'field'),
			$x = [
			    $proto->vs_call('Join', [''], {cell_class => 'label'}),
			    $_,
			];
		    }
		    elsif (UNIVERSAL::isa($_, 'Bivio::UI::Widget')) {
			$x = [$_->put_unless_exists(cell_colspan => 2)];
		    }
		    elsif ($_ =~ s/^-//) {
			$x = [String(
			    vs_text($form, 'separator', $_),
			    0,
			    {
				cell_colspan => 2,
				cell_class => 'sep',
			    },
			)];
		    }
		    elsif ($_ =~ s/^\*//) {
			$have_submit = 1;
			$x = [StandardSubmit(
			    {
				cell_colspan => 2,
				cell_class => 'submit',
				$_ ? (buttons => [split(/\s+/, $_)]) : (),
			    },
			)];
		    }
		    elsif (ref($_) eq 'ARRAY' && ref($_->[0])) {
			$x = $_;
		    }
		    else {
			$x = $proto->vs_descriptive_field($_);
		    }
		    $x;
		} @$rows),
		$have_submit ? () : [
		    StandardSubmit({
			cell_colspan => 2,
			cell_class => 'submit',
		    }),
		],
	    ], {
		class => 'simple',
	    }),
	]),
    );
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
	$proto->vs_table_attrs($model, tree_list => $attrs),
    );
}

sub vs_tree_list_control {
    my($proto, $model, $c) = @_;
    $c = ref($c) ? {field => $c->[0], %{$c->[1] || {}}} : {field => $c}
	unless ref($c) eq 'HASH';
    return {
	%$c,
	column_widget => Join([
	    [sub {
		 return '<span class="sp" />'
		     x shift->get_list_model->get('node_level');
	    }],
	    If([['->get_list_model'], 'node_uri'],
	       map({
		   my($x) = Join([
		       Image(vs_text([
			   sub {
			       my($lm) = shift->get_list_model;
			       return $lm->simple_package_name
				   . '.' . $lm->get('node_state')->get_name;
			   },
		       ])),
		       Tag(span =>
		           ($c->{column_widget}
			       || Bivio::UI::HTML::WidgetFactory->create(
			       $model . '.' . $c->{field}, $c)),
			   'name',
		       ),
		   ]);
		   $_ ? Link($x, [['->get_list_model'], 'node_uri']) : $x;
	       } 1, 0),
	   ),
	]),
	column_data_class => 'node',
    };
}

1;
