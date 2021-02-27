# Copyright (c) 1999-2014 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::Reply;
use strict;
use Bivio::Base 'Agent.Reply';
use APR::Status ();

b_use('IO.Trace');
our($_TRACE);
my($_AC) = b_use('Ext.ApacheConstants');
my($_DT) = b_use('Type.DateTime');
my($_DC) = b_use('Bivio.DieCode');
my($_D) = b_use('Bivio.Die');
my($_C) = b_use('IO.Config');
my(%_DIE_TO_HTTP_CODE);
$_C->register(my $_CFG = {
    additional_http_headers => undef,
});
my($_DOCTYPE_HEAD) = "<!DOCTYPE html>\n<html><head>";

sub client_redirect {
    my($self, $req, $named) = @_;
    my($r) = $self->get('r');
    $self->internal_put({});
    my($uri, $status) = @$named{qw(uri http_status_code)};
    $status ||= $_AC->HTTP_MOVED_TEMPORARILY;
    # have to do it the long way, there is a bug in using the REDIRECT
    # return value when handling a form
    $self->send_append_header($r, Location => $uri);
    _send_http_header($self, $req, $r, $status);
    # make it look like apache's redirect.  Ignore HEAD, because this
    # is like an error.
    $r->print(<<"EOF");
$_DOCTYPE_HEAD
<title>$status Found</title>
</head><body>
<h1>found</h1>
<p>The document has moved <a href="$uri">here</a>.</p>
</body></html>
EOF
    return;
}

sub die_to_http_code {
    # (proto, Bivio.Die) : int
    # (proto, Bivio.DieCode, Apache.Request) : int
    # Translates a L<$_DC> to an L<Apache::Constant>.
    #
    # If I<die> is C<undef>, returns C<$_AC::OK>.
    my($proto, $die, $r) = @_;
    return $_AC->OK
	unless defined($die);
    $die = $die->get('code')
	if $_D->is_blesser_of($die);
    return $_AC->OK
	unless defined($die);
    %_DIE_TO_HTTP_CODE = (
	# Keep in synch with HTTP::Dispatcher
	$_DC->FORBIDDEN => $_AC->FORBIDDEN,
	$_DC->NOT_FOUND => $_AC->NOT_FOUND,
	$_DC->MODEL_NOT_FOUND => $_AC->NOT_FOUND,
	$_DC->CLIENT_REDIRECT_TASK => $_AC->OK,
	$_DC->CORRUPT_QUERY => $_AC->BAD_REQUEST,
	$_DC->CORRUPT_FORM => $_AC->BAD_REQUEST,
	$_DC->INVALID_OP => $_AC->BAD_REQUEST,
	$_DC->INPUT_TOO_LARGE => $_AC->HTTP_REQUEST_ENTITY_TOO_LARGE,
	$_DC->CLIENT_ERROR => $_AC->HTTP_SERVICE_UNAVAILABLE,
    ) unless %_DIE_TO_HTTP_CODE;
    return _error($proto, $_DIE_TO_HTTP_CODE{$die}, $r)
	if defined($_DIE_TO_HTTP_CODE{$die});
    # The rest get mapped to SERVER_ERROR
    b_warn($die, ": unknown $_DC")
        unless $_DC->is_blesser_of($die);
    return _error($proto, $_AC->SERVER_ERROR, $r);
}

sub handle_config {
    # (proto, hash) : undef
    # additional_http_headers : array_ref []
    #
    # An array of [key => value] pairs to add to the http header for all
    # replies.
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub new {
    # (proto, Apache.Request) : HTTP.Reply
    # Creates a new Reply type which uses the specified Apache::Request for
    # output operations.
    return shift->SUPER::new->put(
	output_type => 'text/html',
	r => shift,
    );
}

sub send {
    # (self, Agent.Request) : undef
    # Sends the buffered reply data.
    my($self, $req) = @_;
    my($r, $o) = $self->unsafe_get(qw(r output));
    $r ||= $req->get('r');

    my($is_scalar) = ref($o) eq 'SCALAR';
    die('no reply generated, missing UI item on Task: ',
        $req->get('task_id')->get_name)
	unless $is_scalar || ref($o) eq 'GLOB' || UNIVERSAL::isa($o, 'IO::Handle');
    my($size) = $is_scalar ? length($$o) : -s $o;
    if ($is_scalar) {
	# Don't allow caching of dynamically generated replies, because
	# we don't know the contents (typically from the database)
	# This isn't *really* private, i.e. not setting Pragma: no-cache.
	# This pragma screws up Netscape on animated gifs.
	# Don't set it if someone else has already set Cache-Control
	$self->set_cache_private
	    unless $self->unsafe_get_header('Cache-Control');
    }
    else {
	$self->set_last_modified((stat($o))[9])
	    unless $self->unsafe_get_header('Last-Modified');
    }
    # Don't keep the connection open on normal replies
    $self->send_append_header($r, 'Connection', 'close');

    $self->send_append_header($r, 'Content-Length', $size);
    $r->content_type($self->get_output_type());
    _send_http_header($self, $req, $r, $self->get_or_default('status', $_AC->HTTP_OK));

    Bivio::Die->eval(sub {
	# M_HEAD not defined, so can't use method_number12
	if (uc($r->method) eq 'HEAD') {
	    # No body, just header
	}
	elsif ($is_scalar) {
	    $r->print($$o);
	    _trace($o) if $_TRACE;
	}
	else {
	    $r->send_fd($o, $size);
	    close($o);
	}
    });
    if ($@) {
	die $@
	    unless ref($@) eq 'APR::Error'
		&& APR::Status::is_ECONNABORTED($@);
    }
    # don't let any more data be sent.  Don't clear early in case
    # there is an error and we get called back in die_to_http_code
    # (then _error()).
    $self->internal_put({});
    return;
}

sub send_append_header {
    my(undef, $r, $key, $value) = @_;
    $r->headers_out->add($key, $value);
    return;
}

sub set_cache_max_age {
    my($self, $max_age, $req, $always_cache) = @_;
    unless ($always_cache) {
	return $self
	    unless b_use('UI.Facade')
		->get_from_source($req)->get('want_local_file_cache');
    }
    return $self
	->set_header('Cache-Control', "max-age=$max_age")
        ->set_header(Expires => $_DT->rfc822($_DT->add_seconds($_DT->now, $max_age)));
}

sub set_cache_private {
    # (self) : undef
    # Do not allow shared caching of this response.
    my($self) = @_;
    $self->set_header('Cache-Control', 'private');
    return $self;
}

sub set_expire_immediately {
    # (self) : undef
    # Set the page so it will expire immediately.
    my($self) = @_;
    $self->set_header(Expires => 'Tue, 01 Apr 1980 05:00:00 GMT');
    return $self;
}

sub set_last_modified {
    my($self, $value) = @_;
    return $self->set_header('Last-Modified', $_DT->rfc822($value));
}

sub set_output {
    # (self, scalar_ref) : self
    # (self, IO.File) : self
    # Sets the output to the file.  Output type must be set.
    # I<file> or I<value> will be owned by this method.
    my($self, $value) = @_;
    die('too many calls to set_output')
	if $self->has_keys('output');
    die('not an IO::Handle, GLOB, or SCALAR reference')
	unless ref($value) eq 'SCALAR' || ref($value) eq 'GLOB'
	    || UNIVERSAL::isa($value, 'IO::Handle');
    return shift->SUPER::set_output(@_);
}

sub _cookie_check {
    my($self, $req, $r) = @_;
    $self->set_cache_private
	if $req->get('cookie')->header_out($req, $r);
    return;
}

sub _error {
    # (int, Apache.Request) : ApacheConstants.OK
    # Workaround for apache in error mode.  Sends the reply in line.
    # This is due to a bug in apache which uses a form.  See Req#21
    my($proto, $status, $r) = @_;
#TODO: Older mod_perl versions had Apache::Constants bugs when not
#      running in apache.  If you're using 5.6.* or higher, you're
#      probably using a newer apache.  $^V was only defined after 5.005,
#      so this check is good enough.
    return $status
	if defined($^V)
	    || !exists($ENV{MOD_PERL})
	    || $status == $_AC->OK;
    $r->content_type('text/html');
    _send_http_header($proto, undef, $r, $status);
    # make it look like apache's redirect
    my($uri) = $r->uri;
    # Ignore HEAD.  There was an error, give the whole body
    if ($status == $_AC->NOT_FOUND) {
	$r->print(<<"EOF");
$_DOCTYPE_HEAD
<title>404 Not Found</title>
</head><body>
<h1>Not Found</h1>
<p>The requested URL $uri was not found on this server.</p>
</body></html>
EOF
    }
    elsif ($status == $_AC->FORBIDDEN) {
	$r->print(<<"EOF");
$_DOCTYPE_HEAD
<title>403 Forbidden</title>
</head><body>
<h1>Forbidden</h1>
<p>You don't have permission to access $uri
on this server.</p>
</body></html>
EOF
    }
    else {
	$r->print(<<"EOF");
$_DOCTYPE_HEAD
<title>500 Internal Server Error</title>
</head><body>
<h1>Internal Server Error</h1>
<p>The server encountered an internal error or
misconfiguration and was unable to complete
your request.</P>
<p>Please contact the server administrator,
webmaster\@@{[$r->server->server_hostname]}
and inform them of the time the error occurred,
and anything you might have done that may have
caused the error.</p>
</body></html>
EOF
    }
    # This is a workaround in older Apache versions
    return $_AC->OK;
}

sub _send_http_header {
    my($self, $req, $r, $status) = @_;
    $r->status($status);
    if (ref($self) && $req) {
	_cookie_check($self, $req, $r);
	my($h) = $self->unsafe_get('headers');
	if ($h) {
	    foreach my $k (sort(keys(%$h))) {
		$self->send_append_header($r, $k, $h->{$k});
	    }
	}
	_trace($self->unsafe_get('status'), ' ', $h) if $_TRACE;
    }
    # Turn off KeepAlive if there are jobs.  This is because IE doesn't
    # cycle connections.  It goes back to exactly the same one.
    $self->send_append_header($r, 'Connection', 'close')
	unless b_use('AgentJob.Dispatcher')->queue_is_empty;
    $r->send_http_header;
    return;
}

1;
