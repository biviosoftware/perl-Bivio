# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::WikiName;
use strict;
use base 'Bivio::Type::DocletFileName';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub PRIVATE_FOLDER {
    return shift->WIKI_FOLDER;
}

sub PUBLIC_FOLDER {
    my($proto) = @_;
    return $proto->join($proto->SUPER::PUBLIC_FOLDER, $proto->PRIVATE_FOLDER);
}

sub REGEX {
    return qr{(?-i:[A-Z][A-Z0-9]*[a-z][a-z0-9]*[A-Z][A-za-z0-9]*)}o;
}

sub from_literal {
    my($proto) = shift;
    my($v, $e) = $proto->SUPER::from_literal(@_);
    return ($v, $e)
	unless defined($v);
    $v =~ s/\s+//g;
    return $v =~ m{^@{[$proto->REGEX]}$}s ? $v
	: (undef, Bivio::TypeError->WIKI_NAME);
}

sub get_width {
    return 50;
}

sub to_absolute {
    my($proto, $value) = (shift, shift);
    return $proto->SUPER::to_absolute($value, @_);
}

1;
