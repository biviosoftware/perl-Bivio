# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Action;
use strict;
$Bivio::Biz::Action::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Action - An abstract model action.

=cut

use Bivio::UNIVERSAL;
@Bivio::Biz::Action::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Biz::Action> describes a interaction which can be performed on
Models. Actions may be done, and undone. At any time it may not be possible
to (un)execute an action depending on the state of the model it relates
to. Actions can be queried as to whether they can be performed using the
L<"can_execute"> and L<"can_unexecute">.

Actions get the models they operate on via the L<Bivio::Biz::Request>
they are executed with.

During execution, the action either completes successfully or dies.  Actions
must be called via an L<Bivio::Die::catch|Bivio::Die/"catch"> to allow the
Action to catch exceptions and transform errors appropriately.

There may be more than one action executed when processing a
request.  A "main" action may call subordinate actions.


=cut

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 abstract execute(Bivio::Biz::Request req)

Call this method to perform the action on I<req>.  The form and
query associated with the request will be used to find the models
to act on.

=cut

sub execute {
    die("abstract method");
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
