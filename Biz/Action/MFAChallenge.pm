# Copyright (c) 2025 bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::Action::MFAChallenge;
use strict;
use Bivio::Base 'Biz.Action';
b_use('IO.Trace');

our($_TRACE);
my($_C) = b_use('AgentHTTP.Cookie');
my($_TSC) = b_use('Type.SecretCode');
my($_TSCS) = b_use('Type.SecretCodeStatus');
my($_USC) = b_use('Model.UserSecretCode');
my($_ULF) = b_use('Model.UserLoginForm');
my($_COOKIE_KEY) = {
    LOGIN_CHALLENGE => 'lc',
    ESCALATION_CHALLENGE => 'ec',
    PASSWORD_QUERY => 'pq',
    next_task => 'nt',
};
my($_PASSWORD_QUERY_KEY) = 'x';

# TODO: acks/nacks

sub create_challenge {
    my($proto, $req, $owner, $type) = @_;
    # TODO: keep this comment?
    # Cookies are required to localize challenges to current browser. Otherwise,
    # a challenge could be used from a browser other than the one where the challenge
    # passed, which could be a security issue.
    b_die('MISSING_COOKIES')
        unless my $cookie = $req->unsafe_get('cookie');
    # $_C->assert_is_ok($req);

    # I think we can just return if there's no cookie, which should only happen with basic auth,
    # which doesn't need escalations (at least currently).
    # return
    #     unless my $cookie = $req->unsafe_get('cookie');
    b_die('unexpected type=', $type)
        unless $type->equals_by_name(qw(LOGIN_CHALLENGE ESCALATION_CHALLENGE));
    my($usc) = $_USC->new($req)->set_ephemeral->create({
        $_USC->REALM_ID_FIELD => $owner->get('realm_id'),
        type => $type,
        status => $_TSCS->PENDING,
    });
    _put_cookie($cookie, $usc);
    _put_req($proto, $req, $usc);
    return $usc;
}

sub delete_cookies {
    my($proto, $req) = @_;
    return
        unless my $cookie = $req->ureq('cookie');
    b_debug($cookie->get_shallow_copy);
    _trace('deleting all cookies')
        if $_TRACE;
    $cookie->delete(values(%$_COOKIE_KEY));
    # TODO: delete models also
    return;
}

sub do_plain_or_mfa {
    my(undef, $owner, $plain_op, $mfa_op, $no_context) = @_;
    $plain_op ||= sub {};
    $mfa_op ||= sub {};
    my($methods) = $owner->get_configured_mfa_methods;
    unless (int(@{$methods || []})) {
        _trace('no MFA methods configured')
            if $_TRACE;
        return $plain_op->($owner) // _redirect('plain_task', $no_context);
    }
    # Only TOTP currently supported. If more methods are added, additional task redirects
    # will be required, possibly including a task that allows the user to select which of
    # multiple configured methods they want to use.
    my($m) = $methods->[0]{type};
    if (int(@$methods) > 1 || !$m->eq_totp) {
        b_die('unsupported methods=', $methods);
    }
    _trace('redirecting to MFA method=', $m)
        if $_TRACE;
    return $mfa_op->($owner) // _redirect((lc($m->get_name) . '_task'), $no_context);
}

sub execute_assert_escalation {
    my($proto, $req) = @_;
    if ($req->is_substitute_user) {
        _trace('not requiring escalation for substitute user')
            if $_TRACE;
        $proto->create_challenge($req, $req->req('auth_user'), $_TSC->ESCALATION_CHALLENGE)
            ->update({status => $_TSCS->PASSED});
        return;
    }
    _trace('asserting escalation')
        if $_TRACE;
    b_die('must have user in non-general realm')
        unless $req->req('auth_user') && !$req->req('auth_realm')->is_general;
    # TODO: need to set next in case of recovery code refill?
    return
        if _unsafe_load_from_cookie($proto, $req, {
            type => $_TSC->ESCALATION_CHALLENGE,
            status => $_TSCS->PASSED,
        });
    $proto->create_challenge($req, $req->req('auth_user'), $_TSC->ESCALATION_CHALLENGE);
    return $proto->do_plain_or_mfa($req->req('auth_user'));
}

sub execute_assert_login {
    my($proto, $req) = @_;
    # TODO: sidestep if substitute_user? makes sense, but shoudn't get to a task that asserts login if su, i think
    _trace('asserting login')
        if $_TRACE;
    my($owner) = $_ULF->load_cookie_user($req, $req->req('cookie'));
    my($usc) = $owner
        ? _unauth_load_from_cookie($proto, $req, {
            user_id => $owner->get('realm_id'),
            type => $_TSC->LOGIN_CHALLENGE,
            status => $_TSCS->PASSED,
        })
        : undef;
    # TODO: no context?
    # TODO: ack
    _redirect('login_task')
        unless $owner && $usc;
    b_die('only for mfa login forms to assert plain login')
        unless $owner->get_configured_mfa_methods;
    _trace('MFA available; creating escalation code')
        if $_TRACE;
    $proto->create_challenge($req, $owner, $_TSC->ESCALATION_CHALLENGE);
    return;
}

sub execute_password_reset {
    my($proto, $req) = @_;
    my($query_key) = delete(($req->get('query') || {})->{$_PASSWORD_QUERY_KEY});
    my($u) = $req->get_nested(qw(auth_realm owner));
    my($res);
    my($die) = Bivio::Die->catch(sub {
        b_die('no query key')
            unless $query_key;
        my($err);
        ($query_key, $err) = $_TSC->PASSWORD_QUERY->from_literal_for_type($query_key);
        b_die('invalid query key')
            if $err;
        my($usc) = _unauth_load($proto, $req, $query_key, {
            user_id => $u->get('realm_id'),
            type => $_TSC->PASSWORD_QUERY,
            status => $_TSCS->ACTIVE,
        });
        b_die('invalid or expired')
            unless $usc;
        $usc->update({status => $_TSCS->USED});
        Bivio::Biz::Model->get_instance('UserLoginForm')->execute($req, {
            realm_owner => $u,
            # there might not be a cookie if user is visiting site
            # from the reset-password URI
            disable_assert_cookie => 1,
            require_mfa => 1,
        });
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
    # TODO: does this get cleared from the req appropriately?
    return $proto->do_plain_or_mfa($u, sub {
        $proto->create_challenge($req, $u, $_TSC->ESCALATION_CHALLENGE)
            ->update({status => $_TSCS->PASSED});
        return;
    }, sub {
        _put_next($proto, $req, $req->req('task')->get_attr_as_id('password_task')->get_name);
        return;
    }, 1);
}

sub format_password_query_uri {
    my(undef, $req) = @_;
    my($pqsc) = b_debug($_USC->new($req)->create({
        type => $_TSC->PASSWORD_QUERY,
        status => $_TSCS->ACTIVE,
    }));
    return $req->format_http({
        task_id => $req->get('task')->get_attr_as_id('reset_task'),
        query => {$_PASSWORD_QUERY_KEY => $pqsc->get('code')},
        no_context => 1,
    });
}

# TODO: naming
sub get_challenge {
    my($proto, $req, $query) = @_;
    # TODO: warn?
    return $proto->unsafe_get_challenge($req, $query) || b_die('FORBIDDEN');
}

sub get_next {
    my($proto, $req) = @_;
    # TODO: handle no cookies?
    my($next) = $req->req('cookie')->unsafe_get($_COOKIE_KEY->{next_task});
    _trace('get next=', $next)
        if $_TRACE;
    $req->req('cookie')->delete($_COOKIE_KEY->{next_task});
    return $next;
}

sub get_req_key {
    my($proto, $type) = @_;
    return join('.', $proto, lc($type->get_name));
}

sub unsafe_get_challenge {
    my($proto, $req, $query) = @_;
    b_die('type required')
        unless $query->{type};
    b_die('status required')
        unless $query->{status};
    if (my $usc = $req->ureq($proto->get_req_key($query->{type}))) {
        _trace('have challenge from req=', $usc);
        if ($usc->get('status')->is_equal($query->{status})) {
            return $usc;
        }
        else {
            _trace('have challenge=', $usc, ', but expected status=', $query->{status})
                if $_TRACE;
        }
    }
    return _unsafe_load_from_cookie($proto, $req, $query);
}

sub _cookie_key {
    my($type) = @_;
    return $_COOKIE_KEY->{$type->get_name} || b_die('no key for type=', $type);
}

sub _load {
    my($proto, $req, $method, $code, $query) = @_;
    _trace('load method=', $method, ' query=', $query)
        if $_TRACE;
    my($usc) = $_USC->new($req)->set_ephemeral->$method($code, $query);
    _trace('result=', $usc)
        if $_TRACE;
    _put_req($proto, $req, $usc)
        if $usc;
    return $usc;
}

sub _nak {
    my($proto, $req) = @_;
    $proto->get_instance('Acknowledgement')->save_label(password_nak => $req);
    return;
}

sub _put_cookie {
    my($cookie, $usc) = @_;
    _trace('put cookie ', _cookie_key($usc->get('type')))
        if $_TRACE;
    $cookie->put(_cookie_key($usc->get('type')) => $usc->get('code'));
    return;
}

sub _put_next {
    my($proto, $req, $task_name) = @_;
    _trace('put next task=', $task_name)
        if $_TRACE;
    $req->req('cookie')->put($_COOKIE_KEY->{next_task} => $task_name);
    return;
}

sub _put_req {
    my($proto, $req, $usc) = @_;
    _trace('put req ', $proto->get_req_key($usc->get('type')), '=', $usc)
        if $_TRACE;
    $req->put_durable($proto->get_req_key($usc->get('type')) => $usc);
    return;
}

sub _unauth_load {
    my($proto, $req, $code, $query) = @_;
    return _load($proto, $req, 'unauth_load_by_code', $code, $query);
}

sub _unauth_load_from_cookie {
    my($proto, $req, $query) = @_;
    return
        unless my $code = _unsafe_get_code_from_cookie($proto, $req, $query->{type});
    return _unauth_load($proto, $req, $code, $query);
}

sub _unsafe_load_from_cookie {
    my($proto, $req, $query) = @_;
    return
        unless my $code = _unsafe_get_code_from_cookie($proto, $req, $query->{type});
    # Not using unsafe_load_by_code as we may not be in user realm
    return _load($proto, $req, 'unauth_load_by_code', $code, {
        %$query,
        user_id => $req->req('auth_user_id'),
    });
}

sub _unsafe_get_code_from_cookie {
    my($proto, $req, $type) = @_;
    return
        unless my $cookie = $req->unsafe_get('cookie');
    return
        unless my $code = $cookie->unsafe_get(_cookie_key($type));
    _trace('have cookie code for type=', $type)
        if $_TRACE;
    return $code;
}

sub _redirect {
    my($task_id, $no_context) = @_;
    my($res) = {
        method => 'server_redirect',
        task_id => shift,
        $no_context ? (
            no_context => 1,
        ) : (),
    };
    _trace('redirect=', $res)
        if $_TRACE;
    return $res;
}

1;
