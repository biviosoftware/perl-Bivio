# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Parser::RealmFile::MSExcel;
use strict;
use Bivio::Base 'SearchParserRealmFile.MSOfficeBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub CONTENT_TYPE_LIST {
    return 'application/vnd.ms-excel';
}

sub internal_get_text {
    my($proto, $parseable) = @_;
    my($path) = $parseable->get_os_path;
    my($text) = $proto->internal_run_command("xls2csv $path");
    $text =~ s/"//g;
    return $text;
}

1;
