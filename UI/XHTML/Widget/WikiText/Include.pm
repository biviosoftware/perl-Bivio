# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::WikiText::Include;
use strict;
use Bivio::Base 'XHTMLWidget.WikiTextTag';

my($_CC) = b_use('IO.CallingContext');
my($_SUFFIX) = '.bwiki';

sub handle_register {
    return [qw(b-include)];
}

sub parse_tag_start {
    sub PARSE_TAG_START {[[qw(file FileName)]]};
    my($proto, $args, $attrs) = shift->parameters(@_);
    return
	unless $proto;
    _load($args->{state}, $attrs->{file}, 0);
    return;
}

sub pre_parse {
    my($proto, $state) = @_;
    return
	if $state->{is_inline_text};
    _load($state, 'my', 1);
    return;
}

sub _load {
    my($state, $base, $ignore_not_found) = @_;
    return
	unless my $rf = $state->{proto}->unsafe_load_wiki_data(
	    $base . $_SUFFIX,
	    $state,
	    $ignore_not_found,
	);
    $state->{proto}->include_content(
	$rf->get_content,
	$_CC->new_from_file_line($rf->get('path'), 0),
	$state,
    );
    return;
}

1;
