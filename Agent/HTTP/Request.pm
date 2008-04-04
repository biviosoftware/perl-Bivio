# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::Request;
use strict;
$Bivio::Agent::HTTP::Request::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Agent::HTTP::Request::VERSION;

=head1 NAME

Bivio::Agent::HTTP::Request - An HTTP Request

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

   use Bivio::Agent::HTTP::Request;

=head1 EXTENDS

L<Bivio::Agent::Request>

=cut

use Bivio::Agent::Request;
@Bivio::Agent::HTTP::Request::ISA = ('Bivio::Agent::Request');

=head1 DESCRIPTION

C<Bivio::Agent::HTTP::Request> is a Bivio Request wrapper for an
Apache::Request. It gathers request information from the URI and posted
parameters.

A note about URI vs URL.  Basically, we use URI everywhere.  [RJN: I don't
understand the distinction, but there is a distinction and RFC2616 uses
URI for the most part, so we do, too.]

=cut

#=IMPORTS
use Bivio::Agent::HTTP::Cookie;
use Bivio::Agent::HTTP::Form;
use Bivio::Agent::HTTP::Query;
use Bivio::Agent::HTTP::Reply;
use Bivio::Auth::RealmType;
use Bivio::Auth::Support;
use Bivio::Die;
use Bivio::DieCode;
use Bivio::HTML;
use Bivio::IO::Trace;
use Bivio::Type::DateTime;
use Bivio::Type::UserAgent;
# needed for is_https_port()
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
    # Set remote IP address if passed through by mod_proxy (RH6.2 and RH7.2)
    $r->connection->remote_ip($1)
	if ($r->header_in('x-forwarded-for') || $r->header_in('via') || '')
	    =~ /((?:\d+\.){3}\d+)/;
    # Sets Bivio::Agent::Request->get_current, so do the minimal thing
    my($self) = $proto->internal_new({
	start_time => $start_time,
	reply => Bivio::Agent::HTTP::Reply->new($r),
	r => $r,
	client_addr => $r->connection->remote_ip,
	is_secure => $ENV{HTTPS} || _is_https_port($r) ? 1 : 0,
    });
    Bivio::Type::UserAgent->from_header($r->header_in('user-agent') || '')
        ->put_on_request($self, 1);

    # Cookie parsed first, so log code works properly.
    # We must put the cookie now, because it may be used below.
    # auth_user (may) is set by cookie.
    $self->put_durable(cookie => Bivio::Agent::HTTP::Cookie->new($self, $r));
    my($auth_user) = $self->unsafe_get('auth_user');

    # Task next, because may not be found or task may want
    # to clear 'auth_user_id'.
    my($uri) = $r->uri;
    my($task_id, $auth_realm, $path_info);
    ($task_id, $auth_realm, $path_info, $uri)
	    = Bivio::UI::Task->parse_uri($uri, $self);

    # We have a Facade, so Request is "pretty much initialized".
    $self->internal_set_current();

    # Must re-escape the URI.
    $uri = Bivio::HTML->escape_uri($uri) if $uri;

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

    $self->put_durable(
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

=head2 client_redirect(hash_ref named)

See L<Bivio::Agent::Request::format_uri|Bivio::Agent::Request/"format_uri">

=head2 client_redirect(any uri, any query)

=head2 client_redirect(any task_id, any realm, any query, string path_info, boolean no_context)

Client side redirect to the new task within the new realm.  If I<new_task>
is the same as the current task, does an server_redirect.  Otherwise,
tells client to come back in.

B<DOES NOT RETURN.>

=cut

sub client_redirect {
    my($self, $named) =  shift->internal_get_named_args(
	ref($_[0]) && !(ref($_[0]) eq 'HASH' && $_[0]->{uri})
	    ? [qw(task_id realm query path_info no_context require_context)]
	    : [qw(uri query no_context)],
	\@_,
    );
    if (exists($named->{uri})) {
	# Can't check want_query here, because literal URI
	$named->{query} = Bivio::Agent::HTTP::Query->format($named->{query})
	    if ref($named->{query});
	$named->{uri} =~ s/\?/\?$named->{query}&/
	    || ($named->{uri} .= '?'.$named->{query})
	    if defined($named->{query}) && length($named->{query});
    }
    else {
	# use previous query if not specified, maintains state across pages
	if ($self->retain_query_and_path_info) {
	    $named->{query} = $self->get('query')
		unless exists($named->{query});
	    $named->{path_info} = $self->unsafe_get('path_info')
		unless exists($named->{path_info});
	}
	$self->SUPER::server_redirect($named)
	    unless Bivio::UI::Task->has_uri($named->{task_id}, $self);
        _trace(
	    'current: ', $self->get('task_id'), ', new: ', $named->{task_id}
	 ) if $_TRACE && !$named->{realm};
	$named->{uri} = $self->format_uri($named);
    }
    $self->get('reply')->client_redirect($self, $named->{uri});
    Bivio::Die->throw_quietly(Bivio::DieCode->CLIENT_REDIRECT_TASK);
    # DOES NOT RETURN
}

=for html <a name="client_redirect_if_not_secure"></a>

=head2 client_redirect_if_not_secure()

Causes the client to redirect back to this task in secure mode.
If already in secure mode or can't secure (!I<can_secure>),
returns (does nothing).

=cut

sub client_redirect_if_not_secure {
    my($self) = shift;
    return if $self->get('is_secure') || !$self->get('can_secure');
    $self->client_redirect({
	uri => $self->format_http_toggling_secure(@_),
    });
    # DOES NOT RETURN
}

=for html <a name="format_http_toggling_secure"></a>

=head2 format_http_toggling_secure() : string

Formats the uri for this request, but toggles secure mode.  This
is a very special and only used in one location.

=cut

sub format_http_toggling_secure {
    my($self, $host) = @_;
    my($is_secure, $r, $redirect_count, $uri, $query) = $self->get(
	    qw(is_secure r redirect_count uri query));
    $host ||= Bivio::UI::Facade->get_value('http_host', $self);

    # This is particularly strange.  FormModel deletes the incoming
    # query context.   If we haven't internally redirected, we use
    # the original query string so we get the format_context.  If
    # we redirected, don't bother with the form_context.
#TODO: This is screwed up.  Probably best to take the current
#      form's context and shove it on the URL.  Wouldn't hurt if not
#      really the form_model.
#      RJN 12/13/00 For require_secure, shouldn't grab form context,
#      because we don't even want to pretend to process it.
    $query = $redirect_count ? Bivio::Agent::HTTP::Query->format($query)
	    : $r->args;
    $uri =~ s/\?/\?$query&/ || ($uri .= '?'.$query) if $query;

    # Go into secure if not secure and vice-versa
    return ($is_secure ? 'http://' : 'https://').$host.$uri;
}

=for html <a name="get_content"></a>

=head2 get_content() : string_ref

Returns the content associated with request.  Throws INPUT_TOO_LARGE if the
input is larger than a reasonable size.

=cut

sub get_content {
    my($self) = @_;
    return $self->get_if_exists_else_put(content => sub {
        my($r) = $self->get('r');
	my($c) = '';
	my($l) = $r->header_in('content-length');
	_trace('Content-Length=', $l) if $_TRACE;
	return \$c
	    unless $l;
	$self->throw_die(INPUT_TOO_LARGE => "Content-Length too large: $l")
	    if $l > 120_000_000;
	$r->read($c, $l);
	$self->throw_die(CLIENT_ERROR =>
	    'client interrupt or timeout while reading form-data',
	) if $r->connection->aborted;
        $self->throw_die(CLIENT_ERROR =>
            'timeout occurred while reading request content'
	) unless defined($c);
	$self->throw_die(CORRUPT_QUERY =>
	    "Content-Length ($l) >= actual length: " . length($c)
	) if $l > length($c);
	_trace('length', length($c)) if $_TRACE;
	return \$c;
    });
}

=for html <a name="get_form"></a>

=head2 get_form() : hash_ref

Returns form associated the request or C<undef> if no form.
I<form_model> must be set.

=cut

sub get_form {
    my($self) = @_;
    return $self->get_if_exists_else_put(
	form => sub {Bivio::Agent::HTTP::Form->parse($self)},
    );
}

=for html <a name="reset_reply"></a>

=head2 reset_reply()

Clears the current reply and sets a new one on this request.

=cut

sub reset_reply {
    my($self) = @_;
    $self->put(reply => Bivio::Agent::HTTP::Reply->new($self->get('r')));
    return;
}

=for html <a name="server_redirect"></a>

=head2 server_redirect(string uri, any query, hash_ref form, string path_info)

=head2 server_redirect(...)

Server-side (aka internal) redirect to the new task within the new realm.

If I<uri> supplied, parses out the task_id, realm, and path_info
from the uri and then calls
L<Bivio::Agent::Request::server_redirect|Bivio::Agent::Request/"server_redirect">

B<DOES NOT RETURN.>

=cut

sub server_redirect {
    my($self) = shift;
    $self->SUPER::server_redirect(@_)
	if ref($_[0]);
    my(undef, $named) = $self->internal_get_named_args(
	[qw(uri query form path_info)],
	\@_,
    );
    @$named{qw(task_id realm path_info_from_uri)}
        = Bivio::UI::Task->parse_uri($named->{uri}, $self);
    $named->{path_info} = $named->{path_info_from_uri}
	unless exists($named->{path_info});
    grep(delete($named->{$_}), path_info_from_uri uri);
    $self->SUPER::server_redirect($named);
    # DOES NOT RETURN
}

#=PRIVATE METHODS

# _is_https_port(Apache r) : boolean
#
# Returns true if the local port is 81.  We are using this trick between
# the front-end and the middle tier to indicate it is running in secure
# mode.
#
sub _is_https_port {
    my($r) = @_;
    my($port) = unpack_sockaddr_in($r->connection->local_addr());
    return $port % 2 ? 1 : 0;
}

=head1 SEE ALSO

RFC2616 (HTTP/1.1), RFC1945 (HTTP/1.0), RFC1867 (multipart/form-data),
RFC2109 (Cookies), RFC1630 (URI), RFC1738 (URL), RFC2396 (new URI),
RFC1808 (Relative URL)

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
