# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Parser::RealmFile::TextHTML;
use strict;
use Bivio::Base 'SearchParser.RealmFile';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub CONTENT_TYPE_LIST {
    return 'text/html';
}

sub handle_realm_file_new_text {
    my($proto, $parseable) = @_;
    my($t) = $parseable->get_content;
    $$t =~ s{<title\s*>([^<]+)</title\s*>}{}is;
    my($title) = $1;
    $$t =~
	s/<p[^>]*>|<br[^>]*>\s*(&nbsp;?)*<br[^>]*>/ PARAGRAPH_SPLIT_HERE /isg;
    $title =~ s/^\s+|\s+$//gs
	if defined($title);
    $t = $proto->use('HTML.Scraper')->to_text($t);
    $$t =~ s/\s+/ /sg;
    $$t =~ s/ *\bPARAGRAPH_SPLIT_HERE\b */\n\n/sg;
    return $proto->new({
	type => 'text/html',
	defined($title) && length($title) ? (title => $title) : (),
	text => $t,
    });
}

1;
