# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::Reply;
use strict;
$Bivio::Agent::HTTP::Reply::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Agent::HTTP::Reply - a HTTP reply

=head1 EXTENDS

L<Bivio::Agent::Reply>

=cut

use Bivio::Agent::Reply;
@Bivio::Agent::HTTP::Reply::ISA = qw(Bivio::Agent::Reply);

=head1 DESCRIPTION

C<Bivio::Agent::HTTP::Reply> is the complement to
L<Bivio::Agent::HTTP::Request>. By default the
output type will be 'text/html'.

=cut

#=IMPORTS
use Apache::Constants ();
use Bivio::Agent::HTTP::Cookie;
use Bivio::Die;
use Bivio::IO::Alert;
use Bivio::DieCode;
use Bivio::IO::Trace;
use Carp ();
use UNIVERSAL;
# Avoid import
# use Bivio::Agent::Job::Dispatcher

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
# Can't initialize here, because get "deep recursion".  Don't ask me
# why...
my(%_DIE_TO_HTTP_CODE);

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Apache::Request r) : Bivio::Agent::HTTP::Reply

Creates a new Reply type which uses the specified Apache::Request for
output operations.

=cut

sub new {
    my($proto, $r) = @_;
    my($self) = &Bivio::Agent::Reply::new($proto);
    $self->{$_PACKAGE} = {
	'output' => '',
	'r' => $r,
    };
    # default output to html
    $self->set_output_type('text/html');
    return $self;
}

=head1 METHODS

=cut

=for html <a name="client_redirect"></a>

=head2 client_redirect(Bivio::Agent::Request req, string uri)

Redirects the client to the specified uri.

=cut

sub client_redirect {
    my($self, $req, $uri) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($r) = $fields->{r};

    # don't let any more data be sent
    $self->{$_PACKAGE} = undef;

    # have to do it the long way, there is a bug in using the REDIRECT
    # return value when handling a form
    $r->header_out(Location => $uri);
    $r->status(302);
    _send_http_header($req, $r);
    # make it look like apache's redirect
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

=for html <a name="send"></a>

=head2 send(Bivio::Agent::Request req)

Sends the buffered reply data.

=cut

sub send {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($r) = $fields->{r};
    my($o) = $fields->{output};

    my($is_scalar) = ref($o) eq 'SCALAR';
    die('no reply generated, missing UI item on Task')
	    unless $is_scalar || ref($o) eq 'GLOB';
    my($size) = $is_scalar ? length($$o) : -s $o;


    # only do this the first time
    $r->header_out('Content-Length', $size);
    $r->header_out('Connection', 'close');
    $r->content_type($self->get_output_type());
    _send_http_header($req, $r);
    if ($is_scalar) {
	$r->print($$o);
    }
    else {
	$r->send_fd($o, $size);
	close($o);
    }

    # don't let any more data be sent.  Don't clear early in case
    # there is an error and we get called back in die_to_http_code
    # (then _error()).
    $self->{$_PACKAGE} = undef
}

=for html <a name="die_to_http_code"></a>

=head2 static die_to_mail_reply_code(Bivio::Die die) : int

=head2 static die_to_http_code(Bivio::DieCode die, Apache::Request r) : int

Translates a L<Bivio::DieCode> to an L<Apache::Constant>.

If I<die> is C<undef>, returns C<Apache::Constants::OK>.

=cut

sub die_to_http_code {
    my(undef, $die, $r) = @_;

    return Apache::Constants::OK() unless defined($die);
    $die = $die->get('code') if UNIVERSAL::isa($die, 'Bivio::Die');
    return Apache::Constants::OK() unless defined($die);
    unless (%_DIE_TO_HTTP_CODE) {
	%_DIE_TO_HTTP_CODE = (
	    # Keep in synch with HTTP::Dispatcher
	    Bivio::DieCode::AUTH_REQUIRED()
		=> Apache::Constants::AUTH_REQUIRED(),
	    Bivio::DieCode::FORBIDDEN() => Apache::Constants::FORBIDDEN(),
	    Bivio::DieCode::NOT_FOUND() => Apache::Constants::NOT_FOUND(),
	    Bivio::DieCode::CLIENT_REDIRECT_TASK()
		=> Apache::Constants::OK(),
	);
    }
    return _error($_DIE_TO_HTTP_CODE{$die}, $r)
	    if defined($_DIE_TO_HTTP_CODE{$die});
    # The rest get mapped to SERVER_ERROR
    Bivio::IO::Alert->warn($die, ": unknown Bivio::DieCode")
		unless UNIVERSAL::isa($die, 'Bivio::DieCode');
    return _error(Apache::Constants::SERVER_ERROR(), $r);
}

=for html <a name="set_output"></a>

=head2 set_output(scalar_ref value)

=head2 set_output(io_handle file)

Sets the output to the file.  Output type must be set.
I<file> or I<value> will be owned by this method.

=cut

sub set_output {
    my($self, $value) = @_;
    my($fields) = $self->{$_PACKAGE};
    die('too many calls to set_output') if $fields->{output};
    die('not a GLOB or SCALAR reference')
	    unless ref($value) eq 'SCALAR' || ref($value) eq 'GLOB';
    $fields->{output} = $value;
    return;
}

#=PRIVATE METHODS

# _error(int code, Apache::Request r) : Apache::Constants::OK
#
# Workaround for apache in error mode.  Sends the reply in line.
# This is due to a bug in apache which uses a form.  See Req#21
#
sub _error {
    my($code, $r) = @_;
    return $code if $code == Apache::Constants::OK();
    $r->status($code);
    $r->content_type('text/html');
    _send_http_header(undef, $r);
    # make it look like apache's redirect
    my($uri) = $r->uri;
    if ($code == Apache::Constants::NOT_FOUND()) {
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
    elsif ($code == Apache::Constants::FORBIDDEN()) {
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
	$r->print(<<'EOF');
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<HTML><HEAD>
<TITLE>500 Internal Server Error</TITLE>
</HEAD><BODY>
<H1>Internal Server Error</H1>
The server encountered an internal error or
misconfiguration and was unable to complete
your request.<P>
Please contact the server administrator,
 webmaster@bivio.com and inform them of the time the error occurred,
and anything you might have done that may have
caused the error.<P>
More information about this error may be available
in the server error log.<P>
</BODY></HTML>
EOF
    }
    return Apache::Constants::OK();
}

# _send_http_header(Bivio::Agent::Request req, Apache r)
#
# Sends the header, turning off keep alive (if necessary) and set cookie
# (if req)
#
sub _send_http_header {
    my($req, $r) = @_;
    # We always set the cookie
    Bivio::Agent::HTTP::Cookie->set($req, $r) if $req;

    # Turn off KeepAlive if there are jobs.  This is because IE doesn't
    # cycle connections.  It goes back to exactly the same one.
    $r->header_out('Connection', 'close')
	    unless Bivio::Agent::Job::Dispatcher->queue_is_empty();

    $r->send_http_header;
    return;
}


=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
