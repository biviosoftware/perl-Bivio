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
use Apache::Constants ();
use Bivio::Agent::Dispatcher;
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

=for html <a name="handler"></a>

=head2 static handler(Apache::Request r) : int

Handler called by L<mod_perl|mod_perl>, creates a
L<Bivio::Agent::HTTP::Request|Bivio::Agent::HTTP::Request>
which wraps L<Apache::Request|Apache::Request>.
Then it invokes the appropriate
L<Bivio::Agent::Controller|Bivio::Agent::Controller>
to handle the request.

Returns an HTTP code defined in L<Apache::Constants|Apache::Constants>.

=cut

sub handler {
    my($r) = @_;
    my($return_code);
    Bivio::Agent::Request->clear_current;
    my($res) = Bivio::Die->catch(sub {
	$_INITIALIZED || __PACKAGE__->initialize;
	my($request) = Bivio::Agent::HTTP::Request->new($r);
	$_SELF->process_request($request);
	my($reply) = $request->get('reply');
	if (defined($reply)) {
	    $return_code = $reply->get_http_return_code();
	    $reply->flush if $return_code == Apache::Constants::OK();
	}
	1;
    });
    unless (defined($return_code)) {
	$return_code = Apache::Constants::SERVER_ERROR();
	eval {
	    my($die) = Bivio::Die->get_last;
	    defined($die) && warn(@{$die->get_errors});
	    my($req) = Bivio::Agent::Request->get_current;
	    my($reply) = ref($req) && $req->unsafe_get('reply');
	    $return_code = ref($reply) ? $reply->get_http_return_code()
		    : Apache::Constants::SERVER_ERROR();
	    1;
	} || warn($@);
    }
    Bivio::Agent::Request->clear_current;
    Bivio::Die->clear_last;
    $r->log_error($return_code)
	    unless $return_code == Apache::Constants::OK();
    return $return_code;
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

    sub create_site {
	my($self) = @_;

	Bivio::IO::Config->initialize();
	#site creation here includeing controller registration
    }

    sub get_default_controller_name {
	my($self) = @_;

	# return the name of the default testing controller
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
