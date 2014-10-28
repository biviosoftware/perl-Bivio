# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Parser::RealmFile::MSPowerPoint;
use strict;
use Bivio::Base 'SearchParserRealmFile.MSOfficeBase';


sub CONTENT_TYPE_LIST {
    return 'application/vnd.ms-powerpoint';
}

sub internal_get_text {
    my($proto, $parseable) = @_;
    return $proto->internal_run_parser('catppt <path>', $parseable);
}

1;
