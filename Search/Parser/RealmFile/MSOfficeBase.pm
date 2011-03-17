# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Parser::RealmFile::MSOfficeBase;
use strict;
use Bivio::Base 'SearchParserRealmFile.CommandBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_get_title {
    my($proto, $parseable) = @_;
    return $proto->internal_run_parser('ldat <path>', $parseable)
	=~ /^\s*Title:\s*(.*)/im
        ? $1 : undef;
}

1;
