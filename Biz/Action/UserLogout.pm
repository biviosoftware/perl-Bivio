# Copyright (c) 1999-2025 bivio Software, Inc.  All rights reserved.
package Bivio::Biz::Action::UserLogout;
use strict;
use Bivio::Base 'Biz.Action';

my($_AAC) = b_use('Action.AccessChallenge');
my($_MM) = b_use('Type.MFAMethod');
my($_ULF) = b_use('Model.UserLoginForm');

sub execute {
    my($proto, $req) = @_;
    $_AAC->delete_challenges($req);
    my($res) = $proto->internal_login_form->execute($req, {realm_owner => undef});
    foreach my $t ($_MM->get_non_zero_list) {
        my($res2) = $t->get_login_form_class->execute($req, {do_logout => 1});
        $res ||= $res2;
    }
    return $res;
}

sub internal_login_form {
    return $_ULF;
}

1;
