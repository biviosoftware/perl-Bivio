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
    $self->initialize_ui->with_realm(undef, sub {
	foreach my $u (qw(adm)) {
	    $self->new_other('SQL')->create_test_user($u);
	}
	$self->req->with_user(adm => sub {
            $self->new_other('RealmRole')->make_super_user;
	    $self->new_other('SiteForum')->make_admin;
	});
	return;
    });
    return;
}

1;
