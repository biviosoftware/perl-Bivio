# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RoleBaseList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_C) = b_use('SQL.Connection');
my($_R) = b_use('Auth.Role');
my($_V1) = b_use('IO.Config')->if_version(1);
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
my($_ROLES_MAIN) = [map($_R->unsafe_from_name($_) ? $_R->$_() : (), qw(
    ADMINISTRATOR
    ACCOUNTANT
    MEMBER
    GUEST
    WITHDRAWN
))];

sub ROLES_AUXILIARY {
    my($proto) = @_;
    return [grep({
	my($x) = $_;
	!grep($x == $_, @{$proto->ROLES_MAIN});
    } @$proto->{ROLES_ORDER})];
}

sub ROLES_MAIN {
    return [@{$_ROLES_MAIN}];
}

sub ROLES_ORDER {
    return [@{$_ROLES_ORDER}];
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
		$_V1 ? (
		    in_select => 1,
		    select_value => q{(SELECT group_concat(ru.role)
			FROM realm_user_t ru
			WHERE ru.realm_id = realm_user_t.realm_id
			AND ru.user_id = realm_user_t.user_id
		    ) AS roles},
		) : (
		    in_select => 0,
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

sub roles_by_category {
    my($self, $roles) = @_;
    $roles = {map(($_ => 1), @{$roles || $self->get('roles')})};
    my($main) = [];
    foreach my $m (@{$self->ROLES_MAIN}) {
	push(@$main, $m)
	    if delete($roles->{$m});
    }
    return (
	$self->roles_in_order($main),
	$self->roles_in_order([keys(%$roles)]),
    );
}

sub roles_in_order {
    my($self, $roles) = @_;
    $roles ||= $self->get('roles');
    return [map({
	my($r) = $_;
	grep($r eq $_, @$roles) ? $r : ();
    } @{$self->ROLES_ORDER})];
}

sub _roles {
    my($self, $row) = @_;
    my($main, $aux) = $self->roles_by_category(
	$_V1 ? [map($_R->from_sql_column($_), split(/,/, $row->{roles}))]
	   : _select_roles($self, $row));
#TODO: Consider this for very old apps: [$row->{'RealmRole.role'}]);
    $row->{roles} = [@$main, @$aux];
    return;
}

sub _select_roles {
    my($self, $row) = @_;
    return $_C->map_execute(
	sub {$_R->from_sql_column(shift->[0])},
	'SELECT role FROM realm_user_t WHERE realm_id = ? AND user_id = ?',
	[$row->{'RealmUser.realm_id'}, $row->{'RealmUser.user_id'}],
    );
}

1;
