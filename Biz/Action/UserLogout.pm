# Copyright (c) 1999-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Action::UserLogout;
use strict;
use Bivio::Base 'Biz.Action';

my($_ULF) = b_use('Model.UserLoginForm');

sub execute {
    my(undef, $req) = @_;
    return $_ULF->execute($req, {realm_owner => undef});
}

1;
