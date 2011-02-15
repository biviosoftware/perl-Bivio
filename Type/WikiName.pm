# Copyright (c) 2006-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::WikiName;
use strict;
use Bivio::Base 'Type.DocletFileName';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_WIDTH) = __PACKAGE__->get_instance('FileName')->get_width;
my($_HELP) = '_Help';

sub DEFAULT_START_PAGE_PATH {
    return shift->to_absolute('DefaultStartPage');
}

sub ERROR {
    return Bivio::TypeError->WIKI_NAME;
}

sub PRIVATE_FOLDER {
    return shift->WIKI_FOLDER;
}

sub REGEX {
    return qr{((?:[A-Z]\w+/)*\w+(?:(?:;\d+)(?:\.\d+)?)?)$};
}

sub START_PAGE {
    return 'StartPage';
}

sub TITLE_TAG {
    return '@h1';
}

sub from_literal_stripper {
    my(undef, $v) = @_;
    $v =~ s/\s+/_/g;
    $v =~ s/_+/_/g;
    $v =~ s/^_|_$//g;
    return $v;
}

sub get_width {
    return $_WIDTH;
}

sub title_to_help {
    my($proto, $title) = @_;
    $title =~ s/\W+/_/g;
    return $proto->from_literal_stripper($title) . $_HELP;
}

sub to_title {
    my($proto, $name) = @_;
    my($title) = $proto->get_base($name);
    $title =~ s/$_HELP$//;
    $title =~ s{[_/]+}{ }g;
    return $title;
}

1;
