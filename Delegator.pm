# Copyright (c) 2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Delegator;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';
use Bivio::IO::ClassLoader;

# C<Bivio::Delegator> delegates implementation to another class. Subclasses
# must have an entry in ClassLoader.delegates.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($AUTOLOAD);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_MAP) = {};

sub AUTOLOAD {
    # (self) : undef
    # Handles method calls by invoking the delegate. This is only called if the
    # subclass doesn't implement the method.
    my($proto) = shift;
    my($method) = $AUTOLOAD =~ /([^:]+)$/;
    return if $method eq 'DESTROY';
    return (ref($proto) ? $proto->[$_IDI]->{delegate} : _map($proto))
	->$method(@_);
}

sub new {
    # (proto, ...) : Bivio.Delegator
    # Creates a new instance of the delegator and the delegate.
    my($proto, @args) = @_;
    my($self) = $proto->SUPER::new($proto);
    $self->[$_IDI] = {
	delegate => _map(ref($self))->new(@args),
    };
    return $self;
}

sub _map {
    # (proto) : string
    # Returns the delegate class for the current class/instance.
    my($proto) = @_;
    return $_MAP->{$proto}
	||= Bivio::IO::ClassLoader->delegate_require($proto);
}

1;
