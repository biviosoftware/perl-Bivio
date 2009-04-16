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
                    var res = [], classes = this.className.split(/\s+/);
                    for (var i = 0, length = classes.length; i < length; i++) {
                        if (classes[i] != H) {
                            res.push(classes[i]);
                        }
                    }
                    this.className = res.join(' ');
                };
                b_menu.onmouseover = function () {
                    if (this.className.indexOf(H) < 0) {
                        this.className += (this.className ? ' ' : '') + H;
                    }
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
    field.className.replace(/disabled/, "enabled");
    return;
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
    if (document.forms.length == 0)
        return;
    var fields = document.forms[0].elements;
    for (i=0; i < fields.length; i++) {
        if (fields[i].type == 'text' || fields[i].type == 'textarea') {
            try {
                fields[i].focus();
            } catch (err) {}
            break;
        }
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
