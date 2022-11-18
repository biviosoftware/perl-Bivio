# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::WikiText::Email;
use strict;
use Bivio::Base 'XHTMLWidget.WikiTextTag';
use Bivio::UI::ViewLanguageAUTOLOAD;


sub ACCEPTS_CHILDREN {
    return 1;
}

sub handle_register {
    return [qw(b-email)];
}

sub render_html {
    sub RENDER_HTML {[]};
    my($proto, $args, $attrs) = shift->parameters(@_);
    return
        unless $proto;
    return $args->{proto}->render_error(
        '',
        'tag content must be simple text',
        $args
    ) unless @{$args->{children}} == 1
        && @{$args->{children}->[0]->{children}} == 0
        && defined(my $content = $args->{children}->[0]->{content});
    my($email) = $args->{req}->format_email($content);
    my($b);
    MailTo({
        string_font => 0,
        value => String($email, 0),
        email => $email,
    })->initialize_and_render($args->{source}, \$b);
    return $b;
}

sub render_plain_text {
    sub RENDER_PLAIN_TEXT {[]};
    my($proto, $args, $attrs) = shift->parameters(@_);
    return
        unless $proto;
    return $args->{req}->format_email($attrs->{value});
}

1;
