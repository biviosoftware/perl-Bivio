# Copyright (c) 2006-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::WikiName;
use strict;
use Bivio::Base 'Type.DocletFileName';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_WIDTH) = __PACKAGE__->get_instance('FileName')->get_width;

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
    return $_WIDTH;
}

sub task_to_help {
    my($proto, $task_id, $req) = @_;
    my($name) = Bivio::UI::Text->get_value('title', $task_id->get_name, $req);
    $name =~ s/\W+/_/g;
    return $proto->from_literal_stripper($name) . '_Help';
}

sub to_title {
    my($proto, $name) = @_;
    my($title) = $proto->get_base($name);
    $title =~ s/_/ /g;
    return $title;
}

1;
