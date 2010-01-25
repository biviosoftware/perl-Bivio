# Copyright (c) 2008-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserSettingsListForm;
use strict;
use Bivio::Base 'Biz.ListFormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_NAME_FIELDS) = [map("User.${_}_name", qw(first middle last))];
my($_MAIL_RECIPIENT) = b_use('Auth.Role')->MAIL_RECIPIENT;

sub execute_empty_row {
    my($self) = @_;
    $self->internal_put_field(is_subscribed => _is_subscribed($self));
    return;
}

sub execute_empty_start {
    my($self) = @_;
    foreach my $m (qw(RealmOwner User Email)) {
	$self->load_from_model_properties($self->new_other($m)->load);
    }
    $self->internal_put_field(
	_map_row_tags($self, sub {
           my($field, $type) = @_;
	   return ($field => $type->row_tag_get($self->req));
	}),
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
    _map_row_tags($self, sub {
        my($field, $type) = @_;
	$type->row_tag_replace($self->get($field), $self->req);
	return;
    });
    if ($self->unsafe_get('show_name')) {
	$ro->update($self->get_model_properties('RealmOwner'));
    }
    if ($self->unsafe_get('show_email')) {
	$self->new_other('Email')->load->update(
	    $self->get_model_properties('Email'));
    }
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
	    'Email.email',
	    $self->field_decl([
                [qw(page_size PageSize NOT_NULL)],
                [qw(time_zone_selector TimeZoneSelector NOT_NULL)],
		[qw(is_subscribed Boolean), {in_list => 1}],
	    ]),
	],
	other => [
	    $self->field_decl([qw(
		show_name
		show_email
	    )], 'Boolean', 'NOT_NULL'),
	    'RealmOwner.realm_id',
	],
    });
}

sub internal_initialize_list {
    return shift->new_other('UserSubscriptionList')->load_all_qualified_realms;
}

sub internal_pre_execute {
    my($self) = @_;
    my($req) = $self->req;
    $self->new_other('TimeZoneList')->load_all;
    $self->internal_put_field(
	show_name => $req->is_substitute_user || $req->is_super_user ? 1 : 0);
    $self->internal_put_field(show_email => $req->is_substitute_user);
    return shift->SUPER::internal_pre_execute(@_);
}

sub validate_start {
    my($self) = @_;
    $self->internal_put_error('User.first_name', 'NULL')
	unless _is_name_set($self);
    $self->internal_clear_error('RealmOwner.name')
	unless $self->get('show_name');
    $self->internal_clear_error('Email.email')
	unless $self->get('show_email');
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

sub _map_row_tags {
    my($self, $op) = @_;
    return map(
	$op->($_, $self->get_field_type($_)),
	qw(page_size time_zone_selector),
    );
}

1;
