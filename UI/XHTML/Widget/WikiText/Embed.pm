# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::WikiText::Embed;
use strict;
use Bivio::Base 'XHTMLWidget.WikiTextTag';


sub handle_register {
    return [qw(b-embed ins-page)];
}

sub render_html {
    sub RENDER_HTML {[qw(value)]};
    my($proto, $args, $attrs) = shift->parameters(@_);
    return
	unless $proto;
    my($uri) = $args->{proto}->internal_format_uri($attrs->{value}, $args);
    return $args->{proto}->render_error(
	$uri,
	'invalid URI, must begin with a /',
	$args
    ) unless $uri =~ s{^/+}{/};
    my($reply) = $args->{validator}->call_embedded_task(
	$args->{req}->format_uri({
	    uri => $uri,
	    no_context => 1,
	    query => undef,
	    path_info => undef,
	}),
	$args,
    );
    return $reply ? ${$reply->get_output} : '';
}

1;
