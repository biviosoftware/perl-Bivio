# Copyright (c) 1999-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Action::UserLogout;
use strict;
use Bivio::Base 'Biz.Action';

my($_ULF) = b_use('Model.UserLoginForm');
my($_ULTF) = b_use('Model.UserLoginTOTPForm');

sub execute {
    my(undef, $req) = @_;
    my($res) = $_ULF->execute($req, {realm_owner => undef});
    # TODO: what might $res be here?
    return b_debug($res)
        if $res;
    return $_ULTF->execute($req, {realm_owner => undef});
}

1;
