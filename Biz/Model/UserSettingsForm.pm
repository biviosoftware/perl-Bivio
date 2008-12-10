# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserSettingsForm;
use strict;
use Bivio::Base 'Model.UserPasswordForm';
#TODO: List subscriptions to all groups to which user belongs
#      and can have subscriptions modified.  This may be tricky to find.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_PASSWORD_FIELDS) = [qw(old_password new_password confirm_new_password)];
my($_NAME_FIELDS) = [map("User.${_}_name", qw(first middle last))];

#TODO: remove this.  It should be Type.PageSize->get_default
sub DEFAULT_USER_PAGE_SIZE {
    return 15;
}

sub PAGE_SIZE_KEY {
    return 'PAGE_SIZE';
}

sub execute_empty {
    my($self) = @_;
    foreach my $m (qw(RealmOwner User)) {
        my($model) = $self->new_other($m)->load;
        $self->internal_put_field(page_size => ($self->new_other('RowTag')
            ->get_value($model->get('realm_id'), $self->PAGE_SIZE_KEY) ||
                $self->DEFAULT_USER_PAGE_SIZE))
            if $m eq 'RealmOwner';
	$self->load_from_model_properties($model);
    }
    return shift->SUPER::execute_empty(@_);
}

sub execute_ok {
    my($self) = @_;
    $self->new_other('User')->load->update($self->get_model_properties('User'));
    my($ro) = $self->new_other('RealmOwner')->load;
    $self->new_other('RowTag')->replace_value(
        $ro->get('realm_id'), $self->PAGE_SIZE_KEY,
        $self->unsafe_get('page_size') || $self->DEFAULT_USER_PAGE_SIZE);
    $ro->update($self->get_model_properties('RealmOwner'))
	if $self->get('show_name');
    $self->internal_clear_error('RealmOwner.name')
	unless $self->get('show_name');
    $self->SUPER::execute_ok(@_)
	if _is_password_set($self);
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	require_context => 1,
	visible => [
	    @$_NAME_FIELDS,
	    'RealmOwner.name',
            {
                name => 'page_size',
                type => 'PageSize',
                constraint => 'NONE',
            }
	],
	other => [
	    {
		name => 'show_name',
		type => 'Boolean',
		constraint => 'NOT_NULL',
	    },
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    my($req) = $self->req;
    $self->internal_put_field(
	show_name => $req->is_substitute_user || $req->is_super_user ? 1 : 0);
    return shift->SUPER::internal_pre_execute(@_);
}

sub validate {
    my($self) = @_;
    $self->internal_put_error('User.first_name', 'NULL')
	unless _is_name_set($self);
    $self->internal_clear_error('RealmOwner.name')
	unless $self->get('show_name');
    return $self->SUPER::validate(@_)
	if _is_password_set($self);
    $self->map_invoke(internal_clear_error => $_PASSWORD_FIELDS);
    return;
}

sub _is_name_set {
    return _is_set(shift, $_NAME_FIELDS);
}

sub _is_password_set {
    return _is_set(shift, $_PASSWORD_FIELDS);
}

sub _is_set {
    my($self, $fields) = @_;
    foreach my $f (@$fields) {
	return 1
	    if defined($self->unsafe_get($f));
    }
    return 0;
}

1;
