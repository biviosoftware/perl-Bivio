# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::WikiText::Embed;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub handle_register {
    return [qw(b-embed ins-page)];
}

sub render_html {
    my($proto, $args) = @_;
    my($value) =  delete($args->{attrs}->{value}) || $args->{value};
    Bivio::Die->die($args->{attrs}, ': does not accept attributes')
        if %{$args->{attrs}};
    my($uri) = $args->{proto}->internal_format_uri($value, $args);
    return Bivio::Die->die('invalid URI, must begin with a /')
	unless $uri =~ s{^/+}{/};
    return ${$proto->use('AgentEmbed.Dispatcher')
	->call_task($args->{req}, $args->{req}->format_uri({
	    uri => $uri,
	    no_context => 1,
	    query => undef,
	    path_info => undef,
	}))->get_output
    };
}

1;
