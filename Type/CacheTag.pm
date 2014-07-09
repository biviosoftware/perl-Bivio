# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::CacheTag;
use strict;
use Bivio::Base 'Type.SyntacticString';
use Digest::MD5 ();
b_use('IO.ClassLoaderAUTOLOAD');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_PREFIX) = 'bct_';
my($_ROOT_LENGTH) = 32;

sub REGEX {
    return qr/${_PREFIX}[a-f0-9]{$_ROOT_LENGTH}/i;
}

sub from_local_path {
    my($self, $path) = @_;
    return undef
	unless -r $path;
    return _tag_from_local_path($path);
}

sub get_min_width {
    return shift->get_width;
}

sub get_prefix {
    return $_PREFIX;
}

sub get_width {
    return length($_PREFIX) + $_ROOT_LENGTH;
}

sub internal_post_from_literal {
    return lc($_[1]);
}

sub _format_tag {
    return join('', $_PREFIX, shift);
}

sub _tag_from_local_path {
    return _format_tag(Digest::MD5::md5_hex(${IO_File()->read(shift)}));
}

1;
