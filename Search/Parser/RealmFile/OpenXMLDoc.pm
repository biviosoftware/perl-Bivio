# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Parser::RealmFile::OpenXMLDoc;
use strict;
use Bivio::Base 'SearchParserRealmFile.CommandBase';


sub CONTENT_TYPE_LIST {
    return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
}

sub internal_get_text {
    my($proto, $parseable) = @_;
    return $proto->internal_run_parser('docx2txt <path> -', $parseable);
}

1;
