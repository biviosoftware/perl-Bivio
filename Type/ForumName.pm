# Copyright (c) 2005-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::ForumName;
use strict;
use base 'Bivio::Type::Name';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_SEP) = Bivio::Type->get_instance('RealmName')->SPECIAL_SEPARATOR;

sub FIRST_CHAR_REGEXP {
    return qr{[a-z]};
}

sub SEP_CHAR_REGEXP {
    return qr{$_SEP};
}

sub REGEXP {
    my($proto) = @_;
    my($c) = $proto->FIRST_CHAR_REGEXP;
    my($s) = $proto->SEP_CHAR_REGEXP;
    return qr/^($c\w{2,})(?:$s(\w+($s\w+)*)|)$/is;
}

sub extract_rest {
    my($proto, $value) = @_;
    return ($value =~ $proto->REGEXP)[1];
}

sub extract_top {
    my($proto, $value) = @_;
    return ($value =~ $proto->REGEXP)[0];
}

sub from_literal {
    my($proto, $value) = @_;
    $value =~ s/^\s+|\s+$//sg
	if defined($value);
    my($v, $e) = $proto->SUPER::from_literal($value);
    return ($v, $e)
	unless defined($v);
    return (undef, Bivio::TypeError->FORUM_NAME)
	unless $v =~ $proto->REGEXP;
    return lc($v);
}

sub is_top {
    my($proto, $value) = @_;
    return $proto->extract_top($value) eq $value ? 1 : 0;
}

1;
