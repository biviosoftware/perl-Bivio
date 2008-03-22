# Copyright (c) 1999-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::Reply;
use strict;
use Bivio::Base 'Bivio::Agent::Reply';
use Bivio::Die;
use Bivio::DieCode;
use Bivio::Ext::ApacheConstants;
use Bivio::IO::Config;
use Bivio::IO::Trace;
use Bivio::Type::DateTime;
use UNIVERSAL;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
# Can't initialize here, because get "deep recursion".  Don't ask me
# why...
my(%_DIE_TO_HTTP_CODE);
my($_CFG);
Bivio::IO::Config->register({
    additional_http_headers => undef,
});

sub client_redirect {
    # (self, Agent.Request, string) : undef
    # Redirects the client to the specified uri.
    my($self, $req, $uri) = @_;
    my($r) = $self->get('r');
    $self->internal_put({});

    # have to do it the long way, there is a bug in using the REDIRECT
    # return value when handling a form
    $r->header_out(Location => $uri);
    $r->status(302);
    _send_http_header($self, $req, $r);
    # make it look like apache's redirect.  Ignore HEAD, because this
    # is like an error.
    $r->print(<<"EOF");
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<HTML><HEAD>
<TITLE>302 Found</TITLE>
</HEAD><BODY>
<H1>Found</H1>
The document has moved <A HREF="$uri">here</A>.<P>
</BODY></HTML>
EOF
    return;
}

sub delete_output {
    # (self) : scalar_ref
    # Delete and return output.
    my($self) = @_;
    my($output) = $self->unsafe_get('output');
    $self->delete('output');
    return $output;
}

sub die_to_http_code {
    # (proto, Bivio.Die) : int
    # (proto, Bivio.DieCode, Apache.Request) : int
    # Translates a L<Bivio::DieCode> to an L<Apache::Constant>.
    #
    # If I<die> is C<undef>, returns C<Bivio::Ext::ApacheConstants::OK>.
    my(undef, $die, $r) = @_;
    return Bivio::Ext::ApacheConstants->OK
	unless defined($die);
    $die = $die->get('code')
	if UNIVERSAL::isa($die, 'Bivio::Die');
    return Bivio::Ext::ApacheConstants->OK
	unless defined($die);
    %_DIE_TO_HTTP_CODE = (
	# Keep in synch with HTTP::Dispatcher
	Bivio::DieCode->FORBIDDEN
	    => Bivio::Ext::ApacheConstants->FORBIDDEN,
	Bivio::DieCode->NOT_FOUND
	    => Bivio::Ext::ApacheConstants->NOT_FOUND,
	Bivio::DieCode->MODEL_NOT_FOUND
	    => Bivio::Ext::ApacheConstants->NOT_FOUND,
	Bivio::DieCode->CLIENT_REDIRECT_TASK
	    => Bivio::Ext::ApacheConstants->OK,
	Bivio::DieCode->CORRUPT_QUERY
	    => Bivio::Ext::ApacheConstants->BAD_REQUEST,
	Bivio::DieCode->CORRUPT_FORM
	    => Bivio::Ext::ApacheConstants->BAD_REQUEST,
	Bivio::DieCode->INVALID_OP
	    => Bivio::Ext::ApacheConstants->BAD_REQUEST,
	Bivio::DieCode->INPUT_TOO_LARGE
	    => Bivio::Ext::ApacheConstants->HTTP_REQUEST_ENTITY_TOO_LARGE,
    ) unless %_DIE_TO_HTTP_CODE;
    return _error($_DIE_TO_HTTP_CODE{$die}, $r)
	if defined($_DIE_TO_HTTP_CODE{$die});
    # The rest get mapped to SERVER_ERROR
    Bivio::IO::Alert->warn($die, ": unknown Bivio::DieCode")
	    unless UNIVERSAL::isa($die, 'Bivio::DieCode');
    return _error(Bivio::Ext::ApacheConstants::SERVER_ERROR(), $r);
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

    my($is_scalar) = ref($o) eq 'SCALAR';
    die('no reply generated, missing UI item on Task')
	unless $is_scalar || ref($o) eq 'GLOB' || UNIVERSAL::isa($o, 'IO::Handle');
    my($size) = $is_scalar ? length($$o) : -s $o;
    # NOTE: The -s $o and the "stat(_)" below must be near each other
    if ($is_scalar) {
	# Don't allow caching of dynamically generated replies, because
	# we don't know the contents (typically from the database)
	# This isn't *really* private, i.e. not setting Pragma: no-cache.
	# This pragma screws up Netscape on animated gifs.
	$self->set_cache_private;
    }
    else {
	# Files read from disk are never private
	$self->set_last_modified((stat(_))[9])
	    unless $self->get_if_exists_else_put('headers', {})->{'Last-Modified'};
    }

    # Don't keep the connection open on normal replies
    $r->header_out('Connection', 'close');

    $r->header_out('Content-Length', $size);
    $r->content_type($self->get_output_type());
    _send_http_header($self, $req, $r);

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

    # don't let any more data be sent.  Don't clear early in case
    # there is an error and we get called back in die_to_http_code
    # (then _error()).
    $self->internal_put({});
    return;
}

sub set_cache_private {
    # (self) : undef
    # Do not allow shared caching of this response.
    my($self) = @_;
    $self->set_header('Cache-Control', 'private');
    return;
}

sub set_expire_immediately {
    # (self) : undef
    # Set the page so it will expire immediately.
    my($self) = @_;
    $self->set_header(Expires => 'Tue, 01 Apr 1980 05:00:00 GMT');
    return;
}

sub set_http_status {
    # (self, int) : self
    # Sets the HTTP return code.  Use C<Bivio::Ext::ApacheConstants> values, e.g.
    # C<NOT_FOUND>, C<HTTP_SERVICE_UNAVAILABLE>.
    my($self, $status) = @_;
    # It is error prone keeping a list up to date, so we just check
    # a reasonable range.
    Bivio::Die->die($status, ': unknown HTTP status')
        unless defined($status) && $status =~ /^\d+$/
	&& 100 <= $status && $status < 600;
    $self->put(status => $status);
    return $self;
}

sub set_last_modified {
    # (self, string) : undef
    # (self, int) : undef
    # Sets the last modified header.
    shift->set_header('Last-Modified', Bivio::Type::DateTime->rfc822(shift));
    return;
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

sub unsafe_get_output {
    # (self) : ref
    # Returns the current output value.
    return shift->unsafe_get('output');
}

sub _add_additional_http_headers {
    # (self, Apache.Request) : undef
    # Adds any additional http headers from the configuration.
    my($self, $r) = @_;
    return unless $_CFG->{additional_http_headers};

    foreach my $pair (@{$_CFG->{additional_http_headers}}) {
        my($key, $value) = @$pair;
        $r->header_out($key => defined($r->header_out($key))
            ? $r->header_out($key) . "\r\n$key: $value"
            : $value);
    }
    return;
}

sub _error {
    # (int, Apache.Request) : ApacheConstants.OK
    # Workaround for apache in error mode.  Sends the reply in line.
    # This is due to a bug in apache which uses a form.  See Req#21
    my($code, $r) = @_;
#TODO: Older mod_perl versions had Apache::Constants bugs when not
#      running in apache.  If you're using 5.6.* or higher, you're
#      probably using a newer apache.  $^V was only defined after 5.005,
#      so this check is good enough.
    return $code
	if defined($^V)
	    || !exists($ENV{MOD_PERL})
	    || $code == Bivio::Ext::ApacheConstants->OK;
    $r->status($code);
    $r->content_type('text/html');
    _send_http_header(undef, undef, $r);
    # make it look like apache's redirect
    my($uri) = $r->uri;

    # Ignore HEAD.  There was an error, give the whole body
    if ($code == Bivio::Ext::ApacheConstants->NOT_FOUND) {
	$r->print(<<"EOF");
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<HTML><HEAD>
<TITLE>404 Not Found</TITLE>
</HEAD><BODY>
<H1>Not Found</H1>
The requested URL $uri was not found on this server.<P>
</BODY></HTML>
EOF
    }
    elsif ($code == Bivio::Ext::ApacheConstants->FORBIDDEN) {
	$r->print(<<"EOF");
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<HTML><HEAD>
<TITLE>403 Forbidden</TITLE>
</HEAD><BODY>
<H1>Forbidden</H1>
You don't have permission to access $uri
on this server.<P>
</BODY></HTML>
EOF
    }
    else {
	$r->print(<<"EOF");
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<HTML><HEAD>
<TITLE>500 Internal Server Error</TITLE>
</HEAD><BODY>
<H1>Internal Server Error</H1>
The server encountered an internal error or
misconfiguration and was unable to complete
your request.<P>
Please contact the server administrator,
webmaster\@@{[$r->server->server_hostname]}
and inform them of the time the error occurred,
and anything you might have done that may have
caused the error.<P>
</BODY></HTML>
EOF
    }
    # This is a workaround in older Apache versions
    return Bivio::Ext::ApacheConstants->OK;
}

sub _send_http_header {
    # (HTTP.Reply, Agent.Request, Apache) : undef
    # Sends the header, turning off keep alive (if necessary) and set cookie
    # (if req)
    my($self, $req, $r) = @_;
    if ($req) {
	$r->status($self->get('status'))
	    if $self->has_keys('status');
	$self->set_cache_private
	    if $req->get('cookie')->header_out($req, $r);
        _add_additional_http_headers($self, $r);
	my($h) = $self->unsafe_get('headers');
	if ($h) {
	    foreach my $k (sort(keys(%$h))) {
		$r->header_out($k, $h->{$k});
	    }
	}
	_trace($self->unsafe_get('status'), ' ', $h) if $_TRACE;
    }

    # Turn off KeepAlive if there are jobs.  This is because IE doesn't
    # cycle connections.  It goes back to exactly the same one.
    $r->header_out('Connection', 'close')
	unless Bivio::Agent::Job::Dispatcher->queue_is_empty();

    $r->send_http_header;
    return;
}

1;
