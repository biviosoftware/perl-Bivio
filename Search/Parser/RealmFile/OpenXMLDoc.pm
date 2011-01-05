# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Parser::RealmFile::OpenXMLDoc;
use strict;
use Bivio::Base 'SearchParserRealmFile.CommandBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub CONTENT_TYPE_LIST {
    return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
}

sub internal_get_text {
    my($proto, $parseable) = @_;
    my($path) = $parseable->get_os_path;
    return $proto->internal_run_command("docx2txt $path -");
}

1;
