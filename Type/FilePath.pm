# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::FilePath;
use strict;
use base ('Bivio::Type::String');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub ILLEGAL_CHAR_REGEXP {
    return qr{(?:^|/)\.\.?$|[\\\:*?"<>\|\0-\037\177]};
}

sub from_literal {
    my($proto, $value) = @_;
    my($v, $e) = shift->SUPER::from_literal(@_);
    return ($v, $e)
	unless defined($v);
    return (undef, undef)
	unless $v =~ m{\S};
    $v =~ s{/^\s+|\s+$|^/+|/+$}{}g;
    $v =~ s{/+}{/}g;
    # No specials except forward '/'
    return $v =~ $proto->ILLEGAL_CHAR_REGEXP
	? (undef, Bivio::TypeError->FILE_PATH) : "/$v";
}

sub get_width {
    return 500;
}

1;
