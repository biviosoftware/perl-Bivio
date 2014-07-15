# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::CacheTagFilePath;
use strict;
use Bivio::Base 'Type.FilePath';
b_use('IO.ClassLoaderAUTOLOAD');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
b_use('IO.Config')->register(my $_CFG = {
    use_cached_path => 0,
});

sub REGEX {
    return qr{\.@{[Type_CacheTag()->REGEX]}\.[^\.]+$};
}

sub from_literal {
    my($proto, $value) = @_;
    my($v, $e) = $proto->SUPER::from_literal($value);
    return ($v, $e)
	unless defined($v);
    if ($_CFG->{use_cached_path}) {
	return (undef, $proto->ERROR)
	    unless $v =~ $proto->REGEX;
    }
    return $v;
}

sub from_local_path {
    my($proto, $path, $uri) = @_;
    return ($uri || $path)
	unless $_CFG->{use_cached_path};
    my($tag) = Type_CacheTag()->from_local_path($path);
    return undef
	unless $tag;
    return _format_with_tag($proto, $uri || $path, $tag);
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub is_tagged_path {
    my($proto, $path) = @_;
    return $path =~ $proto->REGEX ? 1 : 0;
}

sub to_untagged_path {
    my($proto, $path) = @_;
    $path =~ s/\.@{[Type_CacheTag()->REGEX]}//;
    return $path;
}

sub _format_with_tag {
    my($proto, $uri_or_path, $tag) = @_;
    return join(
	'.',
	$proto->delete_suffix($uri_or_path),
	$tag,
	$proto->get_suffix($uri_or_path),
    );
}

1;
