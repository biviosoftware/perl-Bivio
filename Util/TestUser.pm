# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::TestUser;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

my($_E) = b_use('Type.Email');
b_use('IO.Config')->register(my $_CFG = {
    default_password => 'password',
});

sub ADM {
    return 'adm';
}

sub DEFAULT_PASSWORD {
    return $_CFG->{default_password};
}

sub USAGE {
    return <<'EOF';
usage: b-test-user [options] command [args..]
commands
  create name_or_email [[password] name]-- RealmAdmin->create_user
  format_email base [domain] -- HTTP->generate_local_email if not already an email
  init -- test users (adm, etc.)
  leave_and_delete [email_re] -- remove user from all realms and delete [
EOF
}

sub create {
    sub CREATE {[
        [qw(user_or_email String)],
        [qw(password Password), sub {shift->DEFAULT_PASSWORD}],
        [qw(name RealmName), undef],
    ]}
    my($self, $bp) = shift->parameters(\@_);
    $self->initialize_fully;
    my($display_name) = $_E->is_valid($bp->{user_or_email})
        ? $_E->get_local_part($bp->{user_or_email})
        : $bp->{user_or_email};
    my($uid) = $self->new_other('RealmAdmin')->create_user(
        $self->format_email($bp->{user_or_email}),
        $display_name,
        $bp->{password},
        $bp->{name} || b_use('Type.RealmName')->clean_and_trim($display_name),
    );
    b_use('Type.PageSize')->row_tag_replace($uid, 100, $self->req);
    return $uid;
}

sub format_email {
    my($self, $base, $domain) = @_;
    return $_E->is_valid($base) ? $base
        : (b_use('TestLanguage.HTTP')->generate_local_email($base, $domain))[0],
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub init {
    my($self) = @_;
    $self->initialize_fully->with_realm(undef, sub {
        $self->req->with_user($self->ADM => sub {
            $self->new_other('SiteForum')->make_admin;
        });
        return;
    });
    return;
}

sub init_adm {
    my($self) = @_;
    return $self->initialize_fully->with_realm(undef, sub {
        my($req) = $self->req;
        $self->create($self->ADM)
            unless $self->model('RealmOwner')->unauth_load({name => $self->ADM});
        $req->set_user($self->ADM);
        $self->new_other('RealmRole')->make_super_user
            unless $req->is_super_user;
        return;
    });
}

sub leave_and_delete {
    sub LEAVE_AND_DELETE {[[qw(name_re Regexp), undef]]}
    my($self, $bp) = shift->parameters(\@_);
    $self->req->assert_test;
    my($uids) = $bp->{name_re} ? _match_users($self, $bp->{name_re})
        : [$self->req('auth_user_id')];
    return []
        unless @$uids;
    $self->model('RealmUser')->do_iterate(
        sub {
            my($it) = @_;
            $it->unauth_delete;
            return 1;
        },
        'unauth_iterate_start',
        'realm_id',
        {user_id => $uids},
    );
    foreach my $uid (@$uids) {
        $self->req->with_user(
            $uid,
            sub {$self->new_other('RealmAdmin')->put(force => 1)->delete_auth_user},
        );
    }
    return $uids;
}

sub _match_users {
    my($self, $re) = @_;
    return [sort(
        keys(
            %{{
                @{$self->model('AdmUserList')
                    ->map_iterate(
                        sub {
                            my($it) = @_;
                            return $it->get('Email.email') =~ $re
                                ? ($it->get('User.user_id') => 1)
                                : ();
                        },
                    ),
                },
            }},
        ),
    )];
}

1;
