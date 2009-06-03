# Copyright (c) 2009 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::ComboBox;
use strict;
use Bivio::Base 'Widget.Join';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_JS) = b_use('HTMLWidget.JavaScript');
my($_SCRIPT) = <<'EOF';
window.bivio = window.bivio || {};

(function (){

window.bivio.combobox = window.bivio.combobox || {};
var selected = null;
var active_timer;

window.bivio.combobox.key_down = function(key, field, drop_down_name, values) {
    if (! field.drop_down)
        init_drop_down(field, document.getElementById(drop_down_name), values);
    field.key_code = key;
    // tab
    if (key == 9)
        field.clear_list();
    else if (key == 38 || key == 40) {
        select_next_item(key == 38, field);
        set_timeout(field, 300);
    }
    // enter
    return key == 13 ? false : true;
}

window.bivio.combobox.key_up = function(key, field) {
    if (active_timer)
        window.clearTimeout(active_timer);
    if (! field.drop_down)
        return;

    // enter
    if (key == 13) {
        save_selected(field);
        return true;
    }
    // up/down arrows
    else if (key == 38 || key == 40)
	return true;
    field.clear_list();

    // escape
    if (key == 27)
	return true;
    populate_search(field);

    var drop_down = field.drop_down;
    if (drop_down.childNodes.length > 0) {

        if (drop_down.childNodes.length == 1
            && field.value == drop_down.childNodes[0].real_value) {
            return true;
        }
        drop_down.style.visibility = 'visible';
        document.onclick = function() {
            field.clear_list();
        }
    }
    return true;
}

function init_drop_down(field, drop_down, values) {
    drop_down.style.width = field.clientWidth + 'px';
    field.drop_down = drop_down;
    field.drop_down_values = values;
    field.clear_list = function() {
        set_selected(null);
        var drop_down = this.drop_down;
        if (! drop_down)
            return;
        while (drop_down.firstChild)
	    drop_down.removeChild(drop_down.firstChild);
        if (drop_down.style.visibility == 'visible')
            drop_down.style.visibility = 'hidden';
    }
    field.clear_list();
}

function populate_search(field) {
    var search = field.value;
    if (! search.length)
	return true;

    for (var i = 0; i < field.drop_down_values.length; i++) {
	var v = field.drop_down_values[i];
        if (! v) continue;

        if (search.length == 1) {
            if (v.toLowerCase().indexOf(search.toLowerCase()) != 0)
                continue;
        }
	else if (v.toLowerCase().indexOf(search.toLowerCase()) < 0)
	    continue;
	var d = document.createElement("div");
	d.style.cursor = 'default';
	d.onmouseover = function(e) {
	    set_selected(this);
	};
	d.onclick = function() {
	    save_selected(field);
	}
	d.innerHTML = v;
	d.real_value = v;
	field.drop_down.appendChild(d);
    }
}

function save_selected(field) {
    if (selected)
        field.value = selected.real_value;
    field.clear_list();
}

function select_next_item(prev, field) {
    var n;
    var drop_down = field.drop_down;
    if (! drop_down)
        return;
    if (selected)
	n = prev ? selected.previousSibling : selected.nextSibling;
    else if (prev)
        return;
    else
	n = drop_down.firstChild;
    if (n) {
	set_selected(n);
	field.value = n.real_value;
    }
    return;
}

function set_selected(item) {
    if (item)
        item.style.backgroundColor = 'aqua';
    if (selected)
	selected.style.backgroundColor = 'white';
    selected = item;
}

function set_timeout(field, count) {
    if (active_timer)
        window.clearTimeout(active_timer);
    active_timer = window.setTimeout(function() {
        set_timeout(field, 150);
        select_next_item(field.key_code == 38, field);
    }, count);
}

})();
EOF


sub initialize {
    my($self) = @_;
    my($var_name) = $self->get('list_class');
    $self->initialize_attr(list => Join([
	"var $var_name = [\n",
	List($self->get('list_class'), [
	    _quoted_value([$self->get('list_display_field')]),
	]),
	"\n];\n",
    ]));
    $self->put_unless_exists(values => [
	Text($self->get('field'))->put(
	    ONKEYDOWN => Join([
		'return window.bivio.combobox.key_down(event.keyCode, this,',
		' "', _drop_down_id(), '",',
		$var_name, ')',
	    ]),
	    ONKEYUP => "return window.bivio.combobox.key_up(event.keyCode, this)",
	    size => 50,
	),
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
	join('.', __PACKAGE__, $self->get('list_class')),
	${$self->render_attr('list', $source)});
    $_JS->render($source, $buffer, __PACKAGE__, $_SCRIPT);
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

sub _quoted_value {
    my($value) = @_;
    return [sub {
        my(undef, $value) = @_;
	$value =~ s/"/\\"/g;
	return "\"$value\",\n";
    }, $value];
}

1;
