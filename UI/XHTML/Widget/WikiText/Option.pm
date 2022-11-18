# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::WikiText::Option;
use strict;
use Bivio::Base 'XHTMLWidget.WikiTextTag';


sub handle_register {
    return [qw(b-option)];
}

sub parse_tag_start {
    sub PARSE_TAG_START {[
        [qw(paragraphing Boolean), undef],
    ]};
    my($proto, $args, $attrs) = shift->parameters(@_);
    return
        unless $proto;
    $args->{state}->{option}->{paragraphing} = $attrs->{paragraphing}
        if defined($attrs->{paragraphing});
    return;
}

sub render_html {
    return '';
}

1;
