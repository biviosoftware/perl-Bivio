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

A note about URI vs URL.  Basically, we use URI everywhere.  [RJN: I don't
understand the distinction, but there is a distinction and RFC2616 uses
URI for the most part, so we do, too.]

=cut

#=IMPORTS
use Bivio::Type::DateTime;
use Bivio::HTML;
use Bivio::Ext::ApacheConstants;
use Bivio::Agent::HTTP::Cookie;
use Bivio::Agent::HTTP::Form;
use Bivio::Agent::HTTP::Location;
use Bivio::Agent::HTTP::Query;
use Bivio::Agent::HTTP::Reply;
use Bivio::Agent::Task;
use Bivio::Auth::Role;
use Bivio::Die;
use Bivio::DieCode;
use Bivio::IO::Trace;
# Avoid circular import
#use Bivio::Biz::Action::Logout;
use Bivio::Type::UserAgent;
use Socket;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Apache::Request r) : Bivio::Agent::HTTP::Request

Creates a Request from an apache request.  The target and path are
separated.

=cut

sub new {
    my($proto, $r) = @_;
    my($start_time) = Bivio::Type::DateTime->gettimeofday();
    # Set remote IP address if passed through Via: header
    my($via) = $r->header_in('via');
    $r->connection->remote_ip($via) if defined($via);
    # Sets Bivio::Agent::Request->get_current, so do the minimal thing
    my($self) = Bivio::Agent::Request::internal_new($proto, {
	start_time => $start_time,
	reply => Bivio::Agent::HTTP::Reply->new($r),
	r => $r,
	client_addr => $r->connection->remote_ip,
	is_secure => $ENV{HTTPS} || _is_hack_https_port($r)
	? 1 : 0,
    });

    Bivio::Type::UserAgent->put_on_request(
	    $r->header_in('user-agent') || '', $self);

    # Cookie parsed first, so referral and log code works properly.
    my($cookie) = Bivio::Agent::HTTP::Cookie->new($self, $r);
    # We must put the cookie now, because it may be used below.
    $self->put(cookie => $cookie);

    # Location next, because may not be found or location may want
    # to clear 'auth_user_id'.
    my($uri) = $r->uri;
    my($task_id, $auth_realm, $path_info);
    ($task_id, $auth_realm, $path_info, $uri)
	    = Bivio::Agent::HTTP::Location->parse($self, $uri);

    # We have a Facade, so Request is "pretty much initialized".
    $self->internal_set_current();

    # Must re-escape the URI.
    $uri = Bivio::HTML->escape_uri($uri) if $uri;

    # This special field is set by one of the handlers (LoginForm).
    my($auth_user_id) = $self->unsafe_get('auth_user_id');
    my($auth_user);
    if ($auth_user_id) {
	$auth_user = Bivio::Biz::Model::RealmOwner->new($self);
	unless ($auth_user->unauth_load(
		realm_id => $auth_user_id,
		realm_type => Bivio::Auth::RealmType::USER())) {
	    # Unknown user, so force logout (which clears cookie)
	    Bivio::IO::Alert->warn($auth_user_id,
		    ': user_id not found, logging out');
	    Bivio::Biz::Model::LoginForm->invalidate_user($self);
	    $auth_user = undef;
	}
    }

    # NOTE: Syntax is weird to avoid passing $r->args in an array context
    # which avoids parsing $r->args.
    my($query) = Bivio::Agent::HTTP::Query->parse(scalar($r->args));

    _trace($r->method, ': query=', $query, '; path_info=', $path_info)
	    if $_TRACE;

    # AUTH: Make sure the auth_id is NEVER set by the user.
    #       We are making a presumption about how the models work.
    #       However, it is reasonable to assume that there should never
    #       be a query or form field called "auth_id".
    delete($query->{auth_id}) if $query;

    $self->put(
	    uri => $uri,
	    query => $query,
	    path_info => $path_info,
	    task_id => $task_id,
	   );
    $self->internal_initialize($auth_realm, $auth_user);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="client_redirect"></a>

=head2 client_redirect(string new_uri, hash_ref new_query)

=head2 client_redirect(string new_uri, string new_query)

=head2 client_redirect(Bivio::Agent::TaskId new_task, Bivio::Auth::Realm new_realm, hash_ref new_query, string new_path_info)

=head2 client_redirect(Bivio::Agent::TaskId new_task, Bivio::Auth::Realm new_realm, string new_query, string new_path_info)

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
	my($new_task, $new_realm, $new_query, $new_path_info) = @_;

	# use previous query if not specified, maintains state across pages
	if (int(@_) <= 2) {
	    $new_query = $self->get('query');
	    $new_path_info = $self->unsafe_get('path_info')
		    if int(@_) <= 3;
	}

	# server_redirect if same task or if task doesn't have a uri
	$self->SUPER::server_redirect($new_task, $new_realm, $new_query,
		$new_path_info)
		if $new_task eq $self->get('task_id')
		    || !Bivio::Agent::HTTP::Location->task_has_uri($new_task);

	$uri = $self->format_uri($new_task, $new_query,
		defined($new_realm) ? $new_realm
		: $self->get_realm_for_task($new_task),
		$new_path_info);
    }
    else {
	my($new_uri, $new_query) = @_;
	$self->SUPER::server_redirect($self->get('task_id'), undef, $new_query)
		if $new_uri eq $self->get('uri');
	$uri = $new_uri;
	$new_query = Bivio::Agent::HTTP::Query->format($new_query)
		if ref($new_query);
	$uri =~ s/\?/\?$new_query&/ || ($uri .= '?'.$new_query)
		if defined($new_query) && length($new_query);
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
    $uri =~ s/\?/\?$query&/ || ($uri .= '?'.$query) if $query;

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

=head2 server_redirect(string new_uri, hash_ref new_query, hash_ref new_form, string new_path_info)

=head2 server_redirect(string new_uri, string new_query, hash_ref new_form, string new_path_info)

=head2 server_redirect(Bivio::Agent::TaskId new_task, Bivio::Auth::Realm new_realm, hash_ref new_query, hash_ref new_form, string new_path_info)

=head2 server_redirect(Bivio::Agent::TaskId new_task, Bivio::Auth::Realm new_realm, string new_query, hash_ref new_form, string new_path_info)

Server-side (aka internal) redirect to the new task within the new realm.

If I<new_uri> supplied, parses out the task, realm, and new_path_info
from the uri and then calls C<SUPER::redirect>.

B<DOES NOT RETURN.>

=cut

sub server_redirect {
    my($self) = shift;
    # If the task is specified already, let super handle it.
    $self->SUPER::server_redirect(@_) if ref($_[0]);

    # Need to parse out task and realm from uri
    die('too many args') if int(@_) > 4;
    my($new_uri, $new_query, $new_form, $new_path_info) = @_;
    my($new_task, $new_realm, $path_info_from_uri)
	    = Bivio::Agent::HTTP::Location->parse($self, $new_uri);
    # Replace path_info (if not set)
    $new_path_info ||= $path_info_from_uri if int(@_) <= 3;
    $self->SUPER::server_redirect($new_task, $new_realm, $new_query,
	    $new_form, $new_path_info);
}

=for html <a name="server_redirect_in_handle_die"></a>

=head2 server_redirect_in_handle_die(string new_uri, hash_ref new_query, hash_ref new_form, string new_path_info)

=head2 server_redirect_in_handle_die(string new_uri, string new_query, hash_ref new_form, string new_path_info)

=head2 server_redirect_in_handle_die(Bivio::Agent::TaskId new_task, Bivio::Auth::Realm new_realm, hash_ref new_query, hash_ref new_form, string new_path_info)

=head2 server_redirect_in_handle_die(Bivio::Agent::TaskId new_task, Bivio::Auth::Realm new_realm, string new_query, hash_ref new_form, string new_path_info)

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

    # Need to parse out task and realm from uri
    die('too many args') if int(@_) > 4;
    my($new_uri, $new_query, $new_form, $new_path_info) = @_;
    my($new_task, $new_realm, $path_info_from_uri)
	    = Bivio::Agent::HTTP::Location->parse($self, $new_uri);
    # Replace path_info (if not set)
    $new_path_info ||= $path_info_from_uri if int(@_) <= 3;
    $self->SUPER::server_redirect_in_handle_die($new_task, $new_realm,
	    $new_query, $new_form, $new_path_info);
    return;
}


#=PRIVATE METHODS

# _is_hack_https_port(Apache r) : boolean
#
# Returns true if the local port is 81.  We are using this hack between
# the front-end and the middle tier to indicate it is running in secure
# mode.
#
sub _is_hack_https_port {
    my($r) = @_;
    my($port) = unpack_sockaddr_in($r->connection->local_addr());
    return $port == 81 ? 1 : 0;
}

=head1 SEE ALSO

RFC2616 (HTTP/1.1), RFC1945 (HTTP/1.0), RFC1867 (multipart/form-data),
RFC2109 (Cookies), RFC1630 (URI), RFC1738 (URL), RFC2396 (new URI),
RFC1808 (Relative URL)

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
