# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::TestUser;
use strict;
use Bivio::Base 'Bivio::ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub ADM {
    return 'adm';
}

sub USAGE {
    return <<'EOF';
usage: b-test-user [options] command [args..]
commands
  init -- test users (adm, etc.)
  leave_and_delete -- remove user from all realms and delete
EOF
}

sub init {
    my($self) = @_;
    $self->initialize_ui->with_realm(undef, sub {
	$self->req->with_user($self->ADM => sub {
	    $self->new_other('SiteForum')->make_admin;
	});
	return;
    });
    return;
}

sub init_adm {
    my($self) = @_;
    $self->initialize_ui->with_realm(undef, sub {
	$self->new_other('SQL')->create_test_user($self->ADM);
	$self->req->set_user($self->ADM);
	$self->new_other('RealmRole')->make_super_user;
	return;
    });
    return;
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
