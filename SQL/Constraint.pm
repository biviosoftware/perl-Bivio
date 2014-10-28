# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::SQL::Constraint;
use strict;
use Bivio::Base 'Type.Enum';

my($_TE) = b_use('Bivio::TypeError');
my($_E) = b_use('Type.Enum');
__PACKAGE__->compile([
    NONE => [0],
    PRIMARY_KEY => [1],
    NOT_NULL => [2],
    NOT_NULL_UNIQUE => [3],
    NOT_ZERO_ENUM => [4],
    IS_SPECIFIED => [5],
]);

sub check_value {
    my($self, $type, $value) = @_;
    return
	if $self->eq_none;
    return $_TE->NULL
	unless defined($value);
    if ($self->equals_by_name(qw(NOT_ZERO_ENUM IS_SPECIFIED))) {
	return $_TE->UNSPECIFIED
	    unless $type->is_specified($value);
    }
    return;
}

1;
