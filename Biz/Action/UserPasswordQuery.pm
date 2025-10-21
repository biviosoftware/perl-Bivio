# Copyright (c) 2025 bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::Action::UserPasswordQuery;
use strict;
use Bivio::Base 'Biz.Action';
use Bivio::Biz::Random;

my($_DT) = b_use('Type.DateTime');
my($_USC) = b_use('Model.UserSecretCode');
my($_TSC) = b_use('Type.SecretCode');
my($_KEY) = 'x';

sub execute {
    my($proto, $req) = @_;
    my($query_key) = delete(($req->get('query') || {})->{$_KEY});
    my($u) = $req->get_nested(qw(auth_realm owner));
    my($res);
    my($die) = Bivio::Die->catch(sub {
        my($err);
        ($query_key, $err) = $_TSC->PASSWORD_QUERY->from_literal_for_type($query_key);
        b_die('invalid query key')
            if $err;
        my($pqsc) = $_USC->new($req)->unauth_load_by_code_and_type(
            $u->get('realm_id'), $query_key, $_TSC->PASSWORD_QUERY);
        b_die('invalid or expired')
            unless $pqsc;
        $pqsc->set_used;
        my($tsc) = $u->require_mfa ? $_TSC->PASSWORD_QUERY_MFA_CHALLENGE : $_TSC->PASSWORD_RESET;
        my($usc) = $_USC->new($req)->create({
            $_USC->REALM_ID_FIELD => $u->get('realm_id'),
            type => $tsc,
        });
        my($self) = $proto->new({
            lc($tsc->get_name) . '_code' => $usc->get('code'),
        })->put_on_request($req, 1);
        $res = Bivio::Biz::Model->get_instance('UserLoginForm')->execute($req, {
            realm_owner => $u,
            # there might not be a cookie if user is visiting site
            # from the reset-password URI
            disable_assert_cookie => 1,
            require_mfa => $u->require_mfa,
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
    my($pqsc) = $_USC->new($req)->create($_TSC->PASSWORD_QUERY);
    return $req->format_http({
        task_id => $req->get('task')->get_attr_as_id('reset_task'),
        query => {$_KEY => $pqsc->get('code')},
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
