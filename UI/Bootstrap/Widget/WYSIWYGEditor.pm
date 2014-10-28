# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Bootstrap::Widget::WYSIWYGEditor;
use strict;
use Bivio::Base 'XHTMLWidget.Join';
b_use('UI.ViewLanguageAUTOLOAD');

my($_DIV_ID) = 'bootstrap_wysiwyg';

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(values => [
	LocalFileAggregator({
	    widget_values => [
		'bootstrap-wysiwyg/bootstrap-wysiwyg.min.js',
		'jquery-hotkeys/jquery-hotkeys.min.js',
	    ],
	}),
	LocalFileAggregator({
	    widget_values => [
		InlineJavaScript(
		    Join([
			<<'EOF',
(function($, wysiwyg_div_id, form_field_name) {
  var wysiwyg_field = $("#" + wysiwyg_div_id);
  var form_field = $('textarea[name="' + form_field_name + '"]');
  wysiwyg_field.wysiwyg();
  wysiwyg_field.html(form_field.val());
  $(document).ready(function() {
    wysiwyg_field.closest('form').submit(function(event) {
      form_field.val(wysiwyg_field.html());
    });
  });
  $('.dropdown-menu input')
    .click(function() {return false;})
    .change(function () {$(this)
    .parent('.dropdown-menu')
    .siblings('.dropdown-toggle')
    .dropdown('toggle');})
    .keydown('esc', function () {this.value='';$(this).change();});
})(jQuery,
EOF
			JavaScriptString($_DIV_ID),
			', ',
			JavaScriptString([
			    sub {
				my($source) = @_;
				my($form) = $source->ureq('form_model');
				return $form
				    ->get_field_name_for_html($self->get('field'))
					if $form;
				return '';
			    },
			]),
			");\n",
		    ])
		),
	    ],
	}),
	TextArea({
	    field => $self->get('field'),
	    STYLE => 'display: none;',
	}),
	DIV(
	    Join([
		DIV(
		    DIV(
			Join([
			    _button_groups(
				[
				    'DropDownIconButton',
				    [qw(font Font), [map(
					A($_, {
					    'DATA-EDIT' => "fontName $_",
					    STYLE => "font-family: $_",
					}),
					'Serif',
					'Sans',
					'Arial',
					'Arial Black',
					'Courier',
					'Courier New',
					'Comic Sans MS',
					'Helvetica',
					'Impact',
					'Lucida Grande',
					'Lucida Sans',
					'Tahoma',
					'Times',
					'Times New Roman',
					'Verdana',
				    )]],
				],
				[
				    'DropDownIconButton',
				    ['text_height', 'Text Height', [map(
					A($_, {
					    'DATA-EDIT' => "fontSize ${_}px",
					    STYLE => "font-size: ${_}px",
					}),
					qw(8 9 10 12 14 16 18 20 24 30 36),
				    )]],
				],
				[qw(IconButton bold italic underline strike)],
				[
				    'IconButton',
				    ['list_ul', 'Unordered List', 'insertunorderedlist'],
				    ['list_ol', 'Ordered List', 'insertorderedlist'],
				],
				[qw(IconButton indent outdent)],
				[
				    'IconButton',
				    ['align_left', 'Left', 'justifyleft'],
				    ['align_center', 'Center', 'justifycenter'],
				    ['align_right', 'Right', 'justifyright'],
				    ['align_justify', 'Justify', 'justifyfull'],
				],
				[
				    'DropDownIconButton',
				    ['link', 'Link', DIV(
					DIV(
					    Join([
						INPUT({
						    class => 'form-control',
						    PLACEHOLDER => 'URL',
						    TYPE => 'text',
						    'DATA-EDIT' => 'createLink',
						}),
						SPAN(
						    BUTTON('Add', {
							class => 'btn btn-default',
							TYPE => 'button',
							UNSELECTABLE => 'on',
						    }),
						    {
							class => 'input-group-btn',
						    },
						),
					    ]),
					    {
						class => 'input-group',
					    },
					),
					{
					    class => 'dropdown-menu',
					},
				    )],
				],
				[qw(IconButton unlink)],
				[
				    'IconButton',
				    [qw(arrow_ccw Undo undo)],
				    [qw(arrow_cw Redo redo)],
				],
			    ),
			]),
			{
			    class => "btn-toolbar",
			    role => 'toolbar',
			    'DATA-ROLE' => "editor-toolbar",
			    'DATA-TARGET' => "#$_DIV_ID",
			},
		    ),
		    {
			class => 'panel-heading ',
		    },
		),
		DIV('', {
		    class => 'panel-body',
		    ID => $_DIV_ID,
		    STYLE => 'height: 24em; overflow: scroll;',
		}),
	    ]),
	    {
		class => 'panel panel-default',
	    },
	),
    ]);
    return shift->SUPER::initialize(@_);
}

sub _button_groups {
    return map({
	my($items) = $_;
	my($widget) = \&{shift($items)};
	ButtonGroup([
	    map({
		my($i) = $_;
		$i = [$i, ucfirst($i), $i]
		    unless ref($i);
		$i->[2] = {
		    data_edit => $i->[2],
		} unless ref($i->[2]);
		$widget->(@$i);
	    } @$items),
	]);
    } @_);
}

1;
