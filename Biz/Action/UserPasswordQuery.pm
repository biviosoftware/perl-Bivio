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
        realm_owner => $u,
        # there might not be a cookie if user is visiting site
        # from the reset-password URI
        disable_assert_cookie => 1,
        password_query_recovery_code => $query_key,
        require_totp => 0,
    })->put_on_request($req, 1);
    my($redirect_task_id);
    my(@res);
    if ($u->require_totp) {
        $self->put(require_totp => 1);
        @res = {
            method => 'server_redirect',
            #TODO: get_attr and set no_context on the password_task
            task_id => $req->get('task')->get_attr_as_id('login_task'),
            no_context => 1,
        };
    }
    else {
        my($die) = Bivio::Die->catch(sub {
            @res = Bivio::Biz::Model->get_instance('UserLoginForm')->execute($req, {
                realm_owner => $u,
            });
        });
        if (b_debug($die)) {
            $die->throw
                if $die->get('code')->eq_missing_cookies;
            _nak($proto, $req);
            Bivio::Die->throw(NOT_FOUND => {
                entity => $query_key,
                realm => $u,
            });
        }
        $proto->get_instance('Acknowledgement')->save_label($req);
    }
    return @res;
}

sub format_uri {
    my(undef, $req) = @_;
    my($query_key) = $_TRC->generate_code_for_query;
    $_MRC->new($req)->create(
        $query_key, $_TRCT->PASSWORD_QUERY, $_DT->add_seconds($_DT->now, $_CFG->{query_key_expiry_seconds}));
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
