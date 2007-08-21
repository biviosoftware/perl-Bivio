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
	    foreach my $r (qw(ADMIN SITE CONTACT)) {
		my($m) = $r . "_REALM";
		$req->set_realm_and_user($self->new_other('SiteForum')->$m, $u);
		$self->model('ForumUserAddForm', {
		    'RealmUser.realm_id' => $req->get('auth_id'),
		    'User.user_id' => $req->get('auth_user_id'),
		    administrator => 1,
		});
	    }
	});
	return;
    });
    return;
}

1;
