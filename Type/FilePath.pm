# Copyright (c) 2005-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::FilePath;
use strict;
use base ('Bivio::Type::FileName');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub ILLEGAL_CHAR_REGEXP {
    return qr{(?:^|/)\.\.?$|[\\\:*?"<>\|\0-\037\177]};
}

sub MAIL_FOLDER {
    return '/Mail';
}

sub PUBLIC_FOLDER {
    # Always is_public => 1
    return '/Public';
}

sub from_literal {
    my($proto, $value) = @_;
    my($v, $e) = Bivio::Type::String->from_literal($value);
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

sub join {
    my($proto, @parts) = @_;
    (my $res = join('/', map(defined($_) && length($_) ? $_ : (), @parts)))
	 =~ s{//+}{/}sg;
    return $res;
}

1;
