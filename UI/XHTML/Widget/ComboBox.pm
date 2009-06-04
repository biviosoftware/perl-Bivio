# Copyright (c) 2009 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::ComboBox;
use strict;
use Bivio::Base 'Widget.Join';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_JS) = b_use('HTMLWidget.JavaScript');

sub initialize {
    my($self) = @_;
    my($var_name) = 'window.bivio.combobox.list_' . $self->get('list_class');
    return if $self->unsafe_get('list');
    $self->initialize_attr(list => Join([
	"$var_name = [",
	List($self->get('list_class'), [
	    b_use('JavaScriptWidget.QuotedValue')
	        ->new([$self->get('list_display_field')]),
	    ])->put(row_separator => ','),
	"];\n",
    ]));
    $self->initialize_attr(size => 50);
    my($text) = Text($self->get('field'), {
	ONKEYDOWN => Join([
	    'return window.bivio.combobox.key_down(event.keyCode, this, {',
	        'dd_name: "', _drop_down_id(), '",',
	        $self->unsafe_get('auto_submit')
	            ? 'auto_submit: true,' : (),
	        'dd_values: ', $var_name, '})',
	]),
	ONKEYUP => "return window.bivio.combobox.key_up(event.keyCode, this)",
	AUTOCOMPLETE => 'off',
	size => $self->get('size'),
    });
    $self->put(values => [
	Script('common'),
	Script('b_combo_box'),
	$self->unsafe_get('hint_text')
	    ? ClearOnFocus($text, $self->get('hint_text'))
	    : $text,
	BR(),
	Tag(div => Simple(' '), {
	    CLASS => 'dd_menu',
	    ID => _drop_down_id(),
	}),
    ]);
    return shift->SUPER::initialize(@_);
}

sub render {
    my($self, $source, $buffer) = @_;
    $_JS->render($source, $buffer,
	join('.', $self->package_name, $self->get('list_class')),
	${$self->render_attr('list', $source)});
    return shift->SUPER::render(@_);
}

sub _drop_down_id {
    return [sub {
        my($source) = @_;
	my($id) = 'combobox_drop_down';
	if ($source->can('get_list_model')) {
	    $id .= '_' . $source->get_list_model->get_cursor;
	}
	return $id;
    }];
}

1;
