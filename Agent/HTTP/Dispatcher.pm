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

C<Bivio::Agent::HTTP::Dispatcher> is an C<Apache> C<mod_perl>
handler.  It creates a single instance of itself on the first request.
For testing, a subclass can register itself as the singleton using the
method L<set_handler|"set_handler">.

=cut

#=IMPORTS
use Bivio::Ext::ApacheConstants;
use Bivio::Agent::Dispatcher;
use Bivio::Agent::HTTP::Reply;
use Bivio::Agent::HTTP::Request;
use Bivio::Agent::TaskId;
use Bivio::Die;
use Bivio::IO::Trace;
use Bivio::SQL::Connection;
use Bivio::Util;
# Required in initialize
# use Bivio::Agent::Job::Dispatcher

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_SELF);
my($_INITIALIZED);
__PACKAGE__->initialize;

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

Handler called by C<mod_perl>.

Returns an HTTP code defined in C<Bivio::Ext::ApacheConstants>.

=cut

sub handler {
    my($r) = @_;
    Apache->push_handlers('PerlCleanupHandler', sub {
	my($req) = Bivio::Agent::Request->get_current;
	if ($req) {
	    Bivio::IO::Alert->warn('[', $req->unsafe_get('client_addr'),
		    '] request aborted, rolling back ',
		    $req->unsafe_get('task_id'));
	    Bivio::Agent::Task->rollback;
	    Bivio::Agent::Request->clear_current;
	}
	return Bivio::Ext::ApacheConstants::OK();
    });
    my($die) = $_SELF->process_request($r);

    # Log the error
    if (defined($die) && $die->get('code')
	    # Keep in synch with Reply::die_to_http_code
	    ne Bivio::DieCode::CLIENT_REDIRECT_TASK()) {
	my($c) = $r->connection();
	my($u) = $c && $c->user() || 'ANONYMOUS';
	my($ip) = $c && $c->remote_ip || '0.0.0.0';
	$r->log_reason($ip.' '.$u.' '.$die->as_string)
    }

    Apache->push_handlers('PerlCleanupHandler', sub {
	Bivio::Agent::Job::Dispatcher->execute_queue();
	return Bivio::Ext::ApacheConstants::OK();
    }) unless Bivio::Agent::Job::Dispatcher->queue_is_empty();
    return Bivio::Agent::HTTP::Reply->die_to_http_code($die, $r);
}

=for html <a name="initialize"></a>

=head2 static initialize()

Creates C<$_SELF> and initializes config.

=cut

sub initialize {
    my($proto) = @_;
    $_INITIALIZED && return;
    $_INITIALIZED = 1;
    Bivio::IO::Config->initialize;
    $_SELF = $proto->new;
    $_SELF->SUPER::initialize();
    # Avoids import problems
    Bivio::Util::my_require('Bivio::Agent::Job::Dispatcher');
    # clear db time
    Bivio::SQL::Connection->get_db_time;
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
