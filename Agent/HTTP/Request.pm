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
use Bivio::Agent::HTTP::Form;
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
	client_addr => $r->connection->remote_ip,
	is_secure => $ENV{HTTPS} ? 1 : 0,
    });
    my($uri) = $r->uri;
    my($task_id, $auth_realm)
	    = Bivio::Agent::HTTP::Location->parse($self, $uri);
    my($auth_user) = Bivio::Agent::HTTP::Cookie->parse($self, $r);
#TODO: Make secure.  Need to watch for large queries and forms here.
    # NOTE: Syntax is weird to avoid passing $r->args in an array context
    # which avoids parsing $r->args.
    my $qs = $r->args;
#TODO: Apache bug: ?bla&foo=1 will generate "odd number elements in hash"
#      warning.
    my($query) = defined($qs) ? {$r->args} : undef;
    _trace($r->method, ': query=', $query) if $_TRACE;

    # AUTH: Make sure the auth_id is NEVER set by the user.
    #       We are making a presumption about how the models work.
    #       However, it is reasonable to assume that there should never
    #       be a query or form field called "auth_id".
    delete($query->{auth_id}) if $query;

    $self->put(
	    uri => $uri,
	    query => $query,
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

	# use previous query if not specifed, maintains state across pages
	$new_query ||= $self->get('query');

	# server_redirect if same task or if task doesn't have a uri
	$self->SUPER::server_redirect($new_task, $new_realm, $new_query)
		if $new_task eq $self->get('task_id')
		    || !Bivio::Agent::HTTP::Location->task_has_uri($new_task);

	$self->internal_redirect_realm($new_task, $new_realm);
	$uri = $self->format_uri($new_task, $new_query);

    }
    else {
	my($new_uri, $new_query) = @_;
	$self->SUPER::server_redirect($self->get('task_id'), undef, $new_query)
		if $new_uri eq $self->get('uri');
	$uri = $new_uri;
	if ($new_query) {
	    my($query) = Bivio::Agent::HTTP::Query->format($new_query);
	    $uri =~ s/\?/?$query&/ || ($uri .= '?'.$query);
	}
    }
    $self->get('reply')->client_redirect($self, $uri);
    Bivio::Die->die(Bivio::DieCode::CLIENT_REDIRECT_TASK());
}

=for html <a name="format_http_toggling_secure"></a>

=head2 format_http_toggling_secure() : string

Formats the uri for this request, but toggles secure mode.  This
is a very special and only used in one location--thank goodness!

=cut

sub format_http_toggling_secure {
    my($self) = @_;
    my($is_secure, $host, $r, $redirect_count, $uri, $query) = $self->get(
	    qw(is_secure http_host r redirect_count uri query));

    # This is particularly strange.  FormModel deletes the incoming
    # query context.   If we haven't internally redirected, we use
    # the original query string so we get the format_context.  If
    # we redirected, don't bother with the form_context.
#TODO: This is screwed up.  Probably best to take the current
#      form's context and shove it on the URL.  Wouldn't hurt if not
#      really the form_model.
    $query = $redirect_count ? Bivio::Agent::HTTP::Query->format($query)
	    : $r->args;
    $uri =~ s/\?/?$query&/ || ($uri .= '?'.$query) if $query;

    # Go into secure if not secure and vice-versa
    return ($is_secure ? 'http://' : 'https://').$host.$uri;
}

=for html <a name="get_form"></a>

=head2 get_form() : hash_ref

Returns form associated the request or C<undef> if no form.
I<form_model> must be set.

=cut

sub get_form {
    my($self) = @_;

    # Parsed already or perhaps set via context
    return $self->get('form') if $self->has_keys('form');

    my($form) = Bivio::Agent::HTTP::Form->parse($self);
    $self->put(form => $form);
    return $form;
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

Tags the user specially if I<super_user_id> is set on this request.

=cut

sub set_user {
    my($self) = shift;
    $self->SUPER::set_user(@_);
    my($user) = shift;
    $user = defined($user) ? $user->get('name') : $_ANONYMOUS;
    $user = 'su-'.$user if $self->unsafe_get('super_user_id');
    $self->get('r')->connection->user($user);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
