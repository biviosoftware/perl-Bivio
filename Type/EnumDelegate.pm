# Copyright (c) 2012 bivio Softare, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::EnumDelegate;
use strict;
use Bivio::Base 'Bivio.Delegate';

our($AUTOLOAD);
our($_PREV_AUTOLOAD) = '';
my($_MAP) = {};

sub AUTOLOAD {
    my($proto) = shift;
    my($method) = $AUTOLOAD =~ /([^:]+)$/;
    return
	if $method eq 'DESTROY';
    die($AUTOLOAD, ': infinite delegation loop')
	if $AUTOLOAD eq $_PREV_AUTOLOAD;
    local($_PREV_AUTOLOAD) = $AUTOLOAD;
    my($delegator) = $proto->internal_delegator_package;
    return $delegator->can($method)
	? $delegator->$method(@_)
	: b_die($method, ': method not found in ', $delegator, ' or ', $proto->package_name);
}

sub internal_delegator_package {
    return $_MAP->{shift->package_name}
	|| b_die('delegator_package not set');
}

sub internal_set_delegator_package {
    my($proto, $delegator) = @_;
    $delegator = $delegator->package_name;
    $proto = $proto->package_name;
    b_die($delegator, ': already set to other package: ', $_MAP->{$proto})
	if $_MAP->{$proto} && $_MAP->{$proto} ne $delegator;
    return $_MAP->{$proto} = $delegator;
}

1;
