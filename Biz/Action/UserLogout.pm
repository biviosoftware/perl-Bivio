# Copyright (c) 1999-2025 bivio Software, Inc.  All rights reserved.
package Bivio::Biz::Action::UserLogout;
use strict;
use Bivio::Base 'Biz.Action';

my($_ULF) = b_use('Model.UserLoginForm');
my($_ULTF) = b_use('Model.UserLoginTOTPForm');

sub execute {
    my(undef, $req) = @_;
    my($res) = $_ULF->execute($req, {realm_owner => undef});
    my($res2) = $_ULTF->execute($req, {do_logout => 1});
    return $res || $res2;
}

1;
