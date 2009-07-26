# Copyright (c) 2005-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Type;
use strict;
use Bivio::Base 'TestUnit.Unit';
use Bivio::TypeError;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_TE) = b_use('Bivio.TypeError');

sub UNDEF {
    return [undef, undef];
}

sub from_literal_error {
    my(undef, $type_error) = @_;
    return [undef, $_TE->from_any($type_error)];
}

sub handle_test_unit_autoload {
    my($self, $func) = @_;
    return [undef, $_TE->from_name($func)];
}

sub handle_test_unit_autoload_ok {
    my(undef, $func) = @_;
    return $_TE->is_valid_name($func) && $_TE->unsafe_from_name($func);
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
