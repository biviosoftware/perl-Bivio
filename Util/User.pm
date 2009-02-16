# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::User;
use strict;
use base 'Bivio::ShellUtil';
use Bivio::IO::TTY;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = Bivio::Type->get_instance('DateTime');

sub USAGE {
    return <<'EOF';
usage: b-user [options] command [args..]
commands
    create_from_email email -- creates a new user, prompts for password
    realms -- returns realms of the current user
    unsubscribe_bulletin [user_id...] -- clears want_bulletin for auth_user_id or user_ids
EOF
}

sub create_from_email {
    my($self, $email, $password) = @_;
    my($u) = $email =~ /^(\w+)/;
    $self->usage_error($email, ': does not begin with user name')
	unless $u;
    unless ($password) {
	$password = Bivio::IO::TTY->read_password("${u}'s password: ");
	my($p2) = Bivio::IO::TTY->read_password("retype ${u}'s password: ");
	$self->usage_error('password mismatch, try again')
	    unless $password eq $p2;
    }
    $self->initialize_ui;
    $self->new_other('RealmAdmin')->create_user($email, $u, $password, $u);
    return;
}

sub realms {
    my($self) = @_;
    my($realms) = {};
    my($req) = $self->get_request;
    my($ru) = Bivio::Biz::Model->new($req, 'RealmUser');
    $ru->do_iterate(
	sub {
	    my($it) = @_;
	    push(@{$realms->{$it->get('realm_id')} ||= []},
		 $it->get('role')->get_name
		 . ' '
		 . $_DT->to_xml($it->get('creation_date_time'))
	    );
	    return 1;
	},
	'unauth_iterate_start',
	'role asc',
	{user_id => $req->get('auth_user_id')},
    );
    my($ro) = $ru->new_other('RealmOwner');
    my($ra) = $self->new_other('RealmAdmin');
    return join('',
        map($ra->info($ro->unauth_load_or_die({realm_id => $_}))
	    . '  '
	    . join("\n  ", sort(@{$realms->{$_}}))
	    . "\n",
	    sort(keys(%$realms)),
	),
    );
}

sub unsubscribe_bulletin {
    my($self, @realm_ids) = shift->name_args([['?PrimaryId']], \@_);
    push(@realm_ids, $self->req('auth_user_id'))
	unless @realm_ids;
    foreach my $r (@realm_ids) {
	$self->model('Email')->do_iterate(
	    sub {
		shift->update({want_bulletin => 0});
		return 1;
	    },
	    'unauth_iterate_start',
	    'location',
	    {realm_id => $r},
	);
    }
    return;
}

1;
