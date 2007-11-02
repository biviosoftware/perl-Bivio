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
    my($var) = "window.bivio.drop_down_$id";
    $self->put_unless_exists(values => [
	$self->get('widget'),
	_js($var, $id),
	_link($self, $var),
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
    my($var, $id) = @_;
    my($x) = JavaScript()->strip(<<"EOF");
<script type="text/javascript">
window.bivio = window.bivio || {};
(function (){
    $var = $var || {};
    var b = $var;
    b.close = function (e) {
        b.s.visibility == 'visible' && b.toggle(e);
    };
    b.toggle = function (e) {
	if (!b.s) {
	    b.s = document.getElementById('$id').style;
	    document.onclick = b.close;
	}
	b.s.visibility = b.s.visibility == 'visible' ? 'hidden' : 'visible';
	(e||window.event).cancelBubble = true;
    };
})();
</script>
EOF
    chomp($x);
    return $x;
}

sub _link {
    my($self, $var) = @_;
    return A(
	Join([$self->get('label'), ' &#9660;']),
	{
	    HREF => '/',
	    ONCLICK => "this.blur(); $var.toggle(event); return false",
	    class => $self->get('link_class'),
	},
    );
}

1;
