# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XML::Widget::Tag;
use strict;
use Bivio::Base 'Widget.ControlBase';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub control_on_render {
    my($self, $source, $buffer) = @_;
    my($tag) = $self->render_simple_attr('tag', $source);
    $$buffer .= "<$tag";
    $self->render_attr('attributes', $source, $buffer);
    my($b) = '';
    $$buffer .= $self->unsafe_render_attr('value', $source, \$b) && length($b)
	? ">$b</$tag>\n" : "/>\n";
    return;
}

sub initialize {
    my($self) = @_;
    $self->initialize_attr('tag');
    $self->initialize_attr('value', '');
    $self->initialize_attr(attributes => sub {
        my($attr) = $self->get_shallow_copy(qr{^[A-Z0-9]+$});
	return Join([map({
	    my($k, $v) = ($_, $attr->{$_});
	    $k = lc($k);
	    (
		qq{ $k="},
		[\&_to_xml, $v],
		'"',
	    );
	} sort(keys(%$attr)))]);
    });
    return shift->SUPER::initialize(@_);
}


sub internal_as_string {
    return shift->unsafe_get('tag', 'value');
}

sub internal_new_args {
    my(undef, $tag, $value, $attrs) = @_;
    return {
	tag => $tag,
	value => $value,
	($attrs ? %$attrs : ()),
    };
}

sub _to_xml {
    return Bivio::Type->to_xml($_[1]);
}

1;
