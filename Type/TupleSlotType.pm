# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::TupleSlotType;
use strict;
use Bivio::Base 'Type.TupleSlot';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub DEFAULT_CLASS {
    return 'String';
}

sub as_string {
    my($self) = @_;
    return shift->SUPER::as_string(@_)
	unless ref($self);
    my($fields) = $self->[$_IDI];
    my($s) = $fields->{choices}->to_literal($fields->{choices});
    my($c) = $fields->{class}->simple_package_name;
    $c = $self->DEFAULT_CLASS
	if $c eq 'TupleSlot';
    return $self->simple_package_name
	. '['
	. $c
	. (length($s) ? ";$s" : '')
	. ']';
}

sub from_literal {
    my($self) = shift;
    return $self->SUPER::from_literal(@_)
	unless ref($self);
    my($fields) = $self->[$_IDI];
    my($v, $e) = $fields->{class}->from_literal(@_);
    return ($v, $e)
	unless defined($v);
    my($c) = $self->[$_IDI]->{choices};
    return $v
	unless $c->is_specified;
    my($found);
    $c->do_iterate(
	sub {($found = $fields->{class}->is_equal(shift, $v)) ? 0 : 1});
    return $found ? $v : (undef, Bivio::TypeError->NOT_FOUND);
}

sub new {
    my($self) = shift->SUPER::new;
    my($class, $choices) = @_;
    $self->[$_IDI] = {
	class => Bivio::Type->get_instance(
	    $class eq $self->DEFAULT_CLASS ? 'TupleSlot' : $class),
	choices => $choices,
    };
    return $self;
}

1;
