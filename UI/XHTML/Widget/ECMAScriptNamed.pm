# Copyright (c) 2008 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::ECMAScriptNamed;
use strict;
use Bivio::Base 'XHTMLWidget.ECMAScript';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub JAVASCRIPT_CORRECT_TABLE_LAYOUT_BUG {
    return <<'EOF';
function correct_table_layout_bug_onload() {
    if (navigator.appName == "Netscape")
      document.body.innerHTML += "\n";
}
EOF
}

sub JAVASCRIPT_FIRST_FOCUS {
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

sub RENDER_LIST {
    return __PACKAGE__ . '-list';
}

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
        control => [sub {
            return ref(shift->ureq($self->RENDER_LIST)) eq 'ARRAY'
                || $self->unsafe_get('value')
                || $self->unsafe_get('SRC')
                ? 1 : 0;

        }],
    );
    return shift->SUPER::initialize(@_);
}

sub render_tag_value {
    my($self, $source, $buffer) = @_;
    my($req) = $source->get_request;
    if ($self->unsafe_get('value')) {
	my($x) = '';
	if ($self->unsafe_render_attr('value', $source, \$x) && $x) {
	    $x = 'JAVASCRIPT_' . uc($x);
	    $self->die('value', $source, $x, ': no such script')
		unless $self->can($x);
	    my($names) = $req->get_if_exists_else_put($self->RENDER_LIST, []);
	    push(@$names, $x)
		unless grep($x eq $_, @$names);
	}
	return;
    }
    my($names) = $req->unsafe_get($self->RENDER_LIST);
    return unless $names;
    $req->delete($self->RENDER_LIST);

    $$buffer .= join("\n",
	map($self->strip($self->$_()), @$names),
	'window.onload=function(){',
        grep(s/JAVASCRIPT_(.*)/\L$1\E_onload();/, @$names),
	'}',
    );
    return;
}

1;
