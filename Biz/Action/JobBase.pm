# Copyright (c) 2002-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::JobBase;
use strict;
$Bivio::Biz::Action::JobBase::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Action::JobBase::VERSION;

=head1 NAME

Bivio::Biz::Action::JobBase - starts an action as a background job

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Action::JobBase;

=cut

=head1 EXTENDS

L<Bivio::Biz::Action>

=cut

use Bivio::Biz::Action;
@Bivio::Biz::Action::JobBase::ISA = ('Bivio::Biz::Action');

=head1 DESCRIPTION

C<Bivio::Biz::Action::JobBase> enqueues a
L<Bivio::Agent::Job::Dispatcher|Bivio::Agent::Job::Dispatcher>
request.   Subclasses defined L<internal_execute|"internal_execute">,
which does the work.

=cut

#=IMPORTS

#=VARIABLES
my($_SENTINEL) = __PACKAGE__ . '.internal_execute';

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req) : any

Creates a job which will call L<internal_execute|"internal_execute">.

=cut

sub execute {
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

=for html <a name="internal_execute"></a>

=head2 abstract internal_execute(Bivio::Agent::Request req) : any

Called when the task is running in background.

=cut

$_ = <<'}'; # emacs
sub internal_execute {
}

=for html <a name="set_sentinel"></a>

=head2 set_sentinel(Bivio::Agent::Request req)

Sets the sentinel used by L<execute|"execute"> to call
L<internal_execute|"internal_execute">.

=cut

sub set_sentinel {
    my(undef, $req) = @_;
    return $req->put($_SENTINEL => 1);
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2002-2006 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
