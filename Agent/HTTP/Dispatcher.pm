# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::Dispatcher;
use strict;
$Bivio::Agent::HTTP::Dispatcher::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Agent::HTTP::Dispatcher - dispatches Apache httpd requests

=head1 SYNOPSIS

    PerlModule Bivio::Agent::HTTP::Dispatcher
    <LocationMatch "^/\w{3,}($|/)">
    AuthName bivio
    AuthType Basic
    SetHandler perl-script
    PerlHandler Bivio::Agent::HTTP::Dispatcher
    </LocationMatch>

=cut

=head1 EXTENDS

L<Bivio::Agent::Dispatcher>

=cut

use Bivio::Agent::Dispatcher;
@Bivio::Agent::HTTP::Dispatcher::ISA = qw(Bivio::Agent::Dispatcher);

=head1 DESCRIPTION

C<Bivio::Agent::HTTP::Dispatcher> is an L<Apache> L<mod_perl|mod_perl>
handler.  It creates a single instance of itself on the first request.
For testing, a subclass can register itself as the singleton using the
method L<set_handler|"set_handler">.

=cut

#=IMPORTS
use Bivio::Util;
use Bivio::Agent::Dispatcher;
use Bivio::Agent::HTTP::Reply;
use Bivio::Agent::HTTP::Request;
use Bivio::Die;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_INITIALIZED);
my($_SELF);

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Agent::HTTP::Dispatcher

Creates a new dispatcher.

=cut

sub new {
    return &Bivio::Agent::Dispatcher::new(@_);
}

=head1 METHODS

=cut

=for html <a name="create_request"></a>

=head2 create_request(Apache::Request r) : Bivio::Agent::Request

Creates and returns the request.

=cut

sub create_request {
    my($self, $r) = @_;
    return Bivio::Agent::HTTP::Request->new($r);
}

=for html <a name="handler"></a>

=head2 static handler(Apache::Request r) : int

Handler called by L<mod_perl|mod_perl>.

Returns an HTTP code defined in L<Apache::Constants|Apache::Constants>.

=cut

sub handler {
    my($r) = @_;
    my($die);
    $die = Bivio::Die->catch(sub {__PACKAGE__->initialize})
	    unless $_INITIALIZED;
    $die = $_SELF->process_request($r)
	    unless $die;
    $r->log_reason($die->as_string) if defined($die);
    return Bivio::Agent::HTTP::Reply->die_to_http_code($die);
}

=for html <a name="initialize"></a>

=head2 static initialize()

Called on first request.

=cut

sub initialize {
    my($proto) = @_;
    $_INITIALIZED && return;
    Bivio::IO::Config->initialize;
    $_SELF = $proto->new;
    $_SELF->SUPER::initialize();
    $_INITIALIZED = 1;
    return;
}

=for html <a name="set_handler"></a>

=head2 static set_handler(Bivio::Agent::HTTP::Dispatcher dispatcher)

Overrides the default handler with the specified instance. This is useful
for testing small parts of the system.

A subclass for testing could look like this:

    package MyTestDispatcher;

    @MyTestDispatcher::ISA = qw(Bivio::Agent::HTTP::Dispatcher);

    my($_INITIALIZED) = 0;

    sub handler {
	my($r) = @_;

	if (! $_INITIALIZED) {
	    Bivio::Agent::HTTP::Dispatcher->set_handler(__PACKAGE__->new());
	    $_INITIALIZED = 1;
	}
	# handle the request in the base class (not -> notation)
	return Bivio::Agent::HTTP::Dispatcher::handler($r);
    }

Be sure that the subclass name is the entry in the httpd.conf so that it
can get the requests first.
    PerlModule MyDispatcher
    PerlHandler MyDispatcher

=cut

sub set_handler {
    my(undef, $dispatcher) = @_;
    $_SELF = $dispatcher;
    return;
}

#=PRIVATE METHODS

=head1 SEE ALSO

Apache::Request, mod_perl, Bivio::Agent::HTTP::Request,
Bivio::Agent::Controller

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
