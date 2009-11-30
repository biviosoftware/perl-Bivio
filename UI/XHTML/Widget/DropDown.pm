# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::DropDown;
use strict;
use Bivio::Base 'Widget.Join';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(link_class => 'dd_link');
    my($id) = $self->get_nested(qw(widget id));
    $self->die($id, undef, 'widget.id is not JS identifier')
	unless $id =~ /^[a-z]\w+$/s;
    my($local) = JavaScript()->var_name("drop_down_$id");
    $self->put_unless_exists(values => [
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
    dd.curr = null;
    dd.toggle = function (e, b2) {
	if (dd.curr) {
	    var c = dd.curr;
	    dd.curr = null;
	    c.toggle(e);
	}
	(e || window.event).cancelBubble = true;
	if (!b2)
	    return;
	if (b2.style.visibility == 'visible') {
	    b2.style.visibility = 'hidden';
	}
	else {
	    b2.style.visibility = 'visible';
	    dd.curr = b2;
	}
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
        b.style = b.style || document.getElementById('$id').style;
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
	Join([$self->get('label'), vs_text_as_prose('drop_down_arrow')]),
	{
	    HREF => '#',
	    ONCLICK => "this.blur(); $local.toggle(event); return false",
	    class => $self->get('link_class'),
	},
    );
}

1;
