# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::WikiText::Include;
use strict;
use Bivio::Base 'XHTMLWidget.WikiTextTag';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub handle_register {
    return [qw(b-include)];
}

sub parse_tag_start {
    my($proto, $args) = shift->parse_args([qw(file)], @_);
    my($state) = $args->{state};
    return
	unless my $rf = $state->{proto}->unsafe_load_wiki_data(
	    $args->{attrs}->{file} . '.bwiki',
	    $state,
	);
    $state->{proto}->include_content($rf->get_content, $state);
    return;
}

sub render_html {
    return '';
}

1;
