# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::Request;
use strict;
$Bivio::Agent::HTTP::Request::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Agent::HTTP::Request - An HTTP Request

=head1 EXTENDS

L<Bivio::Agent::Request>

=cut

use Bivio::Agent::Request;
@Bivio::Agent::HTTP::Request::ISA = qw(Bivio::Agent::Request);

=head1 DESCRIPTION

C<Bivio::Agent::HTTP::Request> is a Bivio Request wrapper for an
Apache::Request. It gathers request information from the URI and posted
parameters.

=cut

#=IMPORTS
use Apache::Constants;
use Bivio::Agent::HTTP::Cookie;
use Bivio::Agent::HTTP::CookieState;
use Bivio::Agent::HTTP::Location;
use Bivio::Agent::HTTP::Query;
use Bivio::Agent::HTTP::Reply;
use Bivio::Agent::Task;
use Bivio::Auth::RealmType;
use Bivio::Auth::Role;
use Bivio::Biz::Model::RealmOwner;
use Bivio::Die;
use Bivio::DieCode;
use Bivio::IO::Trace;
use Bivio::Util;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_ANONYMOUS) = Bivio::Auth::Role::ANONYMOUS->get_name;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Apache::Request r) : Bivio::Agent::HTTP::Request

Creates a Request from an apache request.  The target and path are
separated.

=cut

sub new {
    my($proto, $r) = @_;
    my($start_time) = Bivio::Util::gettimeofday();
    # Sets Bivio::Agent::Request->get_current, so do the minimal thing
    my($self) = Bivio::Agent::Request::new($proto, {
	start_time => $start_time,
	reply => Bivio::Agent::HTTP::Reply->new($r),
	r => $r,
    });
    my($uri) = $r->uri;
    my($task_id, $auth_realm)
	    = Bivio::Agent::HTTP::Location->parse($self, $uri);
    my($auth_user) = Bivio::Agent::HTTP::Cookie->parse($self, $r);
#TODO: Make secure.  Need to watch for large queries and forms here.
    # NOTE: Syntax is weird to avoid passing $r->args in an array context
    # which avoids parsing $r->args.
    my $query_string = $r->args;
#TODO: Apache bug: ?bla&foo=1 will generate "odd number elements in hash"
#      warning.
    my($query) = defined($query_string) ? {$r->args} : undef;
    my($form) = $r->method_number() eq Apache::Constants::M_POST()
	    ? {$r->content()} : undef;
    _trace($r->method, ': form=', $form, '; query=', $query) if $_TRACE;

    # AUTH: Make sure the auth_id is NEVER set by the user.
    #       We are making a presumption about how the models work.
    #       However, it is reasonable to assume that there should never
    #       be a query or form field called "auth_id".
    delete($query->{auth_id}) if $query;
    delete($form->{auth_id}) if $form;

    $self->put(
	    uri => $uri,
	    form => $form,
	    query => $query,
	    query_string => $query_string,
	    task_id => $task_id,
	   );
    $self->internal_initialize($auth_realm, $auth_user);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="client_redirect"></a>

=head2 client_redirect(string new_uri, hash_ref new_query)

=head2 client_redirect(Bivio::Agent::TaskId new_task, Bivio::Auth::Realm new_realm, hash_ref new_query)

Client side redirect to the new task within the new realm.  If I<new_task>
is the same as the current task, does an server_redirect.  Otherwise,
tells client to come back in.

B<DOES NOT RETURN.>

=cut

sub client_redirect {
    my($self) = shift;
    # do internal redirect if task is the same, avoids bad browser behavior
    # when redirecting to same uri.
    my($uri);
    if (ref($_[0])) {
	my($new_task, $new_realm, $new_query) = @_;
	$self->SUPER::server_redirect($new_task, $new_realm, $new_query)
		if $new_task eq $self->get('task_id');
	$self->internal_redirect_realm($new_task, $new_realm);
	$uri = $self->format_uri($new_task, $new_query);
    }
    else {
	my($new_uri, $new_query) = @_;
	$self->SUPER::server_redirect($self->get('task_id'), undef, $new_query)
		if $new_uri eq $self->get('uri');
	$uri = $new_uri;
	$uri .= '?'.Bivio::Agent::HTTP::Query->format($new_query)
		if $new_query;
    }
    $self->get('reply')->client_redirect($self, $uri);
    Bivio::Die->die(Bivio::DieCode::CLIENT_REDIRECT_TASK());
}

=for html <a name="format_stateless_uri"></a>

=head2 format_stateless_uri(Bivio::Agent::TaskId task_id) : string

Creates a URI relative to this host/port/realm without a query string.

=cut

sub format_stateless_uri {
    my($self, $task_id) = @_;
    return $self->format_uri($task_id, undef);
}

=for html <a name="format_uri"></a>

=head2 format_uri(Bivio::Agent::TaskId task_id, string query, Bivio::Auth::Realm auth_realm) : string

=head2 format_uri(Bivio::Agent::TaskId task_id, hash_ref query, Bivio::Auth::Realm auth_realm) : string

Creates a URI relative to this host/port.
If I<query> is C<undef>, will not create a query string.
If I<query> is not passed, will use this request's query string.
If I<auth_realm> is C<undef>, request's realm will be used.

=cut

sub format_uri {
    my($self, $task_id, $query, $auth_realm) = @_;
    # Note: Bivio::Agent::Mail::Request may call this.
    $task_id = $self->get_widget_value(@$task_id) if ref($task_id) eq 'ARRAY';
    $query = $self->get_widget_value(@$query) if ref($query) eq 'ARRAY';
    $auth_realm = $self->get_widget_value(@$auth_realm)
	    if ref($auth_realm) eq 'ARRAY';
    $task_id = $self->get('task_id') unless $task_id;
    # Allow the realm to be undef
    my($uri) = Bivio::Agent::HTTP::Location->format(
	    $task_id, int(@_) >= 4 ? $auth_realm :
	    $self->internal_get_realm_for_task($task_id));
#TODO: Is this right?
#PJM: I think so
    $query = $self->get('query_string') unless int(@_) >= 3;
    return $uri unless defined($query);
    $query = Bivio::Agent::HTTP::Query->format($query) if ref($query);
    return $uri.'?'.$query unless ref($query);
}

=for html <a name="server_redirect"></a>

=head2 server_redirect(string new_uri, hash_ref new_query, hash_ref new_form)

=head2 server_redirect(Bivio::Agent::TaskId new_task, Bivio::Auth::Realm new_realm, hash_ref new_query, hash_ref new_form)

Server-side (aka internal) redirect to the new task within the new realm.

If I<new_uri> supplied, parses out the task and realm from the uri
and then calls C<SUPER::redirect>.

B<DOES NOT RETURN.>

=cut

sub server_redirect {
    my($self) = shift;
    # If the task is specified already, let super handle it.
    $self->SUPER::server_redirect(@_) if ref($_[0]);

    # Need to parse out task from uri
    my($new_uri) = shift;
    my($new_task, $new_realm) = Bivio::Agent::HTTP::Location->parse(
	    $self, $new_uri);
    $self->SUPER::server_redirect($new_task, $new_realm, @_);
}

=for html <a name="server_redirect_in_handle_die"></a>

=head2 server_redirect_in_handle_die(string new_uri, hash_ref new_query, hash_ref new_form)

=head2 server_redirect_in_handle_die(Bivio::Agent::TaskId new_task, Bivio::Auth::Realm new_realm, hash_ref new_query, hash_ref new_form)

Server-side (aka internal) redirect to the new task within the new realm.

If I<new_uri> supplied, parses out the task and realm from the uri
and then calls C<SUPER::redirect>.

B<DOES NOT RETURN.>

=cut

sub server_redirect_in_handle_die {
    my($self, $die) = (shift, shift);
    # If the task is specified already, let super handle it.
    $self->SUPER::server_redirect_in_handle_die($die, @_), return
	    if ref($_[0]);

    # Need to parse out task from uri
    my($new_uri) = shift;
    my($new_task, $new_realm) = Bivio::Agent::HTTP::Location->parse(
	    $self, $new_uri);
    $self->SUPER::server_redirect_in_handle_die($die, $new_task,
	    $new_realm, @_);
    return;
}

=for html <a name="set_user"></a>

=head2 set_user(Bivio::Biz::Model::RealmOwner user)

Sets I<user> to be C<auth_user>.  May be C<undef>.  Also caches
user_realms and updates user in connection for logging.

=cut

sub set_user {
    my($self) = shift;
    $self->SUPER::set_user(@_);
    my($user) = shift;
    $self->get('r')->connection->user(
	    defined($user) ? $user->get('name') : $_ANONYMOUS);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
