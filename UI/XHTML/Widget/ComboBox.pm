# Copyright (c) 2009-2010 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::ComboBox;
use strict;
use Bivio::Base 'Widget.Join';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_JS) = b_use('HTMLWidget.JavaScript');
my($_QV) = b_use('JavaScriptWidget.QuotedValue');
my($_PREFIX) = 'window.bivio.combobox';

sub initialize {
    my($self) = @_;
    return
	if $self->is_initialized;
    $self->initialize_attr(auto_submit => 0);
#TODO: Make size dynamic to fit given list items
    $self->initialize_attr(size => 80);
#TODO: Add list_id_field like Select().  See Pethop AdmSubstituteUserForm.
    my($ldf) = $self->initialize_attr('list_display_field');
    $self->put_unless_exists(
	_list => Join([
	    _var_name($self) . ' = [',
	    List(
		$self->get('list_class'),
#TODO: Find all places which pass list_display_field and fix to be list_display_value
		[$_QV->new(ref($ldf) ? $ldf : [$ldf])],
	    )->put(row_separator => ','),
	    "];\n",
	]),
    );
    $self->put(_html_id => JavaScript()->unique_html_id());
    $self->put(values => [
	Script('common'),
	Script('b_combo_box'),
	$self->unsafe_get('hint_text')
	    ? ClearOnFocus(_text($self), $self->get('hint_text'))
	    : _text($self),
	DIV_cb_arrow(vs_text_as_prose('combo_box_arrow'),
	{
	    ONMOUSEDOWN => Join([
		"return $_PREFIX.arrow_mouse_down(this, {",
		_init_values($self),
		"})",
	    ]),
	    ONMOUSEUP => "return $_PREFIX.arrow_mouse_up(this)",
	    ONSELECTSTART => 'return false',
	}),
	BR(),
	EmptyTag(div => {
	    CLASS => 'cb_menu',
	}),
    ]);
    return shift->SUPER::initialize(@_);
}

sub internal_cb_size {
    my($self) = @_;
    return $self->get('size');
}

sub internal_cb_text_class {
    return 'cb_text';
}

sub render {
    my($self, $source, $buffer) = @_;
    my($module_tag) = $self->package_name
	. '.' . $self->render_simple_attr('list_class', $source);
    $_JS->render(
    	$source,
    	$buffer,
	$module_tag,
    	${$self->render_attr('_list', $source)},
    ) unless $_JS->has_been_rendered($source, $module_tag);
    return shift->SUPER::render(@_);
}

sub _init_values {
    my($self) = @_;
    return (
	If($self->unsafe_get('auto_submit'),
	   'auto_submit: true,'),
	'dd_values: ',
	_var_name($self),
    );
}

sub _text {
    my($self) = @_;
    return Text($self->get('field'), {
	ONKEYDOWN => Join([
	    "return $_PREFIX.key_down(event.keyCode, this, {",
	    _init_values($self),
	    '})',
	]),
	ONKEYUP => "return $_PREFIX.key_up(event.keyCode, this)",
	AUTOCOMPLETE => 'off',
	size => $self->internal_cb_size,
	class => $self->internal_cb_text_class,
	%{$self->unsafe_get('text_attrs') || {}},
    });
}

sub _var_name {
    return "$_PREFIX.list_" . shift->get('list_class');
}

1;
