# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::DropDown;
use strict;
use Bivio::Base 'Widget.Join';
use Bivio::UI::ViewLanguageAUTOLOAD;


sub initialize {
    my($self) = @_;
    my($w) = $self->get_nested('widget');
    $self->put_unless_exists(link_class => 'dd_link');
    my($id) = $w->get_if_exists_else_put(
        id => sub {JavaScript()->unique_html_id});
    $self->die($id, undef, 'widget.id is not JS identifier')
        unless $id =~ /^[a-z]\w+$/s;
    my($local) = JavaScript()->var_name("drop_down_$id");
    $self->put_unless_exists(values => [
        Script('common'),
        $self->get('widget'),
        [sub {_js(@_)}, JavaScript()->var_name('drop_down'), $local, $id],
        _link($self, $local),
    ]);
    return shift->SUPER::initialize(@_);
}

sub internal_new_args {
    my(undef, $label, $widget, $attributes) = @_;
    return {
        label => $label,
        widget => $widget,
        ($attributes ? %$attributes : ()),
    };
}

sub _js {
    my($source, $global, $local, $id) = @_;
    my($b) = '';
    my($js) = JavaScript();
    $js->render(
        $source,
        \$b,
        __PACKAGE__,
        $js->strip(<<"EOF"),
(function (){
    $global = $global || {};
    var dd = $global;
    dd.toggle = function (e, stop_prop, b2) {
        var visible = b_all_elements_by_class('div', 'dd_visible');
        for (var i = 0; i < visible.length; i++) {
            if (!b2 || visible[i] != b2.element) {
                b_toggle_class(visible[i], 'dd_visible', 'dd_hidden');
            }
        }
        if (stop_prop) {
            if (!e) var e = window.event;
            e.cancelBubble = true;
            if (e.stopPropagation) e.stopPropagation();
        }
        if (!b2)
            return;
        b_toggle_class(b2.element, 'dd_visible', 'dd_hidden');
    };
    var ocf = document.onclick;
    document.onclick = function(e) {
        if (ocf) ocf(e);
        dd.toggle(e, false, null);
    };
})();
EOF
        JavaScript()->strip(<<"EOF"),
(function (){
    $local = $local || {};
    var b = $local;
    b.toggle = function (e) {
        b.element = b.element || document.getElementById('$id');
        $global.toggle(e, true, $local);
    };
})();
EOF
    );
    return $b;
}

sub _link {
    my($self, $local) = @_;
    return A(
        Join([
            $self->get('label'),
            $self->unsafe_get('no_arrow')
                ? ()
                : SPAN_dd_arrow(vs_text_as_prose('drop_down_arrow')),
        ]),
        {
            HREF => '#',
            ONCLICK => join(';',
                ($self->unsafe_get('link_onclick') || ''),
                "this.blur(); $local.toggle(event); return false"),
            class => $self->get('link_class'),
        },
    );
}

1;
