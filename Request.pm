# Copyright (c) 1999 bivio, LLC.  All Rights Reserved.
#
# $Id$
#
package Bivio::Request;

use strict;
use Carp ();
use Apache::Constants ();
use Bivio::Util;
use Bivio::Data;
use Bivio::Mail;

$Bivio::Request::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

unless (defined($ENV{MOD_PERL})) {
    # This is necessary to avoid a weird recursion with AUTOLOAD of
    # Apache::Constants when not started from MOD_PERL (e.g. from MHonArc)
    eval 'use Apache::FakeRequest ()';
}

BEGIN {
    use Bivio::Util;
    &Bivio::Util::compile_attribute_accessors(
    	[qw(club user path_info reply_sent)]);
    defined($ENV{BIVIO_REQUEST_DEBUG}) && ($SIG{__DIE__} = \&Carp::confess);
}

# execute $class $r $sub
# Creates a new request and saves a copy of "$r" in "r"
sub process_http ($$$) {
    my($proto, $r, $code) = @_;
    my($self) = {
	'start_time' => &Bivio::Util::gettimeofday,
	'r' => $r,
    };
    &_process($proto, $self, $code) && return &Apache::Constants::OK;
    $r->log_reason($self->{error});
    return $self->{result};
}

# execute $class $document_root $header $sub
#
#   Creates a new request and saves a copy of $document_root and the message
#   $header in $self.
sub process_email ($$$) {
    my($proto, $document_root, $header, $code) = @_;
    my($self) = {
	'start_time' => &Bivio::Util::gettimeofday,
	'document_root' => $document_root,
	'header' => $header,
    };
    &_process($proto, $self, $code) && return &Apache::Constants::OK;
    my($caller) = (caller)[0] eq 'main' ? (caller)[1] : (caller)[0];
    my($attach) = defined($header)
	    ? [{'value_type' => 'text', 'value' => $header}] : undef;
    &Bivio::Mail::send(
	    undef, 'postmaster', "ERROR: $caller", <<"EOF", undef, $attach);
Error while processing email message via Bivio::Request::process_mail:

    $self->{error}

Apache result code: $self->{result}
EOF
    return $self->{result};
}

# _process $proto $self $code -> success
#
#   Blesses $self with $proto and evals $code.  Incomplete transactions are
#   aborted.  Queued messages are sent only on success.
sub _process ($$$) {
    my($proto, $self, $code) = @_;
    defined($proto) && bless($self, ref($proto) || $proto);
    my($ok) = eval { &$code($self); 1;};
    unless ($ok) {
	chop($@);
	$self->{error} = $@;
	unless (defined($self->{result})) {
	    $self->{error} = 'unexpected exception: ' . $self->{error};
	    $self->{result} = &Apache::Constants::SERVER_ERROR;
	}
    }
    my(@aborted) = &Bivio::Data::check_txn($self);
    # Shouldn't be any aborted transactions if $ok
    if (@aborted && $ok) {
	$self->{error} = "transactions incomplete on termination: @aborted";
	$self->{result} = &Apache::Constants::SERVER_ERROR;
	$ok = 0;
    }
    $ok && &Bivio::Mail::send_queued_messages();
    return $ok;
}

# Returns the Apache "r" record associated with this request
sub r ($) {
    return shift->{r};
}

# Indicates that the user is only allowed to access read-only data
sub make_read_only ($$) {
    shift->{read_only} = 1;
}

# Terminates if there the request is read-only
sub assert_writable ($) {
    defined($_[0]->{read_only}) && $_[0]->forbidden("read-only access");
}

# Returns true if user can't modify data associated with request
sub is_read_only ($) {
    defined($_[0]->{read_only});
}

# send an auth_required code
sub auth_failure ($@) {
    my($self) = shift;
    $self->{r}->note_basic_auth_failure();
    $self->_terminate(&Apache::Constants::AUTH_REQUIRED, @_);
}

# Redirect
sub redirect ($$) {
    my($self, $redirect) = @_;
    $self->r->err_header_out('Location', $redirect);
    $self->_terminate(&Apache::Constants::REDIRECT, 'redirect: ', $redirect);
}

# Set a not found error code
sub not_found ($@) {
    shift->_terminate(&Apache::Constants::NOT_FOUND, @_);
}

# Set a forbidden error code
sub forbidden ($@) {
    shift->_terminate(&Apache::Constants::FORBIDDEN, @_);
}

# Terminate the request with a server error
sub server_error ($@) {
    shift->_terminate(&Apache::Constants::SERVER_ERROR, @_);
}

# Terminate the request with a server busy
sub server_busy ($@) {
    shift->_terminate(&Apache::Constants::HTTP_SERVICE_UNAVAILABLE, @_);
}

# Terminate the request with a bad request
sub bad_request ($@) {
    shift->_terminate(&Apache::Constants::BAD_REQUEST, @_);
}

# Terminate an incoming request with a particular Apache::Constants result
sub _terminate ($$@) {
    my($self) = shift;
    $self->{result} = shift;
    my ($pack,$file,$line, $i);
    while (($pack, $file, $line) = caller($i++)) {
	$pack ne 'Bivio::Request' && last;
    }
    die($pack, '(', $line, '): ',
	defined($self->{club})
	? ($self->{club}->{name} . '/' . $self->{user}->{name} . ': ')
	: defined($self->{user})
	? ($self->{user}->{name}. ': ')
	: '',
	@_, "\n");				     	 # \n avoids perl noise
}

sub document_root {
    my($self) = shift;
    defined($self->{r}) && return $self->r->document_root;
    defined($self->{document_root}) && return $self->{document_root};
    $self->server_error("unable to determine document root");
}

# elapsed_time $self -> $seconds
#   Time since request was initiated (in seconds)
sub elapsed_time ($) {
    return &Bivio::Util::time_delta_in_seconds(shift->{start_time});
}

sub fields_posted ($) {
    my($self) = shift;
    my($ct) = $self->r->header_in("Content-type");
    $ct eq 'application/x-www-form-urlencoded'
	|| $self->bad_request("invalid content type: \"$ct\"");
    return {$self->r->content};
}

# canonicalize_uri $self $abs_uri -> $canonical_uri
#
#   Makes the $abs_uri canonical wrt the server which is serving $self.
#   $abs_uri must begin with a '/'.
sub canonicalize_uri ($$) {
    my($self, $uri) = @_;
    return $self->_root_uri . $uri;
}

# _root_uri $self -> "http://server[:port]"
#
#   Returns the way this server can be accessed via http.
sub _root_uri ($) {
    my($self) = @_;
#RJN: Can this be cached?  Do we care?
    my($s) = $self->r->server;
    return 'http://' . $s->server_hostname
	. ($s->port == 80 ? '' : (':' . $s->port));
}

1;
__END__

=head1 NAME

Bivio::Request - Place holder for incoming request

=head1 SYNOPSIS

  use Bivio::Request;

=head1 DESCRIPTION

=head1 AUTHOR

Rob Nagler <nagler@bivio.com>

=head1 SEE ALSO

Bivio::Club

=cut
