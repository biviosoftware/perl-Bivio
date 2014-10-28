# Copyright (c) 2005-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::ControlBase;
use strict;
use Bivio::Base 'HTMLWidget';
use Bivio::UI::ViewLanguageAUTOLOAD;


sub control_on_render {
    my($self, $source, $buffer) = @_;
    $$buffer .= vs_html_attrs_render(
	$self, $source, $self->unsafe_get('html_attrs'));
    return;
}

sub initialize {
    my($self) = @_;
    unless ($self->unsafe_get('html_attrs')) {
	my($a) = $self->map_each(sub {
            my(undef, $k) = @_;
	    return $k =~ /^[A-Z][\_\-A-Z0-9]+$/ ? $k : ();
	});
	$self->put(html_attrs => vs_html_attrs_merge([sort(@$a)]))
	    if @$a;
    }
    vs_html_attrs_initialize($self, $self->unsafe_get('html_attrs'));
    return shift->SUPER::initialize(@_);
}

1;
