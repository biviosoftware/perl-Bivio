# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::RealmUser;
use strict;
use Bivio::Base 'Bivio.ShellUtil';
use Bivio::IO::Trace;

my($_ALL_REALMS_KEY) = 'ALL REALMS';
my($_RN) = b_use('Type.RealmName');
my($_R) = b_use('Auth.Role');
my($_RT) = b_use('Auth.RealmType');
my($_SA) = b_use('Type.StringArray');
my($_MAP) = {};
b_use('IO.Config')->register(my $_CFG = {
    audit_map => [],
});

sub IS_AUDIT_ENABLED {
    return @{$_CFG->{audit_map}} ? 1 : 0;
}

sub USAGE {
    my($proto) = @_;
    return <<"EOF";
usage: bivio @{[$proto->simple_package_name]} [options] command [args..]
commands
  audit_all_users -- checks all users in realm match configuration
  audit_user -- checks user in realm matches configuration
EOF
}

sub audit_all_users {
    my($self) = @_;
    return join(
	'',
	map(
	    $self->req->with_user($_, sub {
	        my($res) = $self->audit_user;
		return !$res ? ()
		    : ($self->req(qw(auth_user name)), ":\n$res");
	    }),
	    sort({$a->get('name') cmp $b->get('name')}
	        map($self->unauth_model('RealmOwner', {realm_id => $_}),
		    @{$_SA->sort_unique(
			$self->model('RealmUser')->map_iterate(
			    sub {shift->get('user_id')}))},
		)
	    ),
	),
    );
}

sub audit_user {
    my($self) = @_;
    my($map, $all_realms, $uid) = _assert_audit($self);
    return
	unless $map;
    my($ru) = $self->model('RealmUser');
    my($res) = '';
    my($src_realm) = $self->req(qw(auth_realm owner_name));
    my($tgt_realms) = _tgt_realms($self, $map);
    foreach my $tgt_realm (sort(keys(%$tgt_realms))) {
	delete($all_realms->{$tgt_realm});
	my($tgt) = {
	    user_id => $uid,
	    realm_id => _realm_id($self, $tgt_realm),
	};
	my($curr_roles) = {@{$ru->map_iterate(
	    sub {(shift->get('role')->get_name => 1)},
	    'unauth_iterate_start',
	    'role',
	    $tgt,
	)}};
	b_die($tgt_realm, ': target realm may not match controlling realm')
	    if $_RN->is_equal($tgt_realm, $src_realm);
	my($did) = [];
	foreach my $tgt_role (sort(keys(%{$tgt_realms->{$tgt_realm}}))) {
	    next
		if delete($curr_roles->{$tgt_role});
	    $ru->create({role => $_R->$tgt_role(), %$tgt});
	    push(@$did, "+$tgt_role");
	}
	foreach my $role (sort(keys(%$curr_roles))) {
	    $ru->unauth_delete({role => $_R->$role(), %$tgt});
	    push(@$did, "-$role");
	}
	$res .= "$tgt_realm: @$did\n"
	    if @$did;
    }
    foreach my $realm (sort(keys(%$all_realms))) {
	my($did) = [];
	$ru->do_iterate(
	    sub {
		my($it) = @_;
		push(@$did, '-' . $it->get('role')->get_name);
		$it->delete;
		return 1;
	    },
	    'unauth_iterate_start',
	    'role',
	    {
		user_id => $uid,
		realm_id => _realm_id($self, $realm),
	    },
	);
	$res .= "$realm: @$did\n"
	    if @$did;
    }
    $self->req->set_user($uid);
    return $res;
}

sub delete_unattached_users {
    my($self, $users) = @_;
    my($ru) = $self->model('RealmUser');
    foreach my $uid (@$users) {
	next
	    if $ru->is_user_attached_to_other_realms($uid);
	$self->model('RealmOwner')->unauth_delete_realm({realm_id => $uid});
    }
    return;
}

sub handle_config {
    my($proto, $cfg) = @_;
    $_CFG = $cfg;
    $_MAP = _parse_map($proto, $_CFG->{audit_map});
    return;
}

sub _assert_audit {
    my($self) = @_;
    $self->initialize_fully;
    $self->usage_error('may not operate on default realm')
	if $self->req('auth_realm')->is_default;
    $self->usage_error('may not operate on default user')
	if $self->req('auth_user')->is_default;
    my($map) = $_MAP->{$self->req(qw(auth_realm owner_name))} || return;
    return (
	$map,
	{%{$map->{$_ALL_REALMS_KEY}}},
	$self->req('auth_user_id'),
    );
}

sub _assert_map {
    my($map) = @_;
    while (my($src_realm, $v) = each(%$map)) {
	while (my($src_role, $v2) = each(%$v)) {
	    while (my($tgt_realm, $tgt_roles) = each(%$v2)) {
		next
		    unless ref($tgt_roles);
		b_die(
		    $tgt_roles,
		    ': too many main roles in ',
		    join('/', $src_realm, $src_role, $tgt_realm),
		) if grep(
		    $_R->$_()->in_category_role_group('all_users'),
		    @$tgt_roles,
		) > 1;
	    }
	}
    }
    return $map;
}

sub _parse_map {
    my($proto, $cfg) = @_;
    my($res) = {};
    $proto->map_by_two(
	sub {
	    my($src_realm, $cfg) = @_;
	    b_die($src_realm, ': duplicate realm')
		if $res->{$src_realm};
	    $src_realm = b_use('Type.ForumName')
		->from_literal_or_die($src_realm);
	    my($map) = $res->{$src_realm} = {
		$_ALL_REALMS_KEY => my $all_realms = {},
	    };
	    $proto->map_by_two(
		sub {
		    my($src_role, $cfg) = @_;
		    my($realms) = $map->{$_R->$src_role()->get_name} = {};
		    foreach my $c (@$cfg) {
			if (!ref($c)) {
			    b_die($c, ': must appear first')
				if %$realms;
			    b_die($c, ': must begin with "+"')
				unless $c =~ /^\+([A-Z0-9_]+)$/;
			    my($r) = $1;
			    b_die($c, ': role must appear prior to ', $src_role)
				unless my $x = $map->{$r};
			    %$realms = map(
				($_ => +{map(($_ => 1), @{$x->{$_}})}),
				keys(%$x),
			    );
			    next;
			}
			my($tgt_realm, $tgt_roles) = @$c;
			foreach my $realm (
			    ref($tgt_realm) ? @$tgt_realm : $tgt_realm
			) {
			    my($tr, $explicit) = $realm =~ /^(\S+)(\s+EXPLICIT)?$/;
			    b_die($realm, ': invalid realm name')
				unless $tr = $_RN->unsafe_from_uri($tr);
			    my($x) = $realms->{$tr} ||= {};
			    $all_realms->{$tr} = 1
				unless $explicit;
			    foreach my $role (
				ref($tgt_roles) ? @$tgt_roles : $tgt_roles
			    ) {
				$x->{$role}++;
			    }
			}
		    }
		    %$realms = map(
			($_ => [map($_, sort(keys(%{$realms->{$_}})))]),
			keys(%$realms),
		    );
		    return;
		},
		$cfg,
	    );
	    return;
	},
	$cfg,
    );
    _trace(b_use('IO.Ref')->to_string($res)) if $_TRACE;
    return _assert_map($res);
}

sub _realm_id {
    my($self, $name) = @_;
    return $self->get_if_exists_else_put("realm_id.$name" => sub {
        return $self->unauth_model('RealmOwner', {name => $name})
	    ->get('realm_id');
    });
}

sub _tgt_realms {
    my($self, $map) = @_;
    my($res) = {};
    foreach my $src_role (@{$self->req('auth_roles')}) {
	next
	    unless my $x = $map->{$src_role->get_name};
	while (my($tgt_realm, $tgt_roles) = each(%$x)) {
	    foreach my $realm (_tgt_realms_list($self, $tgt_realm)) {
		foreach my $role (@$tgt_roles) {
		    ($res->{$realm} ||= {})->{$role} = 1;
		}
	    }
	}
    }
    return $res;
}

sub _tgt_realms_list {
    my($self, $tgt_realm) = @_;
    return $tgt_realm
	unless my $rt = $_RT->unsafe_from_name($tgt_realm);
    return @{$self->model('RealmOwner')->map_iterate(
	sub {
	    my($it) = @_;
	    return
		if $it->is_default;
	    return $it->get('name');
	},
	'unauth_iterate_start',
	'name',
	{realm_type => $rt},
    )};
}

1;
