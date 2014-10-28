# Copyright (c) 2006-2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::EmailAliasOutgoing;
use strict;
use Bivio::Base 'Type.Email';

my($_DN) = b_use('Type.DomainName');
my($_ERR) = b_use('Bivio.TypeError')->EMAIL_ALIAS_OUTGOING;

sub format_domain {
    my(undef, $value) = @_;
    return '@' . $value;
}

sub from_literal {
    my($proto, $value) = @_;
    my($v, $e) = shift->SUPER::from_literal(@_);
    return ($v, $e)
	unless $e && $e->eq_email;
    if ($value =~ s/^\@//) {
	($v, $e) = $_DN->from_literal($value);
	return $v ? ($proto->format_domain($v), undef) : ($v, $e);
    }
    return (undef, $_ERR)
	unless $v = $proto->get_instance('RealmName')->unsafe_from_uri($value);
    return ($v, undef);
}

sub get_domain_part {
    my(undef, $value) = @_;
    # may be of the form '@domain' so can't use Type.Email to parse
    return $value && ($value =~ /\@(.+)$/)[0] || undef;
}

1;
