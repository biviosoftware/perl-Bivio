# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserSettingsForm;
use strict;
use Bivio::Base 'Model.UserPasswordForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_PASSWORD_FIELDS) = [qw(old_password new_password confirm_new_password)];
my($_NAME_FIELDS) = [map("User.${_}_name", qw(first middle last))];

sub execute_empty {
    my($self) = @_;
    foreach my $m (qw(RealmOwner User)) {
	$self->load_from_model_properties($self->new_other($m)->load);
    }
    return shift->SUPER::execute_empty(@_);
}

sub execute_ok {
    my($self) = @_;
    $self->new_other('User')->load->update($self->get_model_properties('User'));
    $self->new_other('RealmOwner')->load
	->update($self->get_model_properties('RealmOwner'))
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
    my($self, $method) = @_;
    my($req) = $self->req;
    $self->internal_put_field(
	show_name => $req->is_substitute_user || $req->is_super_user ? 1 : 0);
    return;
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
