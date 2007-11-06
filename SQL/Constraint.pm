# Copyright (c) 1999-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::SQL::Constraint;
use strict;
use Bivio::Base 'Type.Enum';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_TE) = __PACKAGE__->use('Bivio::TypeError');
my($_E) = __PACKAGE__->use('Type.Enum');
__PACKAGE__->compile([
    NONE => [0],
    PRIMARY_KEY => [1],
    NOT_NULL => [2],
    NOT_NULL_UNIQUE => [3],
    NOT_ZERO_ENUM => [4],
    NOT_NULL_SET => [5],
]);

sub check_value {
    my($self, $value) = @_;
    return
	if $self->eq_none;
    return $_TE->NULL
	unless defined($value);
    if ($self->eq_not_zero_enum) {
	return $_TE->NOT_ZERO
	    unless $value->as_int != 0;
    }
    elsif ($self->eq_not_null_set) {
	die($self, ': check_value not supported');
    }
    return;
}

1;
