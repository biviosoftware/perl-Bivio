# Copyright (c) 2001-2012 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Delegator;
use strict;
use Bivio::Base 'Bivio.UNIVERSAL';

our($AUTOLOAD);
our($_PREV_AUTOLOAD) = '';
my($_CL) = b_use('IO.ClassLoader');
my($_IDI) = __PACKAGE__->instance_data_index;
my($_MAP) = {};

sub AUTOLOAD {
    my($proto) = shift;
    my($method) = $AUTOLOAD =~ /([^:]+)$/;
    return
        if $method eq 'DESTROY';
    die($AUTOLOAD, ': infinite delegation loop')
        if $AUTOLOAD eq $_PREV_AUTOLOAD;
    local($_PREV_AUTOLOAD) = $AUTOLOAD;
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
