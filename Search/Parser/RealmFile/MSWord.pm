# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Parser::RealmFile::MSWord;
use strict;
use Bivio::Base 'SearchParserRealmFile.MSOfficeBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub CONTENT_TYPE_LIST {
    return 'application/msword';
}

sub internal_get_text {
    my($proto, $parseable) = @_;
    return $proto->internal_run_parser('catdoc <path>', $parseable);
}

1;
