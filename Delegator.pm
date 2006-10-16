# Copyright (c) 2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Delegator;
use strict;
$Bivio::Delegator::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Delegator::VERSION;

=head1 NAME

Bivio::Delegator - delegates implementation to another class

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Delegator;

=cut

use Bivio::UNIVERSAL;
@Bivio::Delegator::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Delegator> delegates implementation to another class. Subclasses
must have an entry in ClassLoader.delegates.

=cut

#=IMPORTS
use Bivio::IO::ClassLoader;

#=VARIABLES
use vars ('$AUTOLOAD');
my($_IDI) = __PACKAGE__->instance_data_index;
my($_MAP) = {};

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(...) : Bivio::Delegator

Creates a new instance of the delegator and the delegate.

=cut

sub new {
    my($proto, @args) = @_;
    my($self) = $proto->SUPER::new($proto);
    $self->[$_IDI] = {
	delegate => _map(ref($self))->new(@args),
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="AUTOLOAD"></a>

=head2 AUTOLOAD()

Handles method calls by invoking the delegate. This is only called if the
subclass doesn't implement the method.

=cut

sub AUTOLOAD {
    my($proto) = shift;
    my($method) = $AUTOLOAD =~ /([^:]+)$/;
    return if $method eq 'DESTROY';
    return (ref($proto) ? $proto->[$_IDI]->{delegate} : _map($proto))
	->$method(@_);
}

#=PRIVATE METHODS

# _map(proto) : string
#
# Returns the delegate class for the current class/instance.
#
sub _map {
    my($proto) = @_;
    return $_MAP->{$proto}
	||= Bivio::IO::ClassLoader->delegate_require($proto);
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
