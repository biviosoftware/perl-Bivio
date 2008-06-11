# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Parser::RealmFile::Wiki;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FP) = __PACKAGE__->use('Type.FilePath');
my($_WT) = __PACKAGE__->use('XHTMLWidget.WikiText');

sub CONTENT_TYPE_LIST {
    return 'text/x-bivio-wiki';
}

sub handle_parse {
    my(undef, $parseable) = @_;
    my($wa) = $_WT->prepare_html($parseable, 'FORUM_WIKI_VIEW');
    Bivio::Die->die($parseable, ': unable to parse')
        unless $wa;
    my($body) = $_WT->render_html($wa);
    $body =~ s{<p[^>]*>}{}g;
    $body =~ s{<[^>]+>}{}g;
    return [
	'text/plain',
	Bivio::HTML->unescape($wa->{title}),
	Bivio::HTML->unescape($body),
    ];
}

1;
