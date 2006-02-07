# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::User;
use strict;
use base 'Bivio::ShellUtil';
use Bivio::IO::TTY;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub USAGE {
    return <<'EOF';
usage: b-user [options] command [args..]
commands
   create_from_email email -- creates a new user, prompts for password
EOF
}

sub create_from_email {
    my($self, $email) = @_;
    my($u) = $email =~ /^(\w+)/;
    $self->usage_error($email, ': does not begin with user name')
	unless $u;
    my($p1) = Bivio::IO::TTY->read_password("${u}'s password: ");
    my($p2) = Bivio::IO::TTY->read_password("retype ${u}'s password: ");
    $self->usage_error('password mismatch, try again')
	unless $p1 eq $p2;
    $self->new_other('Bivio::Util::RealmAdmin')->create_user(
	$email, $u, $p1, $u);
    $self->set_realm_and_user($u, $u);
    Bivio::Biz::Model->new($self->get_request, 'RealmFile')->create_folder({
	    path => Bivio::Biz::Model->get_instance('Forum')->PUBLIC_FOLDER,
	    is_public => 1,
	});
    return;
}

1;
