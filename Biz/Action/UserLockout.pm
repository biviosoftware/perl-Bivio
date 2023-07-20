# Copyright (c) 2023 bivio Software, Inc.  All rights reserved.
package Bivio::Biz::Action::UserLockout;
use strict;
use Bivio::Base 'Biz.Action';

my($_E) = b_use('Model.Email');

sub execute_load_owner_email {
    my(undef, $req) = @_;
    $req->put(locked_owner_email => $_E->new($req)->unauth_load_or_die({
        realm_id => $req->get_nested(qw(Model.UserLoginForm realm_owner realm_id)),
        location => $_E->DEFAULT_LOCATION,
    })->get('email'));
    return;
}

1;
