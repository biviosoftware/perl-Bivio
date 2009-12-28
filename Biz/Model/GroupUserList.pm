# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::GroupUserList;
use strict;
use Bivio::Base 'Model.RoleBaseList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_AUL) = b_use('Model.AdmUserList');
my($_R) = b_use('Auth.Role');
my($_SA) = b_use('Type.StringArray');
my($_T) = b_use('FacadeComponent.Text');

sub LOAD_ALL_SEARCH_STRING {
    return shift->delegate_method($_AUL);
}

sub NAME_COLUMNS {
    return shift->delegate_method($_AUL);
}

sub NAME_SORT_COLUMNS {
    return shift->delegate_method($_AUL);
}

sub can_change_privileges {
    my($self, $task_id) = @_;
    return $self->req->can_user_execute_task($task_id);
}

sub can_show_row {
    my($self) = @_;
    return $self->get('is_not_withdrawn');
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
    return '' unless my $qf = $self->ureq('Model.GroupUserQueryForm');
    return '' unless my $role = $qf->get_privilege_role;
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
    }
    return $self->SUPER::internal_prepare_statement(@_);
}

sub internal_qualifying_roles {
    my($self) = @_;
    my($m) = $self->ureq('Model.GroupUserQueryForm');
    return $m && $m->get_privilege_role && $m->get_privilege_role->eq_withdrawn
        ? shift->SUPER::internal_qualifying_roles(@_)
        : [grep(! $_->eq_withdrawn, @{$self->ROLES_ORDER})];
}

sub _privileges {
    my($self, $row) = @_;
    my($main, $aux) = $self->roles_by_category($row->{roles});
    $row->{is_not_withdrawn} = 1;
    my($text) = $_T->get_from_source($self->req);
    $row->{privileges} = $_SA->new([map({
        $row->{is_not_withdrawn} = 0
            if $_->eq_withdrawn;
	$text->unsafe_get_value('GroupUserList.privileges_name.' . $_->get_name)
	    || $_->get_short_desc,
    }
	@$main ? $main->[0] : (),
	@$aux,
    )]);
    return;
}

1;
