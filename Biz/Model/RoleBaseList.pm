# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RoleBaseList;
use strict;
use Bivio::Base 'Biz.ListModel';

my($_C) = b_use('SQL.Connection');
my($_R) = b_use('Auth.Role');
b_die('v0: no longer supported')
    unless b_use('IO.Config')->if_version(1);
my($_ROLES_ORDER) = [map($_R->unsafe_from_name($_) ? $_R->$_() : (), qw(
    ADMINISTRATOR
    ACCOUNTANT
    MEMBER
    GUEST
    WITHDRAWN
    FILE_WRITER
    MAIL_RECIPIENT
    UNAPPROVED_APPLICANT
))];
foreach my $r ($_R->get_non_zero_list) {
    push(@$_ROLES_ORDER, $r)
	unless grep($r == $_, @$_ROLES_ORDER);
}
my($i) = 1;
my($_ROLES_ORDERING) = {map(($_ => $i++), @$_ROLES_ORDER)};
my($_CACHE) = {};

sub LOAD_ALL_SIZE {
    return 3000;
}

sub ROLES_ORDER {
    return [@{$_ROLES_ORDER}];
}

sub internal_cache_key {
    my($self) = @_;
    return __PACKAGE__;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	can_iterate => 1,
	version => 1,
	other => [
	    'RealmUser.role',
	    'RealmUser.creation_date_time',
	    'RealmUser.user_id',
	    'RealmUser.realm_id',
	    {
		name => 'roles',
		type => 'String',
		constraint => 'NONE',
	        b_use('ShellUtil.SQL')->is_oracle ? (
                    in_select => 1,
                    select_value => q{(SELECT
			group_concat(
			    CAST(
				MULTISET(
				    SELECT role
				    FROM realm_user_t ru
				    WHERE ru.realm_id = realm_user_t.realm_id
				    AND ru.user_id = realm_user_t.user_id
				)
				AS t_string_list
			    )
			)
			FROM realm_user_t ru
			WHERE ru.realm_id = realm_user_t.realm_id
			AND ru.user_id = realm_user_t.user_id
			GROUP BY realm_user_t.user_id
			) AS roles},
		) : (
		    in_select => 1,
		    select_value => q{(SELECT group_concat(ru.role || '')
			FROM realm_user_t ru
			WHERE ru.realm_id = realm_user_t.realm_id
			AND ru.user_id = realm_user_t.user_id
		    ) AS roles},
		),
	    },
	],
	where => [
	    'RealmUser.role',
	    '= (SELECT MIN(role) FROM realm_user_t ru WHERE',
	    'RealmUser.realm_id',
	    '= ru.realm_id AND',
	    'RealmUser.user_id',
	    '= ru.user_id)',
	],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    return 0
	unless shift->SUPER::internal_post_load_row(@_);
    _roles($self, $row);
    return 1;
}

sub internal_prepare_statement {
    my($self) = shift;
    my($stmt) = @_;
    $self->internal_qualify_role($stmt);
    return $self->SUPER::internal_prepare_statement(@_);
}

sub internal_qualify_role {
    my($self, $stmt) = @_;
    my($r) = $self->internal_qualifying_roles;
    $stmt->where($stmt->IN('RealmUser.role', $r))
	if $r && @$r;
    return;
}

sub internal_qualifying_roles {
    return [];
}

#could cache this, too
sub roles_by_category {
    my($self, $roles) = @_;
    my($map) = {map(($_ => 1), @{$roles ||= $self->get('roles') || []})};
    my($main) = [];
    foreach my $m (@{$_R->get_category_role_group('all_users')}) {
	push(@$main, $m)
	    if delete($map->{$m});
    }
    return (
	$self->roles_in_order($main),
	$self->roles_in_order([grep($map->{$_}, @$roles)]),
    );
}

#can be private
sub roles_in_order {
    my($self, $roles) = @_;
    $roles ||= $self->get('roles');
    return [sort({
    	$_ROLES_ORDERING->{$a} <=> $_ROLES_ORDERING->{$b};
    } @$roles)];
}

sub _roles {
    my($self, $row) = @_;
    my($res) = ($_CACHE->{$self->internal_cache_key} ||= {})->{$row->{roles}}
	||= _roles_compute($self, $row);
    $row->{roles} = $res->[0];
    $row->{'RealmUser.role'} = $res->[1];
    return;
}

sub _roles_compute {
    my($self, $row) = @_;
    my($main, $aux) = $self->roles_by_category(
	[map($_R->from_sql_column($_), split(/,/, $row->{roles}))],
    );
    my($roles) = [@$main, @$aux];
    $main = $aux
	unless @$main;
    return [$roles, $main->[$#$main]];
}

1;
