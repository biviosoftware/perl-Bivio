# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::GroupUserList;
use strict;
use Bivio::Base 'Model.RoleBaseList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_AUL) = b_use('Model.AdmUserList');
my($_SA) = b_use('Type.StringArray');
my($_R) = b_use('Auth.Role');
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

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 0,
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
	],
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

sub internal_prepare_statement {
    my($self) = shift;
    my($stmt) = @_;
    $self->delegate_method($_AUL, @_);
    $self->internal_qualify_role($stmt);
    return $self->SUPER::internal_prepare_statement(@_);
}

sub internal_qualify_role {
    return;
}

sub _privileges {
    my($self, $row) = @_;
    my($main, $aux) = $self->roles_by_category($row->{roles});
    $row->{privileges} = $_SA->new([map(
	$_T->get_value_for_auth_realm(
	   'GroupUserList.privileges_name.' . $_->get_name,
	    $self->req,
	),
	@$main ? $main->[0] : (),
	@$aux,
    )]);
    return;
}

1;
