# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Parser::RealmFile::TextPlain;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub CONTENT_TYPE_LIST {
    return qw(text/plain text/tab-separated-values text/csv);
}

sub handle_parse {
    my(undef, $parseable) = @_;
    my($ct) = $parseable->get('content_type');
    return [
	$ct eq 'application/octet-stream' ? 'text/plain' : $ct,
	'',
	$parseable->get_content,
    ];
}

1;
