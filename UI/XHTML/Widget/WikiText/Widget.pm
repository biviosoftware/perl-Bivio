# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::WikiText::Widget;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub handle_register {
    return [qw(b-widget)];
}

sub render_html {
    my($proto, $args) = @_;
    my($value) =  delete($args->{attrs}->{value}) || $args->{value};
    Bivio::Die->die($args->{attrs}, ': does not accept attributes')
        if %{$args->{attrs}};
    Bivio::Die->die($value, ': value must be lower case word')
        unless $value =~ /^[a-z][a-z0-9_]+$/;
    return ${Bivio::UI::Widget->render_value(
	$value,
	view_get("wiki_widget_$value"),
	$args->{source},
    )};
}

1;
