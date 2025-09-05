# Copyright (c) 2025 bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::Action::UserPasswordQuery;
use strict;
use Bivio::Base 'Biz.Action';
use Bivio::Biz::Random;

my($_DT) = b_use('Type.DateTime');
my($_MRC) = b_use('Model.RecoveryCode');
my($_MRCL) = b_use('Model.RecoveryCodeList');
my($_TRC) = b_use('Type.RecoveryCode');
my($_TRCT) = b_use('Type.RecoveryCodeType');
my($_KEY) = 'x';
my($_C) = b_use('IO.Config');
$_C->register(my $_CFG = {
    query_key_expiry_seconds => 2 * 60 * 60,
});

sub execute {
    my($proto, $req) = @_;
    my($query_key) = delete(($req->get('query') || {})->{$_KEY});
    my($u) = $req->get_nested(qw(auth_realm owner));
    my($self) = $proto->new({
        password_query_recovery_code => $query_key,
    })->put_on_request($req, 1);
    my($res);
    my($die) = Bivio::Die->catch(sub {
        my($rc) = $_MRC->new($req)->unauth_load_by_code_and_type_or_die(
            $u->get('realm_id'), b_debug($query_key), $_TRCT->PASSWORD_QUERY);
        b_die('expired')
            if $rc->is_expired;
        $rc->update({type => $_TRCT->PASSWORD_RESET});
        Bivio::Biz::Model->get_instance('UserLoginForm')->execute($req, {
            realm_owner => $u,
            # there might not be a cookie if user is visiting site
            # from the reset-password URI
            disable_assert_cookie => 1,
        });
        my($pw_task) = $self->req('task')->get_attr_as_id('password_task');
        $res = {
            method => 'server_redirect',
            # TODO: need this?
            no_context => 1,
        };
        # TODO: do this here or in login form?
        if ($u->require_totp) {
            $self->put(next_task_id => $pw_task);
            $res->{task_id} = $self->req('task')->get_attr_as_id('totp_task');
        }
        else {
            $res->{task_id} = $pw_task;
        }
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
    return b_debug($res);
}

sub format_uri {
    my(undef, $req) = @_;
    my($query_key) = $_TRC->generate_code_for_query;
    $_MRC->new($req)->create(
        b_debug($query_key), $_TRCT->PASSWORD_QUERY, $_DT->add_seconds($_DT->now, $_CFG->{query_key_expiry_seconds}));
    return $req->format_http({
        task_id => $req->get('task')->get_attr_as_id('reset_task'),
        query => {$_KEY => $query_key},
        no_context => 1,
    });
}

sub handle_config {
    my(undef, $cfg) = @_;
    b_die('missing query_key_expiry_seconds')
        unless $cfg->{query_key_expiry_seconds};
    $_CFG = $cfg;
    return;
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
