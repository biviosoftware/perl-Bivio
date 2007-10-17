# Copyright (c) 2001-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Delegate::SimpleRealmName;
use strict;
use Bivio::Base 'Bivio::Type::Name';
use Bivio::TypeError;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub OFFLINE_PREFIX {
    # Returns prefix character for offline names.
    return '=';
}

sub REGEXP {
    # Returns regular expression used by from_literal.
    return qr/^[a-z][a-z0-9_]{2,}$/i;
}

sub SPECIAL_SEPARATOR {
    # The special separator is used in URIs and to group realm names (see ForumName).
    # Don't assume '-'.  Rather explicitly couple with this call.
    return '-';
}

sub from_literal {
    my($proto, $value) = @_;
    # Trims whitespace and checks syntax an returns (value).
    #
    # Returns C<undef> if the name is empty or zero length.
    #
    # Return (C<undef>, L<Bivio::TypeError::REALM_NAME|Bivio::TypeError::REALM_NAME>)
    # if the syntax check fails.
    $value =~ s/^\s+|\s+$//g
	if defined($value);
    my($v, $e) = $proto->SUPER::from_literal($value);
    return ($v, $e)
	unless defined($v);
    return (undef, Bivio::TypeError->REALM_NAME)
        unless $proto->internal_is_realm_name($v);
    return $proto->process_name($v);
}

sub internal_is_realm_name {
    my($proto, $value) = @_;
    # Returns true if the name is allowed. May be overridden by subclasses.
    # Must begin with a letter and be at least three chars
    return $value =~ $proto->REGEXP ? 1 : 0;
}

sub is_offline {
    my($proto, $value) = @_;
    # Returns true if the RealmName is a offline name.
    return defined($value) && $value =~ /^@{[$proto->OFFLINE_PREFIX]}/ ? 1 : 0;
}

sub make_offline {
    my($proto, $value) = @_;
    # Returns an offline realm name.
    return $value if $proto->is_offline($value);
    $value = substr($value, 0, $proto->get_width - 1)
	if length($value) >= $proto->get_width;
    return $proto->OFFLINE_PREFIX . $value;
}

sub process_name {
    my($proto, $value) = @_;
    # Returns the value, converted to lowercase. May be overridden by subclasses.
    return lc($value);
}

sub unsafe_from_uri {
    my($proto, $value) = @_;
    # Returns the name (possibly cleaned up) or undef, if not valid.
    return undef
	unless $value = ($proto->SUPER::from_literal($value))[0];
    # We allow dashes in URI names (my-site and other constructed names)
    my($s) = $proto->SPECIAL_SEPARATOR;
    (my $v = $value) =~ s/$s//og;
    return $proto->internal_is_realm_name($v) && $value !~ /^$s/o
	? $proto->process_name($value) : undef;
}

1;
