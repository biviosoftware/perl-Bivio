# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::Dispatcher;
use strict;
$Bivio::Agent::HTTP::Dispatcher::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Agent::HTTP::Dispatcher::VERSION;

=head1 NAME

Bivio::Agent::HTTP::Dispatcher - dispatches Apache httpd requests

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS


    PerlModule Bivio::Agent::HTTP::Dispatcher
    <LocationMatch "^/(index.html|[*a-zA-Z0-9_-]{2,}($|/))">
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
handler.  It creates a single instance when this module is loaded.

=cut

#=IMPORTS
# dynamically imports Bivio::Agent::Job::Dispatcher
use Bivio::Agent::HTTP::Reply;
use Bivio::Agent::HTTP::Request;
use Bivio::Agent::Task;
use Bivio::DieCode;
use Bivio::Ext::ApacheConstants;
use Bivio::IO::Alert;
use Bivio::IO::ClassLoader;
use Bivio::IO::Trace;
use Bivio::SQL::Connection;
# May not be available on some systems
Bivio::Die->eval('
    use BSD::Resource;
    setrlimit(RLIMIT_CORE, 0, 0);
');

#=VARIABLES
# No core dumps please
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_SELF);
__PACKAGE__->initialize;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Agent::HTTP::Dispatcher

Creates a new dispatcher.

=cut

sub new {
    return shift->SUPER::new(@_);
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
	    Bivio::IO::Alert->warn(
		'[', $req->unsafe_get('client_addr'),
		'] request aborted, rolling back ',
		$req->unsafe_get('task_id'),
	    );
	    Bivio::Agent::Task->rollback($req);
	    Bivio::Agent::Request->clear_current;
	}
	return Bivio::Ext::ApacheConstants::OK();
    });
    my($die) = $_SELF->process_request($r);
    if ($die && !$die->get('code')->equals_by_name('CLIENT_REDIRECT_TASK')) {
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
    return if $_SELF;
    $_SELF = $proto->new;
    $_SELF->SUPER::initialize();
    # Avoids import problems
    Bivio::IO::ClassLoader->simple_require('Bivio::Agent::Job::Dispatcher');
    # clear db time
    Bivio::SQL::Connection->get_db_time;
    return;
}

#=PRIVATE METHODS

=head1 SEE ALSO

Apache::Request, mod_perl, Bivio::Agent::HTTP::Request,
Bivio::Agent::Controller

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
