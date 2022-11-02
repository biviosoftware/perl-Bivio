# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::RealmArg;
use strict;
use Bivio::Base 'Type.String';

my($_RN) = b_use('Type.RealmName');
my($_E) = b_use('Type.Email');
my($_PI) = b_use('Type.PrimaryId');
my($_SYNTAX_ERROR) = b_use('Bivio.TypeError')->SYNTAX_ERROR;
my($_NOT_FOUND) = b_use('Bivio.TypeError')->NOT_FOUND;

sub from_literal {
    my($proto, $value) = @_;
    my($v, $e) = $_PI->from_literal($value);
    return $_PI->is_valid($v) ? ($v, undef) : (undef, $_SYNTAX_ERROR)
        if defined($v);
    ($v, $e) = $_E->from_literal($value);
    if (defined($v) and my $req = b_use('Agent.Request')->get_current) {
        my($email) = b_use('Model.Email')->new($req);
        return $email->unauth_load({email => $v})
            ? ($email->get('realm_id'), undef)
            : (undef, $_NOT_FOUND);
    }
    return $_RN->from_literal($value);
}

1;
