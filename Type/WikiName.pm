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
    return qr{(\w+)$};
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

sub title_to_help {
    my($proto, $title) = @_;
    $title =~ s/\W+/_/g;
    return $proto->from_literal_stripper($title) . '_Help';
}

sub to_title {
    my($proto, $name) = @_;
    my($title) = $proto->get_base($name);
    $title =~ s/_/ /g;
    return $title;
}

sub uri_hash_for_realm_and_path {
    my($self, $realm_name, $realm_file_path) = @_;
    return {
	task_id =>
	    $self->req('Bivio::UI::Facade')->is_site_realm_name($realm_name)
		? 'SITE_WIKI_VIEW'
		: 'FORUM_WIKI_VIEW',
	realm => $realm_name,
	query => undef,
	path_info => $self->from_absolute($realm_file_path),
    };
}

1;
