# Copyright (c) 1999 bivio, LLC.  All Rights Reserved.
#
# $Id$
#
package Bivio::Request;

use strict;
use Carp ();
use Apache::Constants ();

$Bivio::Request::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

# execute $class $r $sub
# Creates a new request and saves a copy of "$r" in "r"
sub execute ($$$) {
    my($proto, $r, $code) = @_;
    my($self) = {
	'r' => $r,
    };
    bless($self, ref($proto) || $proto);
    eval { &$code($self); 1;} && return &Apache::Constants::OK;
    chop($@);
    if (defined($self->{result})) {
	$r->log_reason($@);
	return $self->{result};
    }
    # _terminate wasn't called; syntax or semantic error
    $r->log_reason("unexpected exception: $@");
    return &Apache::Constants::SERVER_ERROR;
}

# Returns the Apache "r" record associated with this request
sub r ($) {
    return shift->{r};
}

# Returns the club associated with this request
sub club ($) {
    return shift->{club};
}

# Sets the club associated with this request
sub set_club ($$) {
    $_[0]->{club} = $_[1];
}

# Returns the user associated with this request
sub user ($) {
    return shift->{user};
}

# Sets the user associated with this request
sub set_user ($$) {
    $_[0]->{user} = $_[1];
}

# Indicates that the user is only allowed to access read-only data
sub set_read_only ($$) {
    shift->{read_only} = 1;
}

# Terminates if there the request is read-only
sub assert_writable ($) {
    defined($_[0]->{read_only}) && $_[0]->forbidden("read-only access");
}

# send an auth_required code
sub auth_failure ($@) {
    my($self) = shift;
    $self->{r}->note_basic_auth_failure();
    $self->_terminate(&Apache::Constants::AUTH_REQUIRED, @_);
}

# Set a not found error code
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
