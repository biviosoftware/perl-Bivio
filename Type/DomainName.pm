# Copyright (c) 2002-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::DomainName;
use strict;
use Bivio::Base 'Type.SyntacticString';
use Socket ();


sub REGEX {
    return qr/((?:[-a-z0-9]{1,63})(?:\.[-a-z0-9]{1,63})+)/is;
}

sub SYNTAX_ERROR {
    return Bivio::TypeError->DOMAIN_NAME;
}

sub get_width {
    return 255;
}

sub internal_post_from_literal {
    return lc($_[1]);
}

sub to_http_uri {
    my($proto, $value) = @_;
    return b_use('Type.HTTPURI')->from_literal(
	join('', 'http://', $proto->from_literal_or_die($value)));
}

sub unsafe_to_dotted_decimal {
    my($proto, $value) = @_;
    return Socket::inet_ntoa(
	gethostbyname($proto->from_literal_or_die($value))
	|| return undef,
    );
}

1;
