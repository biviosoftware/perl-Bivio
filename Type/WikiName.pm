# Copyright (c) 2006-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::WikiName;
use strict;
use Bivio::Base 'Type.DocletFileName';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub ERROR {
    return Bivio::TypeError->WIKI_NAME;
}

sub PRIVATE_FOLDER {
    return shift->WIKI_FOLDER;
}

sub REGEX {
    return qr{\w+};
}

sub START_PAGE {
    return 'StartPage';
}

sub from_literal_stripper {
    my(undef, $v) = @_;
    $v =~ s/\s+/_/g;
    $v =~ s/_+/_/g;
    $v =~ s/^_|_$//g;
    return $v;
}

sub get_width {
    return 50;
}

1;
