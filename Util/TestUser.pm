# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::TestUser;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_E) = b_use('Type.Email');

sub ADM {
    return 'adm';
}

sub DEFAULT_PASSWORD {
    return 'password';
}

sub USAGE {
    return <<'EOF';
usage: b-test-user [options] command [args..]
commands
  create user_or_email [password] -- RealmAdmin->create_user
  format_email base -- HTTP->generate_local_email if not already an email
  init -- test users (adm, etc.)
  leave_and_delete -- remove user from all realms and delete
EOF
}

sub create {
    my($self, $user_or_email, $password) = shift->name_args([
	[qw(user_or_email String)],
	[Password => sub {shift->DEFAULT_PASSWORD}],
    ], \@_);
    $self->initialize_fully;
    my($display_name) = $_E->is_valid($user_or_email)
	? $_E->get_local_part($user_or_email) : $user_or_email;
    my($uid) = $self->new_other('RealmAdmin')->create_user(
	$self->format_test_email($user_or_email),
	$display_name,
	$password,
	b_use('Type.RealmName')->clean_and_trim($display_name),
    );
    b_use('Type.PageSize')->row_tag_replace($uid, 100, $self->req);
    return $uid;
}

sub format_email {
    my($self, $base) = @_;
    return $_E->is_valid($base) ? $base
	: (b_use('TestLanguage.HTTP')->generate_local_email($base))[0],
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
        if ($self->model('RealmOwner')->unauth_load({name => $self->ADM})) {
	    $self->req->set_user($self->ADM);
	}
	else {
	    $self->req->set_user($self->create($self->ADM));
	    $self->new_other('RealmRole')->make_super_user;
	}
	return;
    });
}

sub leave_and_delete {
    my($self) = @_;
    $self->req->assert_test;
    my($uid) = $self->req('auth_user_id');
    $self->model('RealmUser')->do_iterate(
	sub {
	    my($it) = @_;
	    $it->unauth_delete
		unless $it->get('realm_id') eq $uid;
	    return 1;
	},
	'unauth_iterate_start',
	'realm_id',
	{user_id => $uid},
    );
    return $self->new_other('RealmAdmin')->put(force => 1)->delete_user
}

1;
