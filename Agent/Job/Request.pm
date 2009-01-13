# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Agent::Job::Request;
use strict;
use Bivio::Base 'Agent.Request';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IGNORE_REDIRECTS) = __PACKAGE__.'.ignore_redirects';

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
	# Needed by Task->execute, but not used here
	reply => Bivio::Agent::Reply->new(),
    });
    Bivio::Type::UserAgent->execute_job($self);
    $self->put_durable(
	%$params,
	start_time => $self->get('start_time'),
	form => $self->get('form'),
	query => $self->get('query'),
	reply => $self->get('reply'),
	'Bivio::Type::UserAgent' => $self->get('Bivio::Type::UserAgent'),
    );
    my($realm) = $params->{auth_id}
	&& $params->{auth_id} != Bivio::Auth::RealmType->GENERAL()->as_int
	? Bivio::Auth::Realm->new($params->{auth_id}, $self)
	: Bivio::Auth::Realm->get_general();
    $self->internal_set_current();
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
