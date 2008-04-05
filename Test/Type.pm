# Copyright (c) 2005-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Type;
use strict;
use Bivio::Base 'TestUnit.Unit';
use Bivio::TypeError;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($AUTOLOAD);

sub AUTOLOAD {
    my($func) = $AUTOLOAD =~ /(\w+)$/;
    return if $func eq 'DESTROY';
    return [undef, Bivio::TypeError->$func(@_)];
}

sub UNDEF {
    return [undef, undef];
}

sub from_literal_error {
    my(undef, $type_error) = @_;
    return [undef, Bivio::TypeError->from_any($type_error)];
}

sub unit {
    return shift->SUPER::unit(@_)
	if @_ > 2;
    my($self, $group) = @_;
    my($c) = $self->builtin_class;
    return $self->SUPER::unit(ref($group->[0]) eq 'ARRAY' ? $group : [
	map({
	    my($next) = [splice(@$group, 0, 2)];
	    $c eq $next->[0] ? @$next : ($c => $next);
	} 1 .. @$group/2),
    ]);
}

1;
