# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::WikiDataName;
use strict;
use Bivio::Base 'Type.DocletFileName';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_C) = __PACKAGE__->use('IO.Config');
my($_FOLDER) = $_C->if_version(
    6, __PACKAGE__->WIKI_DATA_FOLDER,
    __PACKAGE__->WIKI_FOLDER);

sub PRIVATE_FOLDER {
    return $_FOLDER;
}

sub format_uri {
    my($proto, $uri, $args) = @_;
#TODO: Need to handle multiple realm-types.
    return $args->{req}->format_uri({
	task_id => $_C->if_version(
	    3, 'FORUM_FILE',
	    sub {$args->{is_public} ? 'FORUM_PUBLIC_FILE' : 'FORUM_FILE'},
	),
	realm => $args->{realm_name},
	query => undef,
	path_info => $proto->to_absolute($uri),
    });
}

1;
