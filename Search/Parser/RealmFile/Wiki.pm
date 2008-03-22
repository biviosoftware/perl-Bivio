# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Parser::RealmFile::Wiki;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FP) = __PACKAGE__->use('Type.FilePath');

sub CONTENT_TYPE_LIST {
    return 'text/x-bivio-wiki';
}

sub handle_parse {
    my(undef, $parseable) = @_;
    my($text) = $parseable->get_content;
    $$text =~ s/(?:^|\n)\@h\d+\s+([^\n]+)\n//s;
    my($title) = $1;
    $$text =~ s/(?=\@p)/\n/mg;
    $$text =~ s/^\@(?:\!.*\n|\S+(?:\s*\w+=\S+)*\s*)//mg;
    return [
	'text/plain',
	$title || $_FP->get_base($parseable->get('path')),
	$text,
    ];
}

1;
