# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::DropDown;
use strict;
use Bivio::Base 'Widget.Join';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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
    dd.toggle = function (e, b2) {
        var prev;
        while (prev = b_element_by_class('div', 'dd_visible')) {
	    b_toggle_class(prev, 'dd_visible', 'dd_hidden');
        }
	(e || window.event).cancelBubble = true;
	if (!b2)
	    return;
        b_toggle_class(b2.element, 'dd_visible', 'dd_hidden');
    };
    document.onclick = function(e) {
	dd.toggle(e, null);
    };
})();
EOF
	JavaScript()->strip(<<"EOF"),
(function (){
    $local = $local || {};
    var b = $local;
    b.toggle = function (e) {
        b.element = b.element || document.getElementById('$id');
        $global.toggle(e, $local);
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
	    SPAN_dd_arrow(vs_text_as_prose('drop_down_arrow')),
	]),
	{
	    HREF => '#',
	    ONCLICK => "this.blur(); $local.toggle(event); return false",
	    class => $self->get('link_class'),
	},
    );
}

1;
