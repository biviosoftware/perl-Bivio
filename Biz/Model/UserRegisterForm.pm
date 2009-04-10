# Copyright (c) 2005-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserRegisterForm;
use strict;
use Bivio::Base 'Model.UserCreateForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_A) = b_use('Action.Acknowledgement');
my($_BR) = b_use('Biz.Random');
my($_R) = b_use('Auth.Role');
my($_SF) = b_use('ShellUtil.SiteForum');
my($_UNKNOWN) = b_use('Bivio.TypeError')->UNKNOWN;
my($_UPQ) = b_use('Action.UserPasswordQuery');
my($_UPQF) = b_use('Model.UserPasswordQueryForm');

sub add_site_admin_user {
    my($self, $user) = @_;
    $self->req->with_realm($_SF->ADMIN_REALM, sub {
        $self->new_other('GroupUserForm')->change_main_role(
            $self->req(qw(Model.User user_id)), $_R->USER);
    });
    return;
}

sub execute_ok {
    my($self, ) = @_;
    my($r) = $self->internal_create_models;
    $self->req->set_realm($r);
    return
	if $self->unsafe_get('password_ok');
    $self->internal_put_field(
	uri => $_UPQ->format_uri($self->req),
    );
    $self->put_on_request(1);
    $self->if_unapproved_applicant_mode(sub {
	$self->new_other('GroupUserForm')->create_unapproved_applicant(
	    $self->get('User.user_id'));
	return;
    });
    return {
	method => 'server_redirect',
	task_id => 'next',
	query => undef,
    };
}

sub internal_create_models {
    my($self) = @_;
    $self->internal_put_field(
	'RealmOwner.display_name' => substr(
	    ($self->get('Email.email') =~ /^(.*)\@/)[0] || 'x',
	    0,
	    $self->get_instance('User')->get_field_type('last_name')->get_width,
	 ),
    ) unless $self->unsafe_get('RealmOwner.display_name');
    $self->internal_put_field('RealmOwner.password' => $_BR->password)
	unless $self->unsafe_get('RealmOwner.password')
	&& $self->unsafe_get('password_ok');
    return shift->SUPER::internal_create_models(@_);
}

sub internal_initialize {
    my($self) = @_;
    my($info) = shift->SUPER::internal_initialize(@_);
    @{$info->{visible}} = grep(
	ref($_) && $_->{type} && $_->{type} =~ /Button/,
	@{$info->{visible}});
    return $self->merge_initialize_info($info, {
        version => 1,
	visible => [
	    'Email.email',
	    {
		name => 'RealmOwner.display_name',
		constraint => 'NONE',
	    },
	],
	other => [
	    {
		name => 'RealmOwner.password',
		constraint => 'NONE',
	    },
	    $self->field_decl([[qw(uri String)]]),
	],
    });
}

sub internal_post_execute {
    my($self) = @_;
    my(@res) = shift->SUPER::internal_post_execute(@_);
    return @res
	unless ($self->get_field_error('Email.email') || $_UNKNOWN)->eq_exists;
    my($q) = $_UPQF->add_email_to_query($self->get('Email.email'));
    $_A->save_label('user_exists', $self->req, $q);
    $self->clear_errors;
    return {
	task_id => 'user_exists_task',
	query => $q,
    };
}

sub validate {
    return;
}

1;
