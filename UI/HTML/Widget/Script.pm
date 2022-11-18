# Copyright (c) 2005-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::Script;
use strict;
use Bivio::Base 'UI.Widget';

# C<Bivio::UI::HTML::Widget::Script> is called with a script name, which
# is rendered in the head.   Currently, only scripts that are constants,
# called JAVASCRIPT_I<script_name> are allowed.  The script must have an
# onload function called I<script_name>_onload.

my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

sub JAVASCRIPT_B_SUBMENU_IE6 {
    return <<'EOF';
function b_submenu_ie6_onload() {
    var div;
    while (div = b_element_by_class('div', 'b_submenu')) {
        var b_menu = div.parentNode;
        b_menu.onmouseout = function () {
            b_remove_class(this, 'hover');
        };
        b_menu.onmouseover = function () {
            b_add_class(this, 'hover');
        };
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

    if (key == key_codes.TAB) {
        if (field.drop_down.childNodes.length == 1) {
            set_selected(field.drop_down.firstChild);
        }
        save_selected(field);
    }
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
    populate_search(field, false);
    show_drop_down(field, false);

    return true;
}

window.bivio.combobox.arrow_mouse_down = function(arrow, init_values) {
    var field = b_get_sibling(arrow, false, 'INPUT');
    if (! field.drop_down)
        init_drop_down(field, init_values);
    return true;
}

window.bivio.combobox.arrow_mouse_up = function(arrow) {
    var field = b_get_sibling(arrow, false, 'INPUT');

    if (active_timer)
        window.clearTimeout(active_timer);

    var drop_down = field.drop_down;
    var list_items = drop_down.childNodes.length;
    if (! drop_down)
        return true;
    if (list_items) {
        field.clear_list();
        return true;
    }

    field.clear_list();
    populate_search(field, true);
    show_drop_down(field, true);

    return true;
}

function init_drop_down(field, init_values) {
    var arrow = b_get_sibling(field, true, 'DIV');
    var drop_down = b_get_sibling(arrow, true, 'DIV');
    drop_down.style.width = field.clientWidth + 'px';
    drop_down.style.left = (position(field, drop_down.offsetParent)[0] - 1) + 'px';
    field.drop_down = drop_down;
    field.auto_submit = init_values.auto_submit;
    field.setAttribute('autocomplete', 'off');
    field.drop_down_values = init_values.dd_values;
    field.clear_list = function() {
        var drop_down = this.drop_down;
        if (! drop_down)
            return;
        if (this.block_clear) {
            this.block_clear = false;
            return;
        }
        set_selected(null);
        while (drop_down.firstChild)
            drop_down.removeChild(drop_down.firstChild);
        if (drop_down.style.visibility == 'visible')
            drop_down.style.visibility = 'hidden';
    }
    field.clear_list();

    var ocf = document.onclick;
    document.onclick = function(e) {
        if (ocf) ocf(e);
        field.clear_list();
    }
}

function populate_search(field, show_all) {
    var search;
    search = show_all ? '' : field.value;
    field.typed_value = field.value;
    if (! search.length && ! show_all)
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
        d.innerHTML = b_escape_html(v);
        d.real_value = v;
        if (v == field.value)
            set_selected(d);
        field.drop_down.appendChild(d);
    }
}

function position(obj, commonParent) {
    var left = 0;
    var top = 0;
    if (obj.offsetParent) {
        do {
            left += obj.offsetLeft;
            top += obj.offsetTop;
        } while ((obj = obj.offsetParent) && obj != commonParent);
    }
    return [left, top];
}

function save_selected(field) {
    if (selected && field.typed_value != selected.real_value) {
        field.value = selected.real_value;
        field.typed_value = field.value;
        if (field.onchange)
          field.onchange();
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
    if (selected && selected != item)
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

function show_drop_down(field, block_clear) {
    var drop_down = field.drop_down;
    if (drop_down.childNodes.length > 0) {
        if (drop_down.childNodes.length == 1
            && field.value == drop_down.childNodes[0].real_value) {
            return;
        }
        drop_down.style.visibility = 'visible';
        field.block_clear = block_clear;
    }
}

})();
EOF
}

#TODO: Consolidate date functions with those in HTMLWidget.DateTime
sub JAVASCRIPT_B_DATE_PICKER {
    return <<'EOF';
function b_dp_stop_propagation(event) {
    if (!event) var event = window.event;
    event.cancelBubble = true;
    if (event.stopPropagation) event.stopPropagation();
}
function b_dp_set_day(form, field, id, date) {
    document.forms[form].elements[field].value
        = b_dp_n(date.getMonth() + 1) + '/' + b_dp_n(date.getDate()) + '/' + date.getFullYear();
    var holder = document.getElementById(id);
    b_remove_class(holder, 'dd_visible');
    b_add_class(holder, 'dd_hidden');
}
function b_dp_set_month(form, field, id, date, start_date, end_date) {
    var current_value = document.forms[form].elements[field].value;
    var selection = current_value ? b_dp_get_date(current_value) : null;
    if (!date) {
        current_value
            ? date = b_dp_get_date(current_value) : date = b_dp_get_date();
    }
    var today = b_dp_get_date();
    document.getElementById(id + '_month').innerHTML
        = b_dp_get_month_name(date) + ' ' + date.getFullYear();
    var left_arrow = document.getElementById(id + '_left_arrow');
    var prev_month = b_dp_get_bom(date);
    prev_month.setMonth(prev_month.getMonth() - 1);
    if (start_date && prev_month.getTime() < start_date.getTime()) {
        left_arrow.innerHTML = '&nbsp;';
        b_remove_class(left_arrow, 'b_dp_arrow');
        left_arrow.onclick = null;
    } else {
        left_arrow.innerHTML = '<';
        b_add_class(left_arrow, 'b_dp_arrow');
        left_arrow.onclick
            = (function(form, field, id, date, start_date, end_date) {
                return function() {
                    b_dp_set_month(form, field, id, date, start_date, end_date);
                };
            })(form, field, id, prev_month, start_date, end_date);
    }
    var right_arrow = document.getElementById(id + '_right_arrow');
    var next_month = b_dp_get_bom(date);
    next_month.setMonth(next_month.getMonth() + 1);
    if (end_date && next_month.getTime() > end_date.getTime()) {
        right_arrow.innerHTML = '&nbsp;';
        b_remove_class(right_arrow, 'b_dp_arrow');
        right_arrow.onclick = null;
    } else {
        right_arrow.innerHTML = '>';
        b_add_class(right_arrow, 'b_dp_arrow');
        right_arrow.onclick
            = (function(form, field, id, date, start_date, end_date) {
                return function() {
                    b_dp_set_month(form, field, id, date, start_date, end_date);
                };
            })(form, field, id, next_month, start_date, end_date);
    }
    var month = b_dp_get_month(date);
    for (var i = 0; i < month.length; i++) {
        for (var j = 0; j < month[i].length; j++) {
            var element = document.getElementById(id + '_' + i + j);
            var d = month[i][j];
            b_add_class(element, 'b_dp_active_day');
            b_remove_class(element, 'b_dp_in_month');
            b_remove_class(element, 'b_dp_not_in_month');
            d.getMonth() == date.getMonth()
                ? b_add_class(element, 'b_dp_in_month')
                : b_add_class(element, 'b_dp_not_in_month');
            if (d.getTime() == today.getTime()) {
                b_add_class(element, 'b_dp_today');
            } else {
                b_remove_class(element, 'b_dp_today');
            }
            if (selection && d.getTime() == selection.getTime()) {
                b_add_class(element, 'b_dp_selected');
            } else {
                b_remove_class(element, 'b_dp_selected');
            }
            element.innerHTML = d.getDate();
            if ((start_date && d.getTime() < start_date.getTime())
                || (end_date && d.getTime() > end_date.getTime())) {
                b_remove_class(element, 'b_dp_active_day');
                b_add_class(element, 'b_dp_inactive_day');
                element.onclick = null;
            } else {
                b_add_class(element, 'b_dp_active_day');
                b_remove_class(element, 'b_dp_inactive_day');
                element.onclick = (function(form, field, id, date) {
                    return function() {
                        b_dp_set_day(form, field, id, date);
                    };
                })(form, field, id, d);
            }
        }
    }
}
function b_dp_get_week(date) {
    var dow = date.getDay();
    date.setDate(date.getDate() - dow);
    var week = new Array();
    var d = b_dp_get_date(date);
    for (var i = 0; i < 7; i++) {
        week.push(d);
        d = b_dp_get_date(d);
        d.setDate(d.getDate() + 1);
    }
    return week;
}
function b_dp_get_month(date) {
    var bom = b_dp_get_bom(date);
    var eom = b_dp_get_eom(date);
    var d = b_dp_get_date(bom);
    var month = new Array();
    while (d.getTime() < eom.getTime()) {
        month.push(b_dp_get_week(d));
        d.setDate(d.getDate() + 7);
    }
    while (month.length < 6) {
        var fd = month[0][0];
        var le = month.length - 1;
        var ld = month[le][month[le].length - 1];
        if (bom.getTime() - fd.getTime() > ld.getTime() - eom.getTime()) {
            ld = b_dp_get_date(ld);
            ld.setDate(ld.getDate() + 7);
            month.push(b_dp_get_week(ld));
        } else {
            fd = b_dp_get_date(fd);
            fd.setDate(fd.getDate() - 7);
            month.unshift(b_dp_get_week(fd));
        }
    }
    return month;
}
function b_dp_get_date(date) {
    var d = typeof(date) == 'object'
        ? new Date(date.getTime())
        : typeof(date) == 'string'
            ? new Date(date)
            : new Date();
    d.setHours(21, 59, 59, 0);
    return d;
}
function b_dp_get_bom(date) {
    var bom = b_dp_get_date(date);
    bom.setDate(1);
    return bom;
}
function b_dp_get_eom(date) {
    var eom = b_dp_get_date(b_dp_get_bom(date));
    eom.setMonth(eom.getMonth() + 1);
    eom.setDate(eom.getDate() - 1);
    return eom;
}
function b_dp_n(n){
    return n < 10 ? '0' + n : n;
}
function b_dp_get_month_name(d){
    switch(d.getMonth()){
    case 0: return 'January';
    case 1: return 'February';
    case 2: return 'March';
    case 3: return 'April';
    case 4: return 'May';
    case 5: return 'June';
    case 6: return 'July';
    case 7: return 'August';
    case 8: return 'September';
    case 9: return 'October';
    case 10: return 'November';
    case 11: return 'December';
    }
    return 'N/A';
}
EOF
}

sub JAVASCRIPT_B_LOG_ERRORS {
    return <<'EOF';
window.onerror = function (errorMsg, url, lineNumber) {
    try {
        var req = new XMLHttpRequest();
        req.open("POST", "/pub/javascript-error", false);
        req.setRequestHeader("Content-type","application/x-www-form-urlencoded");
        req.send("json=" + encodeURIComponent(JSON.stringify({
            'errorMsg': errorMsg,
            'url': url,
            'lineNumber': lineNumber
        })));
    }
    catch (e) {
    }
    return true;
}
EOF
}

sub JAVASCRIPT_B_SLIDE_OUT_SEARCH_FORM {
    return <<'EOF';
function b_sosf_focus(field_id, other_ids) {
    var field = document.getElementById(field_id);
    b_add_class(field, 'b_sosf_active');
    other_ids = other_ids || [];
    for (var i = 0; i < other_ids.length; i++) {
        b_add_class(
            document.getElementById(other_ids[i]), 'b_sosf_active');
    }
    if (field === document.activeElement) {
        return;
    }
    field.focus();
    return;
}
function b_sosf_mouseout(field_id, container_id) {
    var field = document.getElementById(field_id);
    if (field.isSameNode(document.activeElement)) return;
    if (field.value == '') {
        b_remove_class(
            document.getElementById(container_id), 'b_sosf_container_active');
        b_remove_class(field, 'b_sosf_field_active');
        field.blur();
    }
    return;
}
function b_sosf_blur(field_id, other_ids) {
    var field = document.getElementById(field_id);
    if (field.value == '') {
        b_remove_class(field, 'b_sosf_active');
        other_ids = other_ids || [];
        for (var i = 0; i < other_ids.length; i++) {
            b_remove_class(
                document.getElementById(other_ids[i]), 'b_sosf_active');
        }
    }
    return;
}
EOF
}

sub JAVASCRIPT_COMMON {
    return <<'EOF';
function b_escape_html (value) {
    return value.replace(new RegExp('&', 'g'), '&amp;')
        .replace(new RegExp('<', 'g'), '&lt;')
        .replace(new RegExp('>', 'g'), '&gt;');
}
function b_remove_class (element, clazz) {
    var res = [], classes = element.className.split(/\s+/);
    for (var i = 0, length = classes.length; i < length; i++) {
        if (classes[i] != clazz) {
            res.push(classes[i]);
        }
    }
    element.className = res.join(' ');
    return;
}
function b_has_class (element, clazz) {
    return element.className.indexOf(clazz) >= 0;
}
function b_add_class (element, clazz) {
    if (!b_has_class(element, clazz)) {
        element.className += (element.className ? ' ' : '') + clazz;
    }
}
function b_toggle_class (element, class1, class2) {
    if (!b_has_class(element, class1)) {
        b_add_class(element, class1);
        if (class2)
            b_remove_class(element, class2);
    }
    else {
        b_remove_class(element, class1);
        if (class2)
            b_add_class(element, class2);
    }
}
function b_element_by_class(tag_name, class_name) {
    if (!document.getElementsByTagName)
        return;
    var tags = document.getElementsByTagName(tag_name);
    for (var i = 0; i < tags.length; i++) {
        if (b_has_class(tags[i], class_name))
            return tags[i];
    }
    return null;
}
function b_all_elements_by_class(tag_name, class_name) {
    if (!document.getElementsByTagName)
        return;
    var tags = document.getElementsByTagName(tag_name);
    var elements = [];
    for (var i = 0; i < tags.length; i++) {
        if (b_has_class(tags[i], class_name))
            elements.push(tags[i]);
    }
    return elements;
}
function b_get_sibling(obj, next, nodeName) {
    var sibling;
    sibling = next ? obj.nextSibling : obj.previousSibling;
    while (sibling.nodeName != nodeName) {
        sibling = next ? sibling.nextSibling : sibling.previousSibling;
    }
    return sibling;
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
    my($search_field_name) = b_use('Model.SearchForm')
        ->get_instance->get_field_name_for_html('search');
    return <<"EOF";
function first_focus_onload() {
    for (var i = 0; i < document.forms.length; i++) {
        var fields = document.forms[i].elements;
        for (var j = 0; j < fields.length; j++) {
            if ((fields[j].type == 'text'
                || fields[j].type == 'textarea')
                && !fields[j].onfocus
                && fields[j].name != '$search_field_name'
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
        if (b_has_class(A, 'b_thumbnail_popup')) {
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

sub JAVASCRIPT_TRIM_TEXT {
    return <<'EOF';
function b_trim_text(id, cutoff) {
  var element = document.getElementById(id);
  if (element == null || element.innerHTML.length <= cutoff + 20)
    return;
  cutoff += Math.max(element.innerHTML.substring(cutoff).indexOf(' '), 0);
  // guard against splitting in middle of an html tag
  var m = element.innerHTML.substring(cutoff).match(/^([^<]*?>)/);
  if (m != null)
    cutoff += m[0].length;
  element.innerHTML = element.innerHTML.substring(0, cutoff)
    + '<span id="' + id + '_rest" class="b_hide">'
    + element.innerHTML.substring(cutoff) + '</span>'
    + ' <a href="javascript:void(0)" class="dd_visible" id="'
    + id + '_more">more&hellip;</a>';
  element.onclick = function() {
    b_toggle_class(document.getElementById(id + '_rest'),
      'dd_visible', 'b_hide')
    b_toggle_class(document.getElementById(id + '_more'),
      'dd_visible', 'b_hide')
  };
}
EOF
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
