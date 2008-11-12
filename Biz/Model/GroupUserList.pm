# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::GroupUserList;
use strict;
use Bivio::Base 'Model.RoleBaseList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_AUL) = __PACKAGE__->use('Model.AdmUserList');

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
	primary_key => [[qw(User.user_id Email.realm_id RealmOwner.realm_id RealmUser.user_id)]],
	order_by => [
	    @{$self->NAME_SORT_COLUMNS},
	    'Email.email',
	],
	other => [
	    @{$self->NAME_COLUMNS},
	    'RealmUser.role',
	    'RealmOwner.display_name',
	    'RealmOwner.name',
 	    'RealmUser.creation_date_time',
	    {
		name => 'display_name',
		type => 'Line',
		constraint => 'NOT_NULL',
	    },
	    $self->field_decl(
		[qw(administrator mail_recipient file_writer)],
		Boolean => 'NOT_NULL',
	    ),
	    [
		'Email.location',
		[$self->get_instance('Email')->DEFAULT_LOCATION],
	    ],
	],
	auth_id => ['RealmUser.realm_id'],
    });
}

sub internal_post_load_row {
    my($self) = shift;
    return 0
	unless $self->SUPER::internal_post_load_row(@_);
    my($row) = @_;
    foreach my $x (qw(administrator mail_recipient file_writer)) {
	$row->{$x} = grep($_->equals_by_name($x), @{$row->{roles}}) ? 1 : 0;
    }
    $self->delegate_method($_AUL, @_);
    return 1;
}

sub internal_prepare_statement {
    my($self) = shift;
    my($stmt) = @_;
    $self->delegate_method($_AUL, @_);
    $self->internal_qualify_role($stmt);
    return $self->SUPER::internal_prepare_statement(@_);
}

sub internal_qualify_role {
    my($self, $stmt) = @_;
    $stmt->where($stmt->NE('RealmUser.role', [Bivio::Auth::Role->WITHDRAWN]));
    return;
}

1;
