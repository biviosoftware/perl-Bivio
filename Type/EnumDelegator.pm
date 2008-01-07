# Copyright (c) 2004-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::EnumDelegator;
use strict;
use Bivio::Base 'Bivio::Type::Enum';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($AUTOLOAD);
my($_MAP) = {};

sub AUTOLOAD {
    my($proto) = shift;
    my($method) = $AUTOLOAD =~ /([^:]+)$/;
    return if $method eq 'DESTROY';
    my($c) = ref($proto) || $proto;
    # can() returns a reference to the method to invoke
    # use this so delegates can be subclassed
    $_MAP->{$c} ||= Bivio::IO::ClassLoader->delegate_require($c);
    my($dispatch) = $_MAP->{$c}->can($method);
    Bivio::Die->die('method not found: ', $c, '->', $method)
        unless $dispatch;
    return ref($proto) ? $dispatch->($proto, @_) : $_MAP->{$c}->$method(@_);
}

sub compile {
    my($proto, $values) = @_;
    return $proto->SUPER::compile(
	$values || Bivio::IO::ClassLoader->delegate_require_info($proto),
    );
}

sub is_continuous {
    return 0;
}

1;
