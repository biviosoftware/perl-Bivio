# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Action;
use strict;
$Bivio::Biz::Action::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Action::VERSION;

=head1 NAME

Bivio::Biz::Action - An abstract model action.

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Action;

=cut

=head1 EXTENDS

L<Bivio::Collection::Attributes>

=cut

use Bivio::Collection::Attributes;
@Bivio::Biz::Action::ISA = ('Bivio::Collection::Attributes');

=head1 DESCRIPTION

C<Bivio::Biz::Action> defines the interface for "pure" business logic,
i.e. not directly associated with any one model.  Actions usually
appear as executable items of L<Bivio::Agent::Task|Bivio::Agent::Task>,
but they may be called directly.

=cut

#=VARIABLES
my(%_CLASS_TO_SINGLETON);

=head1 FACTORIES

=cut

=for html <a name="get_instance"></a>

=head2 static get_instance() : Bivio::Biz::Action

=head2 static get_instance(string class) : Bivio::Biz::Action

Returns the singleton for I<class> or I<proto>.  If I<class> is supplied, it
may be just the simple name or a fully qualified class name.  It will be loaded
with L<Bivio::IO::ClassLoader|Bivio::IO::ClassLoader> using the I<Action> map.

Otherwise, a singleton for the Action will be returned.  If the
action's class has yet to be instantiated, it will be and stored
internally in a singleton cache.

Always returns the same instance (never a class name) for
the specified Action.

=cut

sub get_instance {
    my($proto, $class) = @_;
    if (defined($class)) {
	$class = Bivio::IO::ClassLoader->map_require('Action',
		ref($class) ? ref($class) : $class);
    }
    else {
	$class = ref($proto) ? ref($proto) : $proto;
    }

    $_CLASS_TO_SINGLETON{$class} = $class->new->set_read_only
	    unless $_CLASS_TO_SINGLETON{$class};
    return $_CLASS_TO_SINGLETON{$class};
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 abstract execute(Bivio::Agent::Request req) : any

Perform an action on I<req>.  Usually modifies state of I<req>.

B<Subclasses must override this method>.

=head2 static execute(Bivio::Agent::Request req, string class) : any

If I<class> is supplied, will be loaded with
L<get_instance|"get_instance"> and that instance's execute
method will be called without a I<class> argument.

Returns true if execution should stop.  Returns a
L<Bivio::Agent::TaskId|Bivio::Agent::TaskId> to transition
to a specific task.

=cut

sub execute {
    my($proto, $req, $class) = @_;
    die("abstract method") unless $class;
    return $proto->get_instance($class)->execute($req);
}

=for html <a name="put_on_request"></a>

=head2 put_on_request(Bivio::Agent::Request req) : self

Puts self on request.  May not be called with
L<get_instance|"get_instance">.

=cut

sub put_on_request {
    my($self, $req) = @_;
    Bivio::Die->die($self, ': must be instance')
	unless ref($self);
    Bivio::Die->die($self, ': may not put singleton on request')
	if $self->get_instance == $self;
    foreach my $key ('Action.' . $self->simple_package_name, ref($self)) {
	$req->put($key => $self);
    }
    return $self;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
