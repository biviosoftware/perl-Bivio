# Copyright (c) 2002-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::RealmAdmin;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');

sub USAGE {
    return <<'EOF';
usage: b-realm-admin [options] command [args...]
commands:
    create_user email display_name password [user_name] -- creates a new user
    delete_auth_realm -- deletes auth_realm
    delete_auth_realm_and_users -- deletes realm and all of its users
    delete_auth_user -- deletes auth_user
    diff_users left_realm right_realm -- report differences between rosters
    invalidate_email -- invalidate a user's email
    invalidate_password -- invalidates a user's password
    join_user roles... -- adds specified user role to realm
    leave_role -- remove one user role from a realm
    leave_user -- removes all user roles from realm
    reset_password password -- reset a user's password
    info -- dump info on a realm
    to_id realm -- returns the id for the realm passed as an argument
    users [role] -- dump users in realm [with a specific role]
EOF
}

sub create_user {
    my($self, $email, $display_name, $password, $user_name) = shift->name_args([
	'Email',
	[DisplayName => sub {
	     my(undef, $args) = @_;
	     return b_use('Type.Email')->get_local_part($args->{Email});
	}],
	[Password => sub {b_use('Biz.Random')->string}],
	[RealmName => sub {
	     my(undef, $args) = @_;
	     return b_use('Type.RealmName')
		 ->clean_and_trim($args->{DisplayName});
	}],
    ], \@_);
    return $self->model(UserCreateForm => {
	'Email.email' => $email,
	'RealmOwner.display_name' => $display_name,
	'RealmOwner.password' => $password,
	confirm_password => $password,
	'RealmOwner.name' => $user_name,
    })->get('User.user_id');
}

sub delete_auth_realm {
    my($self) = @_;
    $self->are_you_sure('Delete ' . $self->req('auth_realm')->as_string . '?');
    my($id) = $self->req('auth_id');
    $self->req->set_realm(undef);
    $self->model('RealmOwner')->unauth_delete_realm({realm_id => $id});
    return;
}

sub delete_auth_realm_and_users {
    my($self) = @_;
    my($req) = $self->req;
    $self->usage_error($self->req('auth_realm'), ': cannot delete a default realm')
	if $req->get('auth_realm')->is_default;
    $self->are_you_sure('delete realm ' . $self->req(qw(auth_realm owner_name)));
    foreach my $r (
	@{$self->model('RealmUser')
	    ->map_iterate(sub {shift->get('user_id')}, 'user_id')
	},
    ) {
	next
	    if $r eq $self->req(qw(auth_id));
	$req->with_user(
	    $r,
	    sub {
		$self->delete_auth_user;
		return;
	    },
	);
    }
    return $self->delete_auth_realm;
}

sub delete_auth_user {
    my($self) = @_;
    return $self->req->with_realm(
	$self->req('auth_user'),
	sub {$self->delete_auth_realm},
    );
}

sub delete_user {
    Bivio::IO::Alert->warn_deprecated('use delete_auth_user');
    return shift->delete_auth_user(@_);
}

sub delete_with_users {
    Bivio::IO::Alert->warn_deprecated('use delete_auth_realm_and_users');
    return shift->delete_auth_realm_and_users(@_);
}

sub diff_users {
    sub DIFF_USERS {[[qw(left_realm RealmArg)], [qw(right_realm RealmArg)]]}
    my($self) = shift;
    $self->initialize_fully;
    my(undef, $bp) = $self->parameters(\@_);
    my($maps) = {};
    foreach my $which (qw(left right)) {
	my($u) = $self->req->with_realm(
	    $bp->{$which . '_realm'},
	    sub {$self->model('GroupUserList')->map_iterate},
	);
	foreach my $field (qw(RealmOwner.display_name RealmUser.realm_id)) {
	    ($maps->{$field} ||= {})->{$which}
		= {map(($_->{$field} => $_), @$u)};
	}
    }
    foreach my $map (values(%$maps)) {
	while (my($key, $row) = each(%{$map->{left}})) {
	    next
		unless $row == ($map->{right}->{$key} || {});
	    foreach my $which (qw(left right)) {
		delete($maps->{'RealmUser.realm_id'}
		    ->{$which}->{$row->{'RealmUser.realm_id'}});
	    }
	}
    }
    return [map([values(%{$maps->{'RealmUser.realm_id'}->{$_}})], qw(left right))];
}

sub info {
    my($self, $owner) = @_;
    # Info on I<realm_owner> or auth_realm.
    return _info(
	$owner || $self->get_request->get_nested(qw(auth_realm owner))
    ) . "\n";
}

sub invalidate_email {
    my($self) = @_;
    # Invalidates the user's email address.
    _validate_user($self, 'Invalidate Email')
        ->get_model('User')->invalidate_email;
    return;
}

sub invalidate_password {
    my($self) = @_;
    # Invalidate the user's password.
    _validate_user($self, 'Invalidate Password')->invalidate_password;
    return;
}

sub join_user {
    my($self, @roles) = shift->name_args([['Auth.Role']], \@_);
    my($req) = $self->req;
    foreach my $role (@roles) {
	my($v) = {
	    realm_id => $req->get('auth_id'),
	    user_id => $req->get('auth_user_id'),
	    role => $role,
	};
	$self->model('RealmUser')->create($v)
	    unless $self->model('RealmUser')->unauth_load($v);
    }
    return;
}

sub leave_role {
    my($self, @roles) = shift->name_args([['Auth.Role']], \@_);
    $self->assert_have_user;
    
    foreach my $role (@roles) {
	$self->model('RealmUser')->delete({
	    realm_id => $self->req('auth_id'),
	    user_id => $self->req('auth_user_id'),
	    role => $role,
	});
    }
    return;
}

sub leave_user {
    my($self) = @_;
    # Drops I<user> from I<realm>.
    my($req) = $self->get_request;
    my($realm_user) = Bivio::Biz::Model->new($req, 'RealmUser');
    $realm_user->unauth_iterate_start('realm_id', {
	realm_id => $req->get('auth_id')
	   || $self->usage_error('realm not set'),
	user_id => $req->get('auth_user_id')
	   || $self->usage_error('user not set'),
	});
    while ($realm_user->iterate_next_and_load) {
	$realm_user->delete;
    }
    $realm_user->iterate_end;
    return;
}

sub reset_password {
    my($self, $password) = @_;
    # Changes a user's password.
    $self->usage_error("missing new password")
        unless defined($password);
    _validate_user($self, 'Reset Password')->update({
        password => b_use('Type.Password')->encrypt($password),
    });
    return;
}

sub to_id {
    my($self, $name_or_email) = shift->name_args(['String'], \@_);
    my($r) = $self->model('RealmOwner');
    b_die($name_or_email, ': not found')
	unless $r->unauth_load_by_email_id_or_name($name_or_email)
	|| $r->unauth_load({display_name => $name_or_email});
    return $r->get('realm_id');
}

sub users {
    my($self, $role) = @_;
    # Users for realm.  Filter by role
    $role &&= uc($role);
    my($roles) = {};
    $self->model('RealmUser')->do_iterate(
	sub {
	    my($it) = @_;
	    push(@{$roles->{$it->get('user_id')} ||= []},
		 [$it->get('role')->get_name, $_DT->to_xml($it->get('creation_date_time'))],
	    );
	    return 1;
	},
	'role asc',
    );
    return join('',
        map({
	    my($ro, $roles) = @$_;
	    join("\n  ", _info($ro), map(join(' ', @$_), sort(@$roles))) . "\n";
	} sort {
	    $a->[0]->get('name') cmp $b->[0]->get('name')
	} map(
	    [$self->unauth_model(RealmOwner => {realm_id => $_}), $roles->{$_}],
	    !$role ? keys(%$roles)
		: grep(grep($_->[0] eq $role, @{$roles->{$_}}), keys(%$roles)),
	)),
    );
}

sub _info {
    my($user) = @_;
    return join("\n  ",
	join(' ',
	    $user->get(qw(name realm_id password)),
	    $_DT->to_xml($user->get('creation_date_time')),
	    $user->get('display_name'),
	),
	@{$user->new_other('Email')->map_iterate(
	    sub {
		my($l, $e) = shift->get(qw(location email));
		return $l->get_name . ' ' . $e;
	    },
	    'unauth_iterate_start',
	    'location',
	    {realm_id => $user->get('realm_id')},
	)},
    );
}

sub _validate_user {
    my($self, $message) = @_;
    # Ensures the user is present, displays the are_you_sure using the
    # specified message.
    # Returns the user's realm.
    my($req) = $self->get_request;
    $self->usage_error("missing user")
        unless $self->unsafe_get('user');
    $self->are_you_sure($message . ' for '
	. $req->get_nested(qw(auth_user display_name))
	. ' of '
	. $req->get_nested(qw(auth_realm owner display_name))
	. '?');
    return $req->get('auth_user');
}

1;
