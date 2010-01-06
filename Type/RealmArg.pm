# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::RealmArg;
use strict;
use Bivio::Base 'Type.String';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RN) = b_use('Type.RealmName');
my($_PI) = b_use('Type.PrimaryId');
my($_SYNTAX_ERROR) = b_use('Bivio.TypeError')->SYNTAX_ERROR;

sub from_literal {
    my($proto, $value) = @_;
    my($v, $e) = $_PI->from_literal($value);
    return $_PI->is_valid($v) ? ($v, undef) : (undef, $_SYNTAX_ERROR)
	if defined($v);
    return $_RN->from_literal($value);
}

1;
