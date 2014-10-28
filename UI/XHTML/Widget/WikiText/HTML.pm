# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::WikiText::HTML;
use strict;
use Bivio::Base 'XHTMLWidget.WikiTextTag';
use Bivio::UI::ViewLanguageAUTOLOAD;


sub ACCEPTS_CHILDREN {
    return 1;
}

sub handle_register {
    return [qw(b-html)];
}

sub parse_tag_start {
    sub PARSE_TAG_START {[]};
    my($proto, $args, $attrs) = shift->parameters(@_);
    my($state) = $args->{state};
    return
	unless $proto;
    $args->{content}
	= join("\n", @{$proto->parse_lines_till_end_tag($args) || []});
    return 1;
}

sub render_html {
    sub RENDER_HTML {[]};
    my($proto, $args, $attrs) = shift->parameters(@_);
    return
	unless $proto;
    return $args->{content};
}

1;
