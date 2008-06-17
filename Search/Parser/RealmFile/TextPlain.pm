# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Parser::RealmFile::TextPlain;
use strict;
use Bivio::Base 'SearchParser.RealmFile';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub CONTENT_TYPE_LIST {
    return qw(text/plain text/tab-separated-values text/csv);
}

sub handle_realm_file_new_text {
    my($proto, $parseable) = @_;
    my($ct) = $parseable->get('content_type');
    return $proto->new({
	type => $ct eq 'application/octet-stream' ? 'text/plain' : $ct,
	text => $parseable->get_content,
    });
}

1;
