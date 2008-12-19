# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserSettingsListForm;
use strict;
use Bivio::Base 'Biz.ListFormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_NAME_FIELDS) = [map("User.${_}_name", qw(first middle last))];
my($_PS) = b_use('Type.PageSize');
my($_MAIL_RECIPIENT) = b_use('Auth.Role')->MAIL_RECIPIENT;

sub execute_empty_row {
    my($self) = @_;
    $self->internal_put_field(is_subscribed => _is_subscribed($self));
    return;
}

sub execute_empty_start {
    my($self) = @_;
    foreach my $m (qw(RealmOwner User)) {
        my($model) = $self->new_other($m)->load;
	$self->load_from_model_properties($model);
    }
    $self->internal_put_field(
	page_size => $_PS->row_tag_get(
	    $self->get('RealmOwner.realm_id'),
	    $self->new_other('RowTag'),
	    $self->req,
	),
    );
    return;
}

sub execute_ok_row {
    my($self) = @_;
    my($method) = $self->unsafe_get('is_subscribed') ? 'unauth_create_or_update'
	: 'unauth_delete';
    $self->new_other('RealmUser')->$method({
	realm_id => $self->get_list_model->get('RealmUser.realm_id'),
	user_id => $self->req('auth_id'),
	role => $_MAIL_RECIPIENT,
    });
    return;
}

sub execute_ok_start {
    my($self) = @_;
    $self->new_other('User')->load->update($self->get_model_properties('User'));
    my($ro) = $self->new_other('RealmOwner')->load;
#TODO: Delete RowTag for defaults
    $_PS->row_tag_replace($ro, $self->unsafe_get('page_size'));
    if ($self->unsafe_get('show_name')) {
	$ro->update($self->get_model_properties('RealmOwner'));
    }
#TODO: Is this needed?  Was there from UserSettingsForm
#     else {
# 	$self->internal_clear_error('RealmOwner.name')
#     }
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        list_class => 'UserSubscriptionList',
	require_context => 1,
	visible => [
	    @$_NAME_FIELDS,
	    'RealmOwner.name',
            {
                name => 'page_size',
                type => 'PageSize',
                constraint => 'NOT_NULL',
            },
	    {
		name => 'is_subscribed',
		type => 'Boolean',
		constraint => 'NONE',
		in_list => 1,
	    },
	],
	other => [
	    {
		name => 'show_name',
		type => 'Boolean',
		constraint => 'NOT_NULL',
	    },
	    'RealmOwner.realm_id',
	],
    });
}

sub internal_initialize_list {
    return shift->new_other('UserSubscriptionList')->load_all({});
}

sub internal_pre_execute {
    my($self) = @_;
    my($req) = $self->req;
    $self->internal_put_field(
	show_name => $req->is_substitute_user || $req->is_super_user ? 1 : 0);
    return shift->SUPER::internal_pre_execute(@_);
}

sub validate_start {
    my($self) = @_;
    $self->internal_put_error('User.first_name', 'NULL')
	unless _is_name_set($self);
    $self->internal_clear_error('RealmOwner.name')
	unless $self->get('show_name');
    return;
}

sub _is_name_set {
    return _is_set(shift, $_NAME_FIELDS);
}

sub _is_set {
    my($self, $fields) = @_;
    foreach my $f (@$fields) {
	return 1
	    if defined($self->unsafe_get($f));
    }
    return 0;
}

sub _is_subscribed {
    my($self) = @_;
    return grep($_ == $_MAIL_RECIPIENT, @{$self->get_list_model->get('roles')})
	? 1 : 0;
}

1;
