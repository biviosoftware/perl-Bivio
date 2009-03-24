# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::Dispatcher;
use strict;
use Bivio::Base 'Agent.Dispatcher';
use Bivio::IO::Trace;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_JD);
my($_SELF);
my($_C) = b_use('SQL.Connection');
my($_OK) = b_use('Ext.ApacheConstants')->OK;
my($_REPLY) = b_use('AgentHTTP.Reply');
my($_REQUEST) = b_use('AgentHTTP.Request');
my($_T) = b_use('Agent.Task');
Bivio::Die->eval(q{
    use BSD::Resource;
    setrlimit(RLIMIT_CORE, 0, 0);
});
Bivio::IO::Trace->register;
__PACKAGE__->initialize;

sub create_request {
    my($self, $r) = @_;
    return $_REQUEST->new($r);
}

sub handler {
    my($r) = @_;
    Apache->push_handlers('PerlCleanupHandler', sub {
	my($req) = $_REQUEST->get_current;
	if ($req) {
	    b_warn(
		'[', $req->unsafe_get('client_addr'),
		'] request aborted, rolling back ',
		$req->unsafe_get('task_id'),
	    );
	    $_T->rollback($req);
	    $_REQUEST->clear_current;
	}
	return $_OK;
    });
    my($die) = $_SELF->process_request($r);
    if ($die && !$die->get('code')->equals_by_name('CLIENT_REDIRECT_TASK')) {
	my($c) = $r->connection();
	my($u) = $c && $c->user() || 'ANONYMOUS';
	my($ip) = $c && $c->remote_ip || '0.0.0.0';
	$r->log_reason($ip.' '.$u.' '.$die->as_string)
    }
    Apache->push_handlers('PerlCleanupHandler', sub {
	$_JD->execute_queue;
	return $_OK;
    }) unless $_JD->queue_is_empty;
    return $_REPLY->die_to_http_code($die, $r);
}

sub initialize {
    my($proto) = @_;
    return
	if $_SELF;
    $_SELF = $proto->new;
    $_SELF->SUPER::initialize;
    # Avoids import problems
    use attributes ();
    $_REQUEST->if_apache_version(2, sub {
	b_use('APR::SockAddr');
	Bivio::Die->eval(q{use attributes __PACKAGE__, \&handler, 'handler'});
	return;
    });
    $_JD = b_use('AgentJob.Dispatcher');
    $_C->get_db_time;
    return;
}

1;
