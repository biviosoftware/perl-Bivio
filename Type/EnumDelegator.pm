# Copyright (c) 2004-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::EnumDelegator;
use strict;
use Bivio::Base 'Type.Enum';

our($AUTOLOAD);
our($_PREV_AUTOLOAD) = '';
my($_MAP) = {};
my($_CL) = b_use('IO.ClassLoader');

sub AUTOLOAD {
    my($proto) = shift;
    my($method) = $AUTOLOAD =~ /([^:]+)$/;
    return
	if $method eq 'DESTROY';
    die($AUTOLOAD, ': infinite delegation loop')
	if $AUTOLOAD eq $_PREV_AUTOLOAD;
    local($_PREV_AUTOLOAD) = $AUTOLOAD;
    my($delegator) = $proto->package_name;
    my($delegate) = $delegator->internal_delegate_package;
    # can() returns a reference to the method to invoke
    # use this so delegates can be subclassed
    my($dispatch) = $delegate->can($method);
    return !$dispatch
	? $proto->can($method)
	? $proto->$method(@_)
	: b_die($method, ': method not found in ', $delegator, ' or ', $delegate)
	: ref($proto)
	? $dispatch->($proto, @_)
	: $delegate->$method(@_);
}

sub compile {
    my($proto, $values) = @_;
    return $proto->SUPER::compile(
	$values || $_CL->delegate_require($proto)->get_delegate_info,
    );
}

sub internal_delegate_package {
    my($proto) = @_;
    my($delegator) = $proto->package_name;
    ($_MAP->{$delegator} = $_CL->delegate_require($delegator))
	->internal_set_delegator_package($delegator)
	unless $_MAP->{$delegator};
    return $_MAP->{$delegator};
}

sub is_continuous {
    return 0;
}

1;
