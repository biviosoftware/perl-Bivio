# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::WikiText::Embed;
use strict;
use Bivio::Base 'XHTMLWidget.WikiTextTag';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub handle_register {
    return [qw(b-embed ins-page)];
}

sub render_html {
    my($proto, $args) = shift->parse_args([qw(value)], @_);
    my($uri) = $args->{proto}->internal_format_uri(
	$args->{attrs}->{value}, $args,
    );
    return Bivio::Die->die('invalid URI, must begin with a /')
	unless $uri =~ s{^/+}{/};
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
