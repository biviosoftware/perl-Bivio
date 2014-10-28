# Copyright (c) 2008-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::GroupUserList;
use strict;
use Bivio::Base 'Model.RoleBaseList';
b_use('IO.ClassLoaderAUTOLOAD');

my($_AUL) = b_use('Model.AdmUserList');
my($_R) = b_use('Auth.Role');
my($_SA) = b_use('Type.StringArray');
my($_T) = b_use('FacadeComponent.Text');
my($_C) = b_use('IO.Config');

sub LOAD_ALL_SEARCH_STRING {
    return shift->delegate_method($_AUL);
}

sub NAME_COLUMNS {
    return shift->delegate_method($_AUL);
}

sub NAME_SORT_COLUMNS {
    return shift->delegate_method($_AUL);
}

sub can_add_user {
    return 1;
}

sub can_change_privileges {
    my($self, $task_id) = @_;
    return $self->req->can_user_execute_task($task_id)
	&& $self->get('is_not_withdrawn');
}

sub can_substitute_user {
    my($self) = @_;
    return $self->new_other(
	$_C->if_version(10,
	    sub {'SiteAdminSubstituteUserForm'},
	    sub {'AdmSubstituteUserForm'},
	),
    )->can_substitute_user($self->get('RealmUser.user_id'));
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	primary_key => [[qw(RealmUser.user_id User.user_id Email.realm_id RealmOwner.realm_id)]],
	order_by => [
	    @{$self->NAME_SORT_COLUMNS},
	    'Email.email',
	],
	other => [
	    @{$self->NAME_COLUMNS},
	    'RealmOwner.display_name',
	    'RealmOwner.name',
	    {
		name => 'display_name',
		type => 'Line',
		constraint => 'NOT_NULL',
	    },
	    [
		'Email.location',
		[$self->get_instance('Email')->DEFAULT_LOCATION],
	    ],
	    {
		name => 'privileges',
		type => 'StringArray',
		constraint => 'NONE',
	    },
            {
                name => 'is_not_withdrawn',
                type => 'Boolean',
                constraint => 'NONE',
            },
	    'UserRealmSubscription.is_subscribed',
	    [qw(RealmUser.realm_id UserRealmSubscription.realm_id(+))],
	    [qw(RealmUser.user_id UserRealmSubscription.user_id(+))],
	],
	group_by => [
	    @{$self->NAME_SORT_COLUMNS},
	    @{$self->NAME_COLUMNS},
	    qw(
		RealmUser.user_id
		RealmUser.realm_id
		RealmUser.role
		RealmUser.creation_date_time
		RealmOwner.display_name
		RealmOwner.name
		Email.email
		Email.location
		UserRealmSubscription.is_subscribed
	    ),
	],
	other_query_keys => [qw(b_filter b_privilege)],
	auth_id => ['RealmUser.realm_id'],
    });
}

sub internal_post_load_row {
    my($self) = shift;
    return 0
	unless $self->SUPER::internal_post_load_row(@_);
    my($row) = @_;
    _privileges($self, $row);
    return $self->delegate_method($_AUL, @_);
}

sub internal_pre_load {
    my($self) = @_;
    my($super) = shift->SUPER::internal_pre_load(@_);
    return $super
	unless my $qf = $self->ureq('Model.GroupUserQueryForm');
    my($role) = $qf->get_privilege_role;
    return $super
	unless $role;
    $super = join(
	' AND ',
        $super || (),
	$self->internal_role_exists_statement(
	    $qf->get_subscribed ? Auth_Role('MAIL_RECIPIENT') : $role),
    );
    return $super;
}

sub internal_prepare_statement {
    my($self) = shift;
    my($stmt) = @_;
#TODO: Move internal_prepare_statement out of AdmUserList into RoleBaseList(?)
#      or just here.
    $self->delegate_method($_AUL, @_);
    if (my $qf = $self->ureq('Model.GroupUserQueryForm')) {
	$qf->filter_statement($stmt, {
	    match_fields => [
		qr/\@/ => 'Email.email',
		qr/^\w/ => 'RealmOwner.display_name',
	    ],
	});
	$stmt->where([
	    'UserRealmSubscription.is_subscribed' => [1],
	]) if $qf->get_subscribed;
    }
    return $self->SUPER::internal_prepare_statement(@_);
}

sub internal_qualifying_roles {
    my($self) = @_;
    my($m) = $self->ureq('Model.GroupUserQueryForm');
    my($role) = $m && $m->get_privilege_role;
    return $role && ref($role) && $role->eq_withdrawn
        ? shift->SUPER::internal_qualifying_roles(@_)
        : [grep(! $_->eq_withdrawn, @{$self->ROLES_ORDER})];
}

sub internal_role_exists_statement {
    my($self, $role) = @_;
    return <<"EOF";
        EXISTS (
            SELECT ru.role
            FROM realm_user_t ru
            WHERE ru.realm_id = realm_user_t.realm_id
            AND ru.user_id = realm_user_t.user_id
            AND ru.role = @{[$role->as_sql_param]}
        )
EOF
}

sub privilege_name {
    my(undef, $name, $req) = @_;
    return (FacadeComponent_Text()->get_from_source($req)
	->unsafe_get_value("GroupUserList.privileges_name.$name"))[0];
}

sub _privileges {
    my($self, $row) = @_;
    my($main, $aux) = $self->roles_by_category($row->{roles});
    $row->{is_not_withdrawn} = 1;
    $row->{privileges} = $_SA->new([
	map({
	    $row->{is_not_withdrawn} = 0
		if $_->eq_withdrawn;
	    $self->privilege_name($_->get_name, $self->req)
		|| $_->get_short_desc,
	}
	    @$main ? $main->[0] : (),
	    grep(!$_->eq_mail_recipient, @$aux),
	),
	grep($_->eq_mail_recipient, @$aux)
	    && $row->{'UserRealmSubscription.is_subscribed'}
		? $self->privilege_name(
		    'UserRealmSubscription.is_subscribed', $self->req)
		: (),
    ]);
    return;
}

1;
