# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Parser::RealmFile::PDF;
use strict;
use Bivio::Base 'SearchParserRealmFile.CommandBase';

b_use('IO.Config')->register(my $_CFG = {
    map(
        ($_, -x "/usr/local/bin/$_" ? "/usr/local/bin/$_" : "/usr/bin/$_"),
        qw(pdftotext pdfinfo),
    ),
});

sub CONTENT_TYPE_LIST {
    return 'application/pdf';
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub internal_get_text {
    my($proto, $parseable) = @_;
    my($path) = $parseable->get_os_path;
    my($text) = $proto->internal_run_parser("$_CFG->{pdftotext} <path> -", $parseable);
    $text =~ s/^\s*\n$//mg;
    return $text;
}

sub internal_get_title {
    my($proto, $parseable) = @_;
    return $proto->internal_run_parser(
        "$_CFG->{pdfinfo} <path>",
        $parseable,
        qr{^Error:.*Error:}s,
    ) =~ /^Title:\s*(.*)/im ? $1 : undef;
}

1;
