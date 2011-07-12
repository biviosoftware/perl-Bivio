# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::User;
use strict;
use Bivio::Base 'Bivio::ShellUtil';
use Bivio::IO::TTY;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = Bivio::Type->get_instance('DateTime');

sub USAGE {
    return <<'EOF';
usage: b-user [options] command [args..]
commands
    create_from_email email -- creates a new user, prompts for password
    merge_users source_user_id target_user_id -- merge two users
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

sub merge_users {
    my($self, $source_user_id, $target_user_id) = @_;
    $self->usage_error('missing source and/or target')
	unless $source_user_id && $target_user_id;
    return if $source_user_id eq $target_user_id;
    $self->are_you_sure('Merge '
	. join(' into ',
	    map($self->unauth_model('RealmOwner', {
		realm_id => $_
	    })->get('display_name'), $source_user_id, $target_user_id))
	. '?');

    foreach my $property (@{_get_related_property_names($self)}) {
	next if $property eq 'User.user_id';
 	my($model, $field) = $property =~ /(.*)\.(.*)/;
	$self->model($model)->do_iterate(sub {
	    my($m) = @_;

	    if ($self->model($model)->unauth_load({
	        map(($_ => $m->get($_)),
		    @{$m->get_info('primary_key_names')}),
		$field => $target_user_id,
	    })) {
		$m->delete;
	    }
	    else {
		my($die) = Bivio::Die->catch_quietly(sub {
		    $m->update({
		        $field => $target_user_id,
			$model eq 'RealmFile'
			    ? (override_is_read_only => 1)
			    : (),
		    });
		});
		
		# continue if constraint fails, ex. uniqueness violation
		if ($die && $die->get('code')->eq_db_constraint) {
		    b_warn('skipping model for merge user db constraint: ',
		       $die->get('attrs')->{model},
		       ' ', $die->get('attrs')->{dbi_errstr},);
		}
		else {
		    $die->throw
			if $die;
		}
	    }
	    return 1;
	}, 'unauth_iterate_start', $field, {
            $field => $source_user_id,
        });
    }
    # special case for RealmFile because updates fail if is_read_only
    b_use('SQL.Connection')->execute(
	'UPDATE realm_file_t SET user_id = ? WHERE user_id = ?',
	[$target_user_id, $source_user_id]);
    $self->unauth_model('User', {
	user_id => $source_user_id,
    })->cascade_delete;
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

sub _get_related_property_names {
    my($self) = @_;
    my($names) = [];

    # get all the fields which refer to RealmOwner.realm_id or User.user_id
    foreach my $model (qw(RealmOwner User)) {
	foreach my $related (@{$self->model($model)
	    ->internal_get_sql_support->get_children}) {

	    foreach my $field (keys(%{$related->[1]})) {
		push(@$names, join('.', ($related->[0]->simple_package_name,
		    $field)));
	    }
	}
    }
    # ECPayment doesn't export the user_id relationship
    push(@$names, 'ECPayment.user_id');
    return $names;
}


1;
