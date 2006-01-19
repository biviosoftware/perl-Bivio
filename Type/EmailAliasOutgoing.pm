# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::EmailAliasOutgoing;
use strict;
use base 'Bivio::Type::Email';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub from_literal {
    my($proto, $value) = @_;
    my($v, $e) = shift->SUPER::from_literal(@_);
    return ($v, $e)
	unless $e && $e == Bivio::TypeError->EMAIL;
    return ($v = $proto->get_instance('RealmName')->unsafe_from_uri($value))
	? $v : (undef, Bivio::TypeError->EMAIL_ALIAS_OUTGOING);
}

1;
