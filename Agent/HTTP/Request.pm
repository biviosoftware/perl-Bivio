# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::Request;
use strict;
use Bivio::Base 'Agent.Request';
use Bivio::IO::Trace;
#TODO: Should be Socket ();  Fix unqualified symbols
use Socket;

# C<Bivio::Agent::HTTP::Request> is a Bivio Request wrapper for an
# Apache::Request. It gathers request information from the URI and posted
# parameters.
#
# A note about URI vs URL.  Basically, we use URI everywhere.  [RJN: I don't
# understand the distinction, but there is a distinction and RFC2616 uses
# URI for the most part, so we do, too.]

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
# needed for is_https_port()
our($_TRACE);
my($_C) = b_use('AgentHTTP.Cookie');
my($_D) = b_use('Bivio.Die');
my($_DC) = b_use('Bivio.DieCode');
my($_DT) = b_use('Type.DateTime');
my($_F) = b_use('AgentHTTP.Form');
my($_FCT) = b_use('FacadeComponent.Task');
my($_FM) = b_use('Biz.FormModel');
my($_H) = b_use('Bivio.HTML');
my($_R) = b_use('AgentHTTP.Reply');
my($_T) = b_use('Agent.Task');
my($_TI) = b_use('Agent.TaskId');
my($_READ_SIZE) = 4096;

sub client_redirect {
    my($self) = shift;
    if (my $named = $self->internal_client_redirect(@_)) {
	$self->SUPER::server_redirect($named);
	# DOES NOT RETURN
    }
    $_D->throw_quietly($_DC->CLIENT_REDIRECT_TASK);
    # DOES NOT RETURN
}

sub get_content {
    # (self) : string_ref
    # (self, IO::File) : IO::File
    # Returns the content associated with request.
    my($self, $fh) = @_;
    return $self->get_if_exists_else_put(content => sub {
        my($r) = $self->get('r');
	my($res) = '';
	my($expect) = $r->header_in('content-length');
	_trace('Content-Length=', $expect) if $_TRACE;
	return \$res
	    unless $expect && $expect > 0;
	my($read) = 0;
	while ($read < $expect) {
	    my($buf);
	    my($to_read) = $expect - $read;
	    $r->read($buf, $to_read < $_READ_SIZE ? $to_read : $_READ_SIZE);
	    $self->throw_die(CLIENT_ERROR =>
		'timeout occurred while reading request content'
	    ) unless defined($buf);
	    unless (length($buf)) {
		$self->warn('read returned zero length buffer, exitting loop');
		last;
	    }
	    $read += length($buf);
	    if ($fh) {
		$self->throw_die(IO_ERROR => {
		    message => 'write failed to file',
		    entity => "$!",
		}) unless $fh->print($buf);
	    }
	    else {
		$res .= $buf;
	    }
	}
	$self->throw_die(CLIENT_ERROR =>
	    'client interrupt or timeout while reading form-data',
	) if $r->connection->aborted;
	return $fh
	    if $fh;
	$self->throw_die(CLIENT_ERROR =>
	    "Content-Length ($expect) >= actual length: " . length($res)
	) unless $expect == length($res);
	_trace('length', length($res)) if $_TRACE;
	return \$res;
    });
}

sub get_form {
    # (self) : hash_ref
    # Returns form associated the request or C<undef> if no form.
    # I<form_model> must be set.
    my($self) = @_;
    return $self->get_if_exists_else_put(
	form => sub {$_F->parse($self)},
    );
}

sub internal_client_redirect {
    # NOTE: Use cient_redirect unless you know what you are doing
    my($self, $named) = shift->internal_client_redirect_args(@_);
    unless (defined($named->{uri})) {
	# use previous query if not specified, maintains state across pages
	$self->internal_copy_implicit($named);
	return $named
	    unless $_FCT->has_uri($named->{task_id}, $self);
        _trace(
	    'current: ', $self->get('task_id'), ', new: ', $named->{task_id}
	) if $_TRACE && !$named->{realm};
#TODO: Probably needs to be elsewhere
	foreach my $k (keys(%$named)) {
	    delete($named->{$k})
		unless grep($k eq $_, @{$self->FORMAT_URI_PARAMETERS});
	}
	$named->{uri} = $self->format_uri($named);
    }
    $self->get('reply')->client_redirect($self, $named->{uri});
    return;
}

sub new {
    # (proto, Apache.Request) : HTTP.Request
    # Creates a Request from an apache request.  The target and path are
    # separated.
    my($proto, $r) = @_;
    my($start_time) = $_DT->gettimeofday();
    # Set remote IP address if passed through by mod_proxy (RH6.2 and RH7.2)
    $r->connection->remote_ip($1)
	if ($r->header_in('x-forwarded-for') || $r->header_in('via') || '')
	    =~ /((?:\d+\.){3}\d+)/;
    # Sets Bivio::Agent::Request->get_current, so do the minimal thing
    my($self) = $proto->internal_new({
	start_time => $start_time,
	reply => $_R->new($r),
	r => $r,
	client_addr => $r->connection->remote_ip,
	is_secure => $ENV{HTTPS} || _is_https_port($proto, $r) ? 1 : 0,
    });
    Bivio::Type::UserAgent->from_header($r->header_in('user-agent') || '')
        ->put_on_request($self, 1);
    # Cookie parsed first, so log code works properly.
    # We must put the cookie now, because it may be used below.
    # auth_user (may) is set by cookie.
    $self->put_durable(cookie => $_C->new($self, $r));
    $self->put(referer => my $referer = $r->header_in('Referer'));
    $self->internal_initialize_with_uri(
	scalar($r->uri),
	scalar($r->args),
    );
    $self->delete_from_query($_FM->FORM_CONTEXT_QUERY_KEY)
	unless $referer;
    return $self;
}

sub put_client_redirect_state {
    my($self) = shift;
    if (my $named = $self->internal_client_redirect(@_)) {
	b_die($named, ': invalid redirect state');
    }
    return;
}

sub reset_reply {
    # (self) : undef
    # Clears the current reply and sets a new one on this request.
    my($self) = @_;
    $self->put(reply => $_R->new($self->get('r')));
    return;
}

sub _is_https_port {
    my($proto, $r) = @_;
    return $proto->want_scalar($proto->if_apache_version(
	2 => sub {$r->connection->local_addr->port},
	sub {unpack_sockaddr_in($r->connection->local_addr)},
    )) % 2;
}

1;
