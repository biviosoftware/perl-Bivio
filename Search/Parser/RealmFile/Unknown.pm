# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Parser::RealmFile::Unknown;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RF) = __PACKAGE__->use('SearchParser.RealmFile');

sub CONTENT_TYPE_LIST {
    return 'application/octet-stream';
}

sub handle_parse {
    my($proto, $parseable) = @_;
    return
	if -B $parseable->get_os_path;
    return $_RF->parse($parseable->put(content_type => 'text/plain'));
}

1;
