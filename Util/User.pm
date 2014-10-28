# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::User;
use strict;
use Bivio::Base 'Bivio::ShellUtil';
use Bivio::IO::TTY;

my($_DT) = Bivio::Type->get_instance('DateTime');

sub DETACH_USER_MODELS {
    return (
	['Address', 'realm_id',
	     [qw(street1 street2 city state zip country)]],
	['Phone', 'realm_id', [qw(phone)]],
	['User', 'user_id', [qw(birth_date gender)]],
	['Website', 'realm_id', [qw(url)]],
    );
}

sub USAGE {
    return <<'EOF';
usage: b-user [options] command [args..]
commands
    create_from_email email -- creates a new user, prompts for password
    detach_user -- remove personal user data, invalidate email and remove from non-user realms
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

sub detach_user {
    my($self) = @_;
    my($u) = $self->ureq('auth_user_id');
    $self->usage_error('must provide user')
	unless $u;
    my($ro) = $self->model('RealmOwner')->unauth_load_or_die({
	realm_id => $u,
    });
    $self->are_you_sure("Are you sure you want to remove personal data, invalidate email and remove from non-user realms for user @{[$ro->get('display_name')]}\n?");
    foreach my $x ($self->DETACH_USER_MODELS) {
	my($m) = $self->model($x->[0]);
	$m->unauth_load({
	    $x->[1] => $u,
	});
	$m->update({
	    map({
		$_ => $_ eq 'gender'
		    ? b_use('Type.Gender')->UNKNOWN
		    : undef,
	    } @{$x->[2]}),
	}) if $m->is_loaded;
    }
    $self->model('EmailVerify')->do_iterate(sub {
	shift->delete;
    }, 'unauth_iterate_start', {
	realm_id => $u,
    });
    my($e) = $self->model('Email');
    $e->unauth_load({
	realm_id => $u,
    });
    $e->invalidate
	if $e->is_loaded;
    $self->model('RealmFileLock')->do_iterate(sub {
	shift->delete;
    }, 'unauth_iterate_start', {
	user_id => $u,
    });
    $self->model('RealmUser')->do_iterate(sub {
	my($ru) = @_;
	$ru->delete
	    unless $ru->get('realm_id') eq $u;
    }, 'unauth_iterate_start', {
	user_id => $u,
    });
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
    _copy_realm_files($self, $source_user_id, $target_user_id);

    foreach my $property (@{_get_related_property_names($self)}) {
	next if $property eq 'User.user_id';
 	my($model, $field) = $property =~ /(.*)\.(.*)/;
	next if $model eq 'RealmFile';
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
    $self->unauth_model('User', {
	user_id => $source_user_id,
    })->cascade_delete;
    return;
}

sub realms {
    my($self) = @_;
    my($realms) = {};
    $self->model('RealmUser')->do_iterate(
	sub {
	    my($ru) = @_;
	    push(@{$realms->{$ru->get('realm_id')} ||= []},
		 $ru->get('role')->get_name
		 . ' '
		 . $_DT->to_xml($ru->get('creation_date_time'))
 		 . $self->subscribe_info($ru),
	    );
	    return 1;
	},
	'unauth_iterate_start',
	'role asc',
	{user_id => $self->req('auth_user_id')},
    );
    my($ro) = $self->model('RealmOwner');
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

sub subscribe_info {
    my($self, $ru) = @_;
    return '' unless $ru->get('role')->eq_mail_recipient;
    my($sub) = $self->model('UserRealmSubscription');
    return ' (NO SUBSCRIPTION)'
	unless $sub->unauth_load({
	    realm_id => $ru->get('realm_id'),
	    user_id => $ru->get('user_id'),
	});
    return ' ('
	. ($sub->get('is_subscribed') ? 'subscribed' : 'not-subscribed')
	. ' ' . $_DT->to_xml($sub->get('modified_date_time')) . ')';
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

sub _copy_realm_files {
    my($self, $source_user_id, $target_user_id) = @_;
    # avoid RealmFile folder dependencies
    $self->model('RealmFile')->do_iterate(sub {
        my($rf) = @_;
	return 1 if $rf->is_version;
	return 1 if $self->model('RealmFile')->unauth_load({
	    realm_id => $target_user_id,
	    path_lc => $rf->get('path_lc'),
	});
	$self->model('RealmFile')->create_with_content({
	    realm_id => $target_user_id,
	    user_id => $target_user_id,
	    map(($_ => $rf->get($_)), qw(path is_public modified_date_time)),
	}, $rf->get_content);
        return 1;					      
    }, 'unauth_iterate_start', 'path_lc', {
	realm_id => $source_user_id,
	is_folder => 0,
    });
    $self->req->with_realm($source_user_id, sub {
        $self->model('RealmFile')->delete_all;
    });
    # special case for RealmFile because updates fail if is_read_only
    b_use('SQL.Connection')->execute(
	'UPDATE realm_file_t SET user_id = ? WHERE user_id = ?',
	[$target_user_id, $source_user_id]);
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
