# Copyright (c) 2001-2011 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Delegator;
use strict;
use Bivio::Base 'Bivio.UNIVERSAL';

# C<Bivio::Delegator> delegates implementation to another class. Subclasses
# must have an entry in ClassLoader.delegates.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($AUTOLOAD);
my($_CL) = b_use('IO.ClassLoader');
my($_IDI) = __PACKAGE__->instance_data_index;
my($_MAP) = {};
our($last) = '';

sub AUTOLOAD {
    my($proto) = shift;
    my($method) = $AUTOLOAD =~ /([^:]+)$/;
    return
	if $method eq 'DESTROY';
    die($AUTOLOAD)
	if $AUTOLOAD eq $last;
    local($last) = $AUTOLOAD;
    return (
	ref($proto) ? $proto->[$_IDI]->{delegate}
	    : $proto->internal_delegate_package
    )->$method(@_);
}

sub b_can {
    my($proto, $method) = @_;
    return $proto->internal_delegate_package->can($method)
	|| $proto->SUPER::b_can($method)
	? 1 : 0;
}

sub internal_delegate_package {
    my($proto) = @_;
    return $_MAP->{$proto} ||= $_CL->delegate_require($proto);
}

sub new {
    my($proto, @args) = @_;
    my($self) = $proto->SUPER::new;
    $self->[$_IDI] = {
	delegate => ref($self)->internal_delegate_package->new(@args),
    };
    return $self;
}

1;
