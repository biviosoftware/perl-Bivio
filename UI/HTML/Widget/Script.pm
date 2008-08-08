# Copyright (c) 2005-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::Script;
use strict;
use Bivio::Base 'Bivio::UI::Widget';

# C<Bivio::UI::HTML::Widget::Script> is called with a script name, which
# is rendered in the head.   Currently, only scripts that are constants,
# called JAVASCRIPT_I<script_name> are allowed.  The script must have an
# onload function called I<script_name>_onload.
#
# Only supports JavaScript.
#
#
#
# value : any []
#
# Renders the name of the script to render.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

sub JAVASCRIPT_CORRECT_TABLE_LAYOUT_BUG {
    # (self) : string
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
    # : string
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
    # : string
    # Prints on load.
    return 'function page_print_onload(){window.print()}';
}

sub initialize {
    # (self) : undef
    my($self) = @_;
    $self->unsafe_initialize_attr('value');
    return;
}

sub internal_new_args {
    # (self, ...) : any
    # Implements positional argument parsing for L<new|"new">.
    my($proto, $value, $attrs) = @_;
    return {
	($value ? (value => $value) : ()),
	($attrs ? %$attrs : ()),
    };
}

sub render {
    # (self, UI.WidgetValueSource, string_ref) : undef
    # Renders this instance into I<buffer> using I<source> to evaluate
    # widget values.
    my($self, $source, $buffer) = @_;
    my($req) = $source->get_request;
    if ($self->has_keys('value')) {
	my($x) = '';
	if ($self->unsafe_render_attr('value', $source, \$x) && $x) {
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
    return unless $names;
    $req->delete(__PACKAGE__);

    my($js) = $_VS->vs_call('JavaScript');
    $$buffer .= join(
	"\n",
	qq{<script type="text/javascript">\n<!--},
	map($js->strip($self->$_()), @$names),
	'window.onload=function(){',
	grep(s/JAVASCRIPT_(.*)/\L$1\E_onload();/, @$names),
	'}',
	"// --></script>",
	'',
    );
    return;
}

1;
