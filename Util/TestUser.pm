# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::TestUser;
use strict;
use Bivio::Base 'Bivio::ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub USAGE {
    return <<'EOF';
usage: b-test-user [options] command [args..]
commands
  init -- test users (adm, etc.)
EOF
}

sub init {
    my($self) = @_;
    my($req) = $self->initialize_ui;
    $req->with_realm(undef, sub {
	foreach my $u (qw(adm)) {
	    $self->new_other('SQL')->create_test_user($u);
	}
	$req->with_user(adm => sub {
            $self->new_other('RealmRole')->make_super_user;
	    my($u) = 'adm';
	    foreach my $r (@{$self->new_other('SiteForum')->realm_names}) {
		$req->with_realm($r => sub {
		    $self->model('ForumUserAddForm', {
			'RealmUser.realm_id' => $req->get('auth_id'),
			'User.user_id' => $req->get('auth_user_id'),
			administrator => 1,
		    });
		    return;
		});
	    }
	});
	return;
    });
    return;
}

1;
