# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::ClearOnFocus;
use strict;
use Bivio::Base 'XHTMLWidget.Join';
use Bivio::UI::ViewLanguageAUTOLOAD;


sub initialize {
    my($self) = @_;
    my($id) = JavaScript()->unique_html_id;
    $self->put_unless_exists(values => [
        Script('b_clear_on_focus'),
        $self->get('widget')->put(
            ONFOCUS => _onfocus($self),
            class => _class($self),
            id => $id,
        ),
        Tag({
            tag => 'script',
            TYPE => 'text/javascript',
            value => Join([
                "var b_clear_on_focus_value = document.getElementById('$id');\n",
                "if (b_clear_on_focus_value && !b_clear_on_focus_value.value.length)\n",
                'b_clear_on_focus_value.value = ',
                JavaScriptString($self->get('hint_text')),
                ";\n",
            ]),
        }),
    ]);
    return shift->SUPER::initialize(@_);
}

sub internal_new_args {
    return shift->internal_compute_new_args(
        [qw(widget hint_text)], \@_);
}

sub _class {
    my($self) = @_;
    my($c) = $self->get('widget')->unsafe_get('class');
    return !$c ? 'disabled' : Join([$c, 'disabled'], ' ');
}

sub _onfocus {
    my($self) = @_;
    my($of) = $self->get('widget')->unsafe_get('ONFOCUS');
    my($default) = Join([
        'b_clear_on_focus(this, ',
        JavaScriptString($self->get('hint_text')),
        ')',
    ]);
    return $of ? Join([$of, $default], '; ') : $default;
}

1;
