# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
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

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req) : any

Creates a job which will call L<internal_execute|"internal_execute">.
payments in the background.

=cut

sub execute {
    my($self, $req) = @_;
    die($self, ': does not implement internal_execute')
	unless $self->can('internal_execute');
    my($flag) = ref($self) . '.internal_execute';
    return $self->internal_execute($req)
	if $req->unsafe_get($flag);
    Bivio::IO::ClassLoader->simple_require('Bivio::Agent::Job::Dispatcher');
    Bivio::Agent::Job::Dispatcher->enqueue(
	$req, $req->get('task_id'), {$flag => 1});
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

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
