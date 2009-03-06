# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::RealmUser;
use strict;
use Bivio::Base 'Bivio.ShellUtil';
use Bivio::IO::Trace;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RN) = b_use('Type.RealmName');
my($_R) = b_use('Auth.Role');
my($_MAP) = {};
b_use('IO.Config')->register(my $_CFG = {
    audit_map => [],
});

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
	@{$self->model('RealmUser')->map_iterate(
	    sub {
		$self->req->with_user(shift->get('user_id'), sub {
		    my($res) = $self->audit_user;
		    return !$res ? ()
			: ($self->req(qw(auth_user name)), ":\n$res");
		});
	    },
	    'user_id',
	)},
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
	{map(map(($_ => 1), keys(%$_)), values(%$map))},
	$self->req('auth_user_id'),
    );
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
	    my($map) = $res->{$src_realm} = {};
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
			    my($x) = $realms->{$realm} ||= {};
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
    return $res;
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
	    foreach my $r (@$tgt_roles) {
		($res->{$tgt_realm} ||= {})->{$r} = 1;
	    }

	}
    }
    return $res;
}

1;
