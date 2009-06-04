# Copyright (c) 2005-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::Script;
use strict;
use Bivio::Base 'UI.Widget';

# C<Bivio::UI::HTML::Widget::Script> is called with a script name, which
# is rendered in the head.   Currently, only scripts that are constants,
# called JAVASCRIPT_I<script_name> are allowed.  The script must have an
# onload function called I<script_name>_onload.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

sub JAVASCRIPT_B_SUBMENU_IE6 {
    return <<'EOF';
function b_submenu_ie6_onload() {
    if (document.getElementsByTagName) {
        var divs = document.getElementsByTagName('div');
        var H = 'hover';
        for (var i=0; i < divs.length; i++) {
            if (divs[i].className.indexOf('b_submenu') >= 0) {
                var b_menu = divs[i].parentNode;
                b_menu.onmouseout = function () {
                    b_remove_class(this, H);
                };
                b_menu.onmouseover = function () {
                    b_add_class(this, H);
                };
            }
        }
    }
}
EOF
}

sub JAVASCRIPT_B_CLEAR_ON_FOCUS {
    return <<'EOF';
function b_clear_on_focus(field, hint) {
    if (field.value == hint) {
        field.value = "";
    }
    field.className = field.className.replace(/disabled/, "enabled");
    return;
}
EOF
}

sub JAVASCRIPT_B_COMBO_BOX {
    return <<'EOF';
(function (){

window.bivio = window.bivio || {};
window.bivio.combobox = window.bivio.combobox || {};
var selected = null;
var active_timer;
var key_codes = {
  TAB: 9,
  ENTER: 13,
  ESCAPE: 27,
  UP_ARROW: 38,
  DOWN_ARROW: 40
};

window.bivio.combobox.key_down = function(key, field, init_values) {
    if (! field.drop_down)
        init_drop_down(field, init_values);
    field.key_code = key;

    if (key == key_codes.TAB)
        field.clear_list();
    else if (key == key_codes.UP_ARROW || key == key_codes.DOWN_ARROW) {
        select_next_item(key == key_codes.UP_ARROW, field);
        set_timeout(field, 300);
    }
    if (field.drop_down.style.visibility == 'visible')
        return key == key_codes.ENTER ? false : true;
    return true;
}

window.bivio.combobox.key_up = function(key, field) {
    if (active_timer)
        window.clearTimeout(active_timer);
    if (! field.drop_down)
        return true;

    if (key == key_codes.ENTER) {
        save_selected(field);
        return true;
    }
    else if (key == key_codes.UP_ARROW || key == key_codes.DOWN_ARROW)
	return true;
    field.clear_list();

    if (key == key_codes.ESCAPE) {
        if (field.typed_value)
            field.value = field.typed_value;
	return true;
    }
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

function init_drop_down(field, init_values) {
    var drop_down = document.getElementById(init_values.dd_name);

    drop_down.style.width = field.clientWidth + 'px';
    field.drop_down = drop_down;
    field.auto_submit = init_values.auto_submit;
    field.drop_down_values = init_values.dd_values;
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
    field.typed_value = search;
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
    if (selected) {
        field.value = selected.real_value;
        field.typed_value = field.value;
    }
    field.clear_list();
    if (field.auto_submit)
        field.form.submit();
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
        b_add_class(item, 'cb_selected');
    if (selected)
        b_remove_class(selected, 'cb_selected');
    selected = item;
}

function set_timeout(field, count) {
    if (active_timer)
        window.clearTimeout(active_timer);
    active_timer = window.setTimeout(function() {
        set_timeout(field, 150);
        select_next_item(field.key_code == key_codes.UP_ARROW, field);
    }, count);
}

})();
EOF
}

sub JAVASCRIPT_COMMON {
    return <<'EOF';
function b_remove_class (element, clazz) {
    var res = [], classes = element.className.split(/\s+/);
    for (var i = 0, length = classes.length; i < length; i++) {
        if (classes[i] != clazz) {
            res.push(classes[i]);
        }
    }
    element.className = res.join(' ');
}
function b_add_class (element, clazz) {
    if (element.className.indexOf(clazz) < 0) {
        element.className += (element.className ? ' ' : '') + clazz;
    }
}
function b_toggle_class (element, clazz) {
    if (element.className.indexOf(clazz) < 0) {
        b_add_class(element, clazz);
    }
    else {
        b_remove_class(element, clazz);
    }
}
EOF
}

sub JAVASCRIPT_CORRECT_TABLE_LAYOUT_BUG {
    # Adds newline to html body to cause the browser to layout the table
    # again. Works around mozilla/firefox layout bug.
    return <<'EOF';
function correct_table_layout_bug_onload() {
    if (navigator.appName == "Netscape")
      document.body.innerHTML += "\n";
}
EOF
}

sub JAVASCRIPT_FIRST_FOCUS {
    # Forces focus to first text input field, if there is one.
    return <<'EOF';
function first_focus_onload() {
    for (var i = 0; i < document.forms.length; i++) {
        var fields = document.forms[i].elements;
        for (var j = 0; j < fields.length; j++) {
            if ((fields[j].type == 'text'
                || fields[j].type == 'textarea')
                && !fields[j].onfocus
            ) {
                try {
                    fields[j].focus();
                } catch (err) {}
                return;
            }
        }
    }
}
EOF
}

sub JAVASCRIPT_B_THUMBNAIL_POPUP {
    return <<'EOF';
function b_thumbnail_popup_onload() {
    for (var i=0; i < document.links.length; i++) {
        var A = document.links[i];
        if (A.className.indexOf('b_thumbnail_popup') >= 0) {
            var img = document.createElement('img');
            img.src = A.href;
            b_add_class(img, A.className);
            b_add_class(img, 'b_hide');
            b_remove_class(img, 'b_thumbnail_popup');
            A.href = '#';
            A.onclick = function () {
                b_toggle_class(this.firstChild, 'b_hide');
                if (document.body.filters) { /* IE only */
                    var v = document.getElementById('b_video');
                    if (v) {
                        b_toggle_class(v, 'b_hide');
                    }
                }
                return false;
            }
            A.insertBefore(img, A.firstChild);
        }
        A = null;
    }
}
EOF
}

sub JAVASCRIPT_PAGE_PRINT {
    return 'function page_print_onload(){window.print()}';
}

sub initialize {
    my($self) = @_;
    $self->unsafe_initialize_attr('value');
    return;
}

sub internal_new_args {
    my($proto, $value, $attrs) = @_;
    return {
	($value ? (value => $value) : ()),
	($attrs ? %$attrs : ()),
    };
}

sub render {
    my($self, $source, $buffer) = @_;
    my($req) = $source->get_request;
    if ($self->has_keys('value')) {
	if (my $x = $self->render_simple_attr('value', $source)) {
	    $x = 'JAVASCRIPT_' . uc($x);
	    $self->die('value', $source, $x, ': no such script')
		unless $self->can($x);
	    my($names) = $req->get_if_exists_else_put(__PACKAGE__, []);
	    push(@$names, $x)
		unless grep($x eq $_, @$names);
	}
	return;
    }
    my($names) = $req->unsafe_get(__PACKAGE__);
    return
	unless $names;
    $req->delete(__PACKAGE__);

    my($js) = $_VS->vs_call('JavaScript');
    my($functions) = [map($js->strip($self->$_()), @$names)];
    $$buffer .= join(
	"\n",
	qq{<script type="text/javascript">\n<!--},
	@$functions,
	_onload($functions),
	"// --></script>",
	'',
    );
    return;
}

sub _onload {
    my($functions) = @_;
    my($onload) = [map(/^function\s+(\w+_onload)\s*\(/mg, @$functions)];
    return !@$onload ? () : (
	'window.onload=function(){',
	map($_ . '();', @$onload),
	'}',
    );
}

1;
