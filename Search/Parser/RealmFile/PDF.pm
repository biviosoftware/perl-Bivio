# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Parser::RealmFile::PDF;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub CONTENT_TYPE_LIST {
    return 'application/pdf';
}

sub _from_application_pdf {
    my($proto, $rf) = @_;
    my($path) = $rf->get_os_path;
    my $x = `pdfinfo $path 2>&1`;
    my($title) = !$? && $x =~ /^Title:\s*(.*)/im ? $1 : undef;
    $title = ''
	unless defined($title);
    $x = `pdftotext $path - 2>&1`;
    if ($? || $x =~ /^Error:/s) {
	Bivio::IO::Alert->warn($rf, ': pdftotext error: ', $x);
	return;
    }
    $x =~ s/^\s*\n$//mg;
    return ['application/pdf', $title, \$x];
}

1;
