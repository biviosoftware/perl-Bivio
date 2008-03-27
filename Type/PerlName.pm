# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::PerlName;
use strict;
use Bivio::Base 'Type.SyntacticString';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub REGEX {
    return qr{([a-z]\w*)}i;
}

sub unsafe_from_path_info {
    my($proto, $req) = @_;
    return undef
	unless my $p = $req->unsafe_get('path_info');
    $p =~ s{^/+}{};
    return ($proto->from_literal($p))[0];
}

1;
