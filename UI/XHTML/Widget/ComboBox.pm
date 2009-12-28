# Copyright (c) 2009 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::ComboBox;
use strict;
use Bivio::Base 'Widget.Join';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_JS) = b_use('HTMLWidget.JavaScript');
my($_QV) = b_use('JavaScriptWidget.QuotedValue');
my($_PREFIX) = 'window.bivio.combobox';

sub initialize {
    my($self) = @_;
    return
	if $self->is_initialized;
    $self->initialize_attr(size => 50);
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
    $self->put(values => [
	Script('common'),
	Script('b_combo_box'),
	$self->unsafe_get('hint_text')
	    ? ClearOnFocus(_text($self), $self->get('hint_text'))
	    : _text($self),
	BR(),
	EmptyTag(div => {
	    CLASS => 'cb_menu',
	    ID => _drop_down_id($self),
	}),
    ]);
    return shift->SUPER::initialize(@_);
}

sub render {
    my($self, $source, $buffer) = @_;
    $_JS->render(
	$source,
	$buffer,
        $self->package_name
	    . '.'
	    . $self->render_simple_attr('list_class', $source),
	${$self->render_attr('_list', $source)},
    );
    return shift->SUPER::render(@_);
}

sub _drop_down_id {
    my($self) = @_;
    return [sub {
        my($source, $field) = @_;
	$field =~ s/\W//g;
	return 'combobox_drop_down_'
	    . $field
	    . ($source->can('get_list_model')
		   ? '_' . $source->get_list_model->get_cursor
		   : '');
    }, $self->get('field')];
}

sub _text {
    my($self) = @_;
    return Text($self->get('field'), {
	ONKEYDOWN => Join([
	    "return $_PREFIX.key_down(event.keyCode, this, {",
	    'dd_name: "',
	    _drop_down_id($self),
	    '",',
	    If($self->unsafe_get('auto_submit'),
	       'auto_submit: true,'),
	    'dd_values: ',
	    _var_name($self),
	    '})',
	]),
	ONKEYUP => "return $_PREFIX.key_up(event.keyCode, this)",
	AUTOCOMPLETE => 'off',
	size => $self->get('size'),
    });
}

sub _var_name {
    return "$_PREFIX.list_" . shift->get('list_class');
}

1;
