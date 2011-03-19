# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Parser::RealmFile::Unknown;
use strict;
use Bivio::Base 'SearchParser.RealmFile';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub CONTENT_TYPE_LIST {
    return 'application/octet-stream';
}

sub handle_realm_file_new_text {
    my($proto, $parseable) = @_;
    return
	if -B $parseable->get_os_path;
    return $proto->new_text($parseable->put(content_type => 'text/plain'));
}

1;
