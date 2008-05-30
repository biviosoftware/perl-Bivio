# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Parser::RealmFile::PDF;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub CONTENT_TYPE_LIST {
    return 'application/pdf';
}

sub handle_parse {
    my($proto, $parseable) = @_;
    my($path) = $parseable->get_os_path;
    my $x = `pdfinfo $path 2>&1`;
    return
	if _pdfwarn($parseable, $x, 'pdfinfo');
    my($title) = !$? && $x =~ /^Title:\s*(.*)/im ? $1 : undef;
    $title = ''
	unless defined($title);
    $x = `pdftotext $path - 2>&1`;
    return
	if _pdfwarn($parseable, $x, 'pdftotext');
    $x =~ s/^\s*\n$//mg;
    return ['application/pdf', $title, \$x];
}

sub _pdfwarn {
    my($parseable, $x, $cmd) = @_;
    if ($? || $x =~ /^Error:/s) {
	Bivio::IO::Alert->warn($parseable, ': ', $cmd, ' error: ', $x);
	return 1;
    }
    return 0;
}

1;
