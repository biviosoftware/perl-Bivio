# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::EmailAliasIncoming;
use strict;
use Bivio::Base 'Type.EmailAliasOutgoing';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_ERR) = b_use('Bivio.TypeError')->SYNTAX_ERROR;

sub from_literal {
    my($proto, $value) = @_;
    my($v, $e) = shift->SUPER::from_literal(@_);
    return ($v, $e)
	unless $v;
    return $v =~ /\@/ ? ($v, undef) : (undef, $_ERR);
}

1;
