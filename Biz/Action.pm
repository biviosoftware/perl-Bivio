# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Action;
use strict;
$Bivio::Biz::Action::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Action - An abstract model action.

=cut

use Bivio::UNIVERSAL;
@Bivio::Biz::Action::ISA = ('Bivio::UNIVERSAL');

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
my(%_CLASS_TO_SINGLETON);

=head1 FACTORIES

=cut

=for html <a name="get_instance"></a>

=head2 static get_instance() : Bivio::Biz::Action

=head2 static get_instance(string class) : Bivio::Biz::Action

Returns the singleton for I<class> or I<proto>.

=cut

sub get_instance {
    my($proto, $class) = @_;
    if (defined($class)) {
	$class = ref($class) if ref($class);
	$class = 'Bivio::Biz::Action::'.$class unless $class =~ /::/;
	# First time, make sure the class is loaded.
	Bivio::IO::ClassLoader->simple_require($class)
		    unless $_CLASS_TO_SINGLETON{$class};
    }
    else {
	$class = ref($proto) || $proto;
    }
    $_CLASS_TO_SINGLETON{$class} = $class->new
	    unless $_CLASS_TO_SINGLETON{$class};
    return $_CLASS_TO_SINGLETON{$class};
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 abstract execute(Bivio::Biz::Request req) : boolean

=head2 static execute(Bivio::Biz::Request req, string class) : boolean

Call this method to perform the action on I<req>.  The form and
query associated with the request will be used to find the models
to act on.

If I<class> is supplied, will be loaded first.

=cut

sub execute {
    my($proto, $req, $class) = @_;
    die("abstract method") unless $class;
    return $proto->get_instance($class)->execute($req);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
