# Copyright (c) 2025 bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::Action::UserPasswordQuery;
use strict;
use Bivio::Base 'Biz.Action';
use Bivio::Biz::Random;

my($_DT) = b_use('Type.DateTime');
my($_URC) = b_use('Model.UserRecoveryCode');
my($_MRCL) = b_use('Model.MFAFallbackCodeList');
my($_TRC) = b_use('Type.RecoveryCode');
my($_KEY) = 'x';

sub execute {
    my($proto, $req) = @_;
    my($query_key) = delete(($req->get('query') || {})->{$_KEY});
    my($u) = $req->get_nested(qw(auth_realm owner));
    my($self) = $proto->new({
        password_query_code => $query_key,
    })->put_on_request($req, 1);
    my($res);
    my($die) = Bivio::Die->catch(sub {
        my($rc) = $_URC->new($req)->unauth_load_by_code_and_type_or_die(
            $u->get('realm_id'), $query_key, $_TRC->PASSWORD_QUERY);
        $rc->update({type => $_TRC->PASSWORD_RESET});
        $res = Bivio::Biz::Model->get_instance('UserLoginForm')->execute($req, {
            realm_owner => $u,
            # there might not be a cookie if user is visiting site
            # from the reset-password URI
            disable_assert_cookie => 1,
            require_totp => $u->require_totp,
        }) || {
            method => 'server_redirect',
            task_id => 'password_task',
            no_context => 1,
        };
    });
    if ($die) {
        $die->throw
            if $die->get('code')->eq_missing_cookies;
        _nak($proto, $req);
        Bivio::Die->throw(NOT_FOUND => {
            entity => $query_key,
            realm => $u,
        });
    }
    $proto->get_instance('Acknowledgement')->save_label($req);
    return $res;
}

sub format_uri {
    my(undef, $req) = @_;
    my($rc) = $_URC->new($req)->create($_TRC->PASSWORD_QUERY);
    return $req->format_http({
        task_id => $req->get('task')->get_attr_as_id('reset_task'),
        query => {$_KEY => $rc->get('code')},
        no_context => 1,
    });
}

sub _nak {
    my($proto, $req) = @_;
    $proto->get_instance('Acknowledgement')->save_label(password_nak => $req);
    return;
}

sub _throw {
    my($err, $entity, $realm) = @_;
    Bivio::Die->throw($err => {entity => $entity, realm => $realm});
    # DOES NOT RETURN
}

1;
