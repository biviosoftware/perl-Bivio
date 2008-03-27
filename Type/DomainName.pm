# Copyright (c) 2002-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::DomainName;
use strict;
use Bivio::Base 'Bivio::Type::Name';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_REGEXP) = __PACKAGE__->REGEXP;

sub REGEXP {
    # : regexp_ref
    # Returns regular expression used for validating.
    return qr/^(?:[-a-z0-9]{1,63})(?:\.[-a-z0-9]{1,63})+$/is;
}

sub from_literal {
    # (proto, string) : any
    # Downcases result of super and validates against dotted decimal.
    my($value, $err) = shift->SUPER::from_literal(@_);
    return ($value, $err)
	unless defined($value);
    return (undef, Bivio::TypeError->DOMAIN_NAME)
	unless $value =~ $_REGEXP;
    return lc($value);
}

sub get_width {
    # (proto) : int
    # Max host name is 255.
    return 255.
}

1;
