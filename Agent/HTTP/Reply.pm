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
use Bivio::Die;
use Bivio::DieCode;
use Bivio::IO::Trace;
use Carp ();
use UNIVERSAL;

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
        'header_sent' => 0,
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

=head2 client_redirect(string uri)

Redirects the client to the specified uri.

=cut

sub client_redirect {
    my($self, $uri) = @_;
    my($fields) = $self->{$_PACKAGE};

    # don't let any more data be sent
    $fields->{output} = '';
    $fields->{header_sent} = 1;

    # have to do it the long way, there is a bug in using the REDIRECT
    # return value when handling a form
    my($r) = $fields->{r};
    $r->header_out(Location => $uri);
    $r->status(302);
    $r->send_http_header;
    # make it look like apache's redirect
    $r->print('<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<HTML><HEAD>
<TITLE>302 Found</TITLE>
</HEAD><BODY>
<H1>Found</H1>
The document has moved <A HREF="'.$uri.'">here</A>.<P>
</BODY></HTML>
');
    return;
}

=for html <a name="flush"></a>

=head2 flush()

Sends the buffered reply data.

=cut

sub flush {
    my($self,$str) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($size);
    if ($fields->{header_sent} == 0) {
	# only do this the first time
	$fields->{header_sent} = 1;
	$fields->{r}->header_out('Content-Length',
		$size = -s $fields->{file_handle}) if $fields->{file_handle};
	$fields->{r}->content_type($self->get_output_type());
	$fields->{r}->send_http_header;
    }
    if ($fields->{file_handle}) {
	$fields->{r}->send_fd($fields->{file_handle}, $size);
	close($fields->{file_handle});
	delete($fields->{file_handle});
    }
    else {
	$fields->{r}->print($fields->{output});
	$fields->{output} = '';
    }
}

=for html <a name="die_to_http_code"></a>

=head2 static die_to_mail_reply_code(Bivio::Die die) : int

=head2 static die_to_http_code(Bivio::DieCode die) : int

Translates a L<Bivio::DieCode> to an L<Apache::Constant>.

If I<die> is C<undef>, returns C<Apache::Constants::OK>.

=cut

sub die_to_http_code {
    my(undef, $die) = @_;

    return Apache::Constants::OK() unless defined($die);
    $die = $die->get('code') if UNIVERSAL::isa($die, 'Bivio::Die');
    return Apache::Constants::OK() unless defined($die);
    unless (%_DIE_TO_HTTP_CODE) {
	%_DIE_TO_HTTP_CODE = (
	    Bivio::DieCode::AUTH_REQUIRED()
		=> Apache::Constants::AUTH_REQUIRED(),
	    Bivio::DieCode::FORBIDDEN() => Apache::Constants::FORBIDDEN(),
	    Bivio::DieCode::NOT_FOUND() => Apache::Constants::NOT_FOUND(),
	    Bivio::DieCode::CLIENT_REDIRECT_TASK()
		=> Apache::Constants::OK(),
	);
    }
    return $_DIE_TO_HTTP_CODE{$die}
	    if defined($_DIE_TO_HTTP_CODE{$die});
    # The rest get mapped to SERVER_ERROR
    Carp::carp($die, ": unknown Bivio::DieCode")
		unless UNIVERSAL::isa($die, 'Bivio::DieCode');
    return Apache::Constants::SERVER_ERROR();
}

=for html <a name="print"></a>

=head2 print(string str, ...)

Writes the specified string to the request's output stream.

=cut

sub print {
    my($self) = shift;
    my($fields) = $self->{$_PACKAGE};
    die('set_output_from_file and print cannot both be called')
	    if $fields->{file_handle};
    $fields->{output} .= join('', @_);
    return;
}

=for html <a name="set_output_from_file"></a>

=head2 set_output_from_file(file handle)

Sets the output to the file.  Output type must be set.
The handle will be owned by this method.

=cut

sub set_output_from_file {
    my($self, $handle) = @_;
    my($fields) = $self->{$_PACKAGE};
    die('set_output_from_file and print cannot both be called')
	    if length($fields->{output});
    die('too many calls to set_output_from_file') if $fields->{file_handle};
    $fields->{file_handle} = $handle;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
