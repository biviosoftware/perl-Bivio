# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Parser::RealmFile::MSExcel;
use strict;
use Bivio::Base 'SearchParserRealmFile.MSOfficeBase';


sub CONTENT_TYPE_LIST {
    return 'application/vnd.ms-excel';
}

sub internal_get_text {
    my($proto, $parseable) = @_;
    my($text) = $proto->internal_run_parser('xls2csv <path>', $parseable);
    $text =~ s/"//g;
    return $text;
}

1;
