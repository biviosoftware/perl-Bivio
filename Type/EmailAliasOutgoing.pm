# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::EmailAliasOutgoing;
use strict;
use Bivio::Base 'Type.Email';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DN) = b_use('Type.DomainName');
my($_ERR) = b_use('Bivio.TypeError')->EMAIL_ALIAS_OUTGOING;

sub from_literal {
    my($proto, $value) = @_;
    my($v, $e) = shift->SUPER::from_literal(@_);
    return ($v, $e)
	unless $e && $e == Bivio::TypeError->EMAIL;
    if ($value =~ s/^\@//) {
	($v, $e) = $_DN->from_literal($value);
	return $v ? ('@' . $v, undef) : ($v, $e);
    }
    return (undef, $_ERR)
	unless $v = $proto->get_instance('RealmName')->unsafe_from_uri($value);
    return ($v, undef);
}

1;
