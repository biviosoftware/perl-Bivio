# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::BlogContent;
use strict;
use Bivio::Base 'Type.Text64K';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_C) = b_use('IO.Config');

sub TITLE_PREFIX {
    return $_C->if_version(7 => '@h1', '@h3');
}

sub join {
    my($proto) = shift;
    return \($proto->TITLE_PREFIX . ' ' . shift(@_) . "\n" . shift(@_));
}

sub split {
    my($proto, $value) = @_;
    my($title_line, $body)
	= split(/\n+/, (ref($value) ? $$value : $value) || '', 2);
    if ($title_line) {
	my($prefix, $title) = split(/\s+/, $title_line, 2);
	return (
	    defined($prefix) && $prefix eq $proto->TITLE_PREFIX
		? $title : Bivio::TypeError->BLOG_TITLE_PREFIX,
	    defined($body) && $body =~ /\S/
		? $body : Bivio::TypeError->BLOG_BODY_NULL,
	) if $title =~ /\S/;
    }
    return (Bivio::TypeError->BLOG_TITLE_NULL, Bivio::TypeError->BLOG_BODY_NULL);
}

1;
