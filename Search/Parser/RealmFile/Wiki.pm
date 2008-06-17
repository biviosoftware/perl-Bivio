# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Parser::RealmFile::Wiki;
use strict;
use Bivio::Base 'SearchParser.RealmFile';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FP) = __PACKAGE__->use('Type.FilePath');
my($_WT) = __PACKAGE__->use('XHTMLWidget.WikiText');

sub CONTENT_TYPE_LIST {
    return 'text/x-bivio-wiki';
}

sub handle_realm_file_new_text {
    my($proto, $parseable) = @_;
    my($body, $wa) = $_WT->render_plain_text($parseable);
    return $proto->new({
	type => 'text/plain',
	title => Bivio::HTML->unescape($wa->{title}),
	text => \($body),
    });
}

1;
