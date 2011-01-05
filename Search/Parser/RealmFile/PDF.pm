# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Parser::RealmFile::PDF;
use strict;
use Bivio::Base 'SearchParserRealmFile.CommandBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub CONTENT_TYPE_LIST {
    return 'application/pdf';
}

sub internal_get_text {
    my($proto, $parseable) = @_;
    my($path) = $parseable->get_os_path;
    my($text) = $proto->internal_run_command("pdftotext $path -");
    $text =~ s/^\s*\n$//mg;
    return $text;
}

sub internal_get_title {
    my($proto, $parseable) = @_;
    my($path) = $parseable->get_os_path;
    return undef
	unless my $info = $proto->internal_run_command(
	    "pdfinfo $path", qr{/^Error:.*Error:/s});
    return $info =~ /^Title:\s*(.*)/im ? $1 : undef;
}

1;
