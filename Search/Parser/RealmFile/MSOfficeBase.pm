# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Parser::RealmFile::MSOfficeBase;
use strict;
use Bivio::Base 'SearchParserRealmFile.CommandBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_get_title {
    my($proto, $parseable) = @_;
    my($path) = $parseable->get_os_path;
    return undef
	unless my $info = $proto->internal_run_command("ldat $path");
    return $info =~ /^\s*Title:\s*(.*)/im ? $1 : undef;
}

1;
