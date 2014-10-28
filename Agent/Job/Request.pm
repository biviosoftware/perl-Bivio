# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Agent::Job::Request;
use strict;
use Bivio::Base 'Agent.Request';

my($_IGNORE_REDIRECTS) = __PACKAGE__.'.ignore_redirects';

sub agent_execution_is_secure {
    return 1;
}

sub client_redirect {
    # (self, ...) : undef
    # Will set redirect values but not throw the exception if
    # L<ignore_redirects|"ignore_redirects"> was called.
    # Otherwise passes off to SUPER.
    my($self) = shift;
    return $self->unsafe_get($_IGNORE_REDIRECTS)
	? $self->internal_server_redirect(@_)
	: $self->SUPER::client_redirect(@_);
}

sub ignore_redirects {
    # (self, boolean) : undef
    # Sets internal state to ignore redirects if I<state> is true.
    # This can be dangerous.
    #
    # Will set the new state, but not throw the exception.
    #
    # B<EXPERIMENTAL>
    my($self, $state) = @_;
    $self->put_durable($_IGNORE_REDIRECTS => $state);
    return;
}

sub internal_need_to_toggle_secure_agent_execution {
    return 0;
}

sub new {
    # (proto, hash_ref) : Job.Request
    # Creates a Request from the queued I<params>.
    my($proto, $params) = @_;
    my($start_time) = Bivio::Type::DateTime->gettimeofday();
#TODO: Need to handle Facades!
    my($self) = $proto->internal_new({
	# We set the params here, because we want to override values
	%$params,
	start_time => $start_time,
	form => undef,
	query => undef,
	path_info => undef,
	# Needed by Task->execute, but not used here
	reply => b_use('Agent.Reply')->new,
    });
    b_use('Type.UserAgent')->execute_job($self, 1);
    my($realm) = $params->{auth_id}
	&& $params->{auth_id} != b_use('Auth.RealmType')->GENERAL->as_default_owner_id
	? b_use('Auth.Realm')->new($params->{auth_id}, $self)
	: b_use('Auth.Realm')->get_general;
    $self->internal_set_current;
    my($auth_user);
    if ($params->{auth_user_id}) {
	$auth_user = Bivio::Biz::Model->new($self, 'RealmOwner')
		->unauth_load_or_die(realm_id => $params->{auth_user_id});
    }
    $self->internal_initialize($realm, $auth_user);
    return $self;
}

sub server_redirect {
    # (self, ...) : undef
    # Will set redirect values but not throw the exception if
    # L<ignore_redirects|"ignore_redirects"> was called.
    # Otherwise passes off to SUPER.
    my($self) = shift;
    return $self->unsafe_get($_IGNORE_REDIRECTS)
	? $self->internal_server_redirect(@_)
	: $self->SUPER::server_redirect(@_);
}

1;
