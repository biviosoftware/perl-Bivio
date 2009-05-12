# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::AdmSubstituteUserForm;
use strict;
use Bivio::Base 'Biz.FormModel';
use Bivio::IO::Trace;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_LQ) = b_use('SQL.ListQuery');
my($_DEFAULT_TASK) = b_use('Agent.TaskId')->ADM_SUBSTITUTE_USER;

sub SUPER_USER_FIELD {
    # : string
    # Returns the cookie key for the super user value.
    return 's';
}

sub execute_empty {
    # (self) : undef
    # Perform lookup and su automatically if coming in with query string.
    my($self) = @_;
    my($req) = $self->get_request;
    my($this) = ($req->unsafe_get('query') || {})
	->{$_LQ->to_char('this')};
    return unless $this;
    $self->internal_put_field(login => $this);
    $req->put(query => {});
    return $self->validate_and_execute_ok($self->OK_BUTTON_NAME);
}

sub execute_ok {
    # (self) : boolean
    # Logs in the I<realm_owner> and updates the cookie.
    my($self) = @_;
    # user is validated in internal_pre_execute
    return $self->new_other('UserLoginForm')->substitute_user(
	$self->get('realm_owner'),
	$self->get_request,
    );
}

sub internal_initialize {
    # (self) : hash_ref;
    # B<FOR INTERNAL USE ONLY>
    my($self) = @_;
    return $self->merge_initialize_info(
	$self->SUPER::internal_initialize, {
	    version => 1,
	    require_validate => 1,
	    visible => [
		{
		    name => 'login',
		    type => 'Line',
		    constraint => 'NOT_NULL',
		},
	    ],
	    other => [
		{
		    name => 'realm_owner',
		    type => 'Model.RealmOwner',
		    constraint => 'NONE',
		},
	    ],
	},
    );
}

sub su_logout {
    # (self, Agent.Request) : Agent.TaskId
    # Logout as substitute user, return to super user.
    # Return next task (if any).
    my($self) = @_;
    my($req) = $self->req;
    my($su) = $req->get('super_user_id');
    $req->delete('super_user_id');
    $req->get('cookie')->delete($self->SUPER_USER_FIELD)
	if $req->unsafe_get('cookie');
    my($realm) = $self->new_other('RealmOwner');
    $self->new_other('UserLoginForm')->process({
	realm_owner => $realm->unauth_load({realm_id => $su})
	    ? $realm : undef,
    });
    _trace($realm) if $_TRACE;
    return $realm->is_loaded && $req->unsafe_get('task')
	? $req->get('task')->unsafe_get_attr_as_id('su_task') || $_DEFAULT_TASK
	: 0;
}

sub validate {
    my($self) = @_;
    $self->internal_put_field(realm_owner =>
	$self->get_instance('UserLoginForm')->validate_login($self)
    ) unless $self->in_error;
    return;
}

1;
