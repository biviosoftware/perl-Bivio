# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::WikiText::Widget;
use strict;
use Bivio::Base 'XHTMLWidget.WikiTextTag';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_W) = b_use('UI.Widget');

sub handle_register {
    return [qw(b-widget)];
}

sub render_html {
    my($proto, $args) = shift->parse_args([qw(value)], @_);
    return
	unless $proto;
    my($value) =  $args->{attrs}->{value};
    return $args->{proto}->render_error(
	$value, 'value must be lower case word', $args
    ) unless $value =~ /^[a-z][a-z0-9_]+$/;
    return $args->{proto}->render_error(
	$value, 'value must be lower case word', $args
    ) unless $value =~ /^[a-z][a-z0-9_]+$/;
    my($v);
    my($die) = Bivio::Die->catch_quietly(sub {
        $v = view_get("wiki_widget_$value");
    });
    return $args->{proto}->render_error(
	$value, 'widget not found', $args
    ) unless defined($v);
#TODO: upper case is a widget to render.  Request context.
#TODOx: No eval on widget values.
    return ${$_W->render_value($value, $v, $args->{source})};
}

1;
