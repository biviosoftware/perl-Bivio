# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::ForumName;
use strict;
use base 'Bivio::Type::Name';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_SEP) = Bivio::Type->get_instance('RealmName')->SPECIAL_SEPARATOR;
# This is same as SimpleRealmName, but this is loosely coupled
my($_REGEXP_TOP) = qr/^([a-z][a-z0-9_]{2,})($_SEP|$)/io;
my($_REGEXP) = qr/^([a-z][a-z0-9_]{2,})[\w$_SEP]*$/io;

sub extract_top {
    my($proto, $value) = @_;
    return ($value =~ $_REGEXP_TOP)[0];
}

sub from_literal {
    my($proto, $value) = @_;
    $value =~ s/^\s+|\s+$//g
	if defined($value);
    my($v, $e) = $proto->SUPER::from_literal($value);
    return ($v, $e)
	unless defined($v);
    return (undef, Bivio::TypeError->FORUM_NAME)
	unless $v =~ $_REGEXP;
    return lc($v);
}

sub is_top {
    my($proto, $value) = @_;
    return ($value =~ $_REGEXP_TOP)[0] eq $value ? 1 : 0;
}

1;
