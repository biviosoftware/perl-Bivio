# Copyright (c) 2002-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::JobBase;
use strict;
use Bivio::Base 'Bivio::Biz::Action';

# C<Bivio::Biz::Action::JobBase> enqueues a
# L<Bivio::Agent::Job::Dispatcher|Bivio::Agent::Job::Dispatcher>
# request.   Subclasses defined L<internal_execute|"internal_execute">,
# which does the work.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_SENTINEL) = __PACKAGE__ . '.internal_execute';

sub execute {
    # (self, Agent.Request) : any
    # Creates a job which will call L<internal_execute|"internal_execute">.
    my($self, $req) = @_;
    die($self, ': does not implement internal_execute')
	unless $self->can('internal_execute');
    return $self->internal_execute($req)
	if $req->unsafe_get($_SENTINEL);
    Bivio::IO::ClassLoader->simple_require('Bivio::Agent::Job::Dispatcher');
    Bivio::Agent::Job::Dispatcher->enqueue(
	$req, $req->get('task_id'), {$_SENTINEL => 1});
    my($buffer) = '';
    $req->get('reply')->set_output(\$buffer);
    return 0;
}

sub set_sentinel {
    # (self, Agent.Request) : undef
    # Sets the sentinel used by L<execute|"execute"> to call
    # L<internal_execute|"internal_execute">.
    my(undef, $req) = @_;
    return $req->put($_SENTINEL => 1);
}

1;
