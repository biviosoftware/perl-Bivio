# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Agent::Job::Request;
use strict;
$Bivio::Agent::Job::Request::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Agent::Job::Request::VERSION;

=head1 NAME

Bivio::Agent::Job::Request - Bivio::Agent::Request wrapper for jobs

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Agent::Job::Request;
    Bivio::Agent::Job::Request->new($params);

=cut

=head1 EXTENDS

L<Bivio::Agent::Request>

=cut

use Bivio::Agent::Request;
@Bivio::Agent::Job::Request::ISA = qw(Bivio::Agent::Request);

=head1 DESCRIPTION

C<Bivio::Agent::Job::Request> sets the params appropriately.  It
loads a new auth_realm every time.

=cut

#=IMPORTS
use Bivio::Agent::Reply;
use Bivio::Auth::Realm;
use Bivio::Auth::RealmType;
use Bivio::Biz::Model;
use Bivio::Type::DateTime;
use Bivio::Type::UserAgent;

#=VARIABLES
my($_GENERAL);
my($_IGNORE_REDIRECTS) = __PACKAGE__.'.ignore_redirects';

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref params) : Bivio::Agent::Job::Request

Creates a Request from the queued I<params>.

=cut

sub new {
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

    # all attributes need to be durable
    $self->put_durable(
	    %$params,
	    start_time => $self->get('start_time'),
	    form => $self->get('form'),
	    query => $self->get('query'),
	    reply => $self->get('reply'),
	    'Bivio::Type::UserAgent' => $self->get('Bivio::Type::UserAgent'),
	   );

    # Realm
    my($realm);
    if ($params->{auth_id} && $params->{auth_id}
            != Bivio::Auth::RealmType::GENERAL()->as_int) {
	$realm = Bivio::Auth::Realm->new($params->{auth_id}, $self);
    }
    else {
	$_GENERAL = Bivio::Auth::Realm::General->new unless $_GENERAL;
	$realm = $_GENERAL;
    }
    $self->internal_set_current();

    # User
    my($auth_user);
    if ($params->{auth_user_id}) {
	$auth_user = Bivio::Biz::Model->new($self, 'RealmOwner')
		->unauth_load_or_die(realm_id => $params->{auth_user_id});
    }
    $self->internal_initialize($realm, $auth_user);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="client_redirect"></a>

=head2 client_redirect(Bivio::Agent::TaskId new_task, Bivio::Auth::Realm new_realm, hash_ref new_query, string new_path_info, boolean no_context)

Will set redirect values but not throw the exception if
L<ignore_redirects|"ignore_redirects"> was called.
Otherwise passes off to SUPER.

=cut

sub client_redirect {
    my($self) = shift;
    return $self->unsafe_get($_IGNORE_REDIRECTS)
	? $self->internal_server_redirect(@_)
	: $self->SUPER::client_redirect(@_);
}

=for html <a name="ignore_redirects"></a>

=head2 ignore_redirects()

Sets internal state to ignore redirects.  This can be dangerous.

Will set the new state, but not throw the exception.

B<EXPERIMENTAL>


=cut

sub ignore_redirects {
    my($self) = @_;
    $self->put_durable($_IGNORE_REDIRECTS => 1);
    return;
}

=for html <a name="server_redirect"></a>

=head2 server_redirect(Bivio::Agent::TaskId new_task, Bivio::Auth::Realm new_realm, hash_ref new_query, hash_ref new_form, string new_path_info, boolean no_context)

=head2 server_redirect(Bivio::Agent::TaskId new_task, Bivio::Auth::Realm new_realm, string new_query, hash_ref new_form, string new_path_info, boolean no_context)

Will set redirect values but not throw the exception if
L<ignore_redirects|"ignore_redirects"> was called.
Otherwise passes off to SUPER.

=cut

sub server_redirect {
    my($self) = shift;
    return $self->unsafe_get($_IGNORE_REDIRECTS)
	? $self->internal_server_redirect(@_)
	: $self->SUPER::server_redirect(@_);
}

#=PRIVATE METHODS

=head1 SEE ALSO

Bivio::Job::Incoming

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
