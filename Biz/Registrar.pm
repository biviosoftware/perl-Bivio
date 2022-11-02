# Copyright (c) 2008-2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Registrar;
use strict;
use Bivio::Base 'Bivio.UNIVERSAL';

my($_IDI) = __PACKAGE__->instance_data_index;

sub call_fifo {
    my($self, $method, $args, $call_wrapper) = @_;
    my($q) = [@{$self->[$_IDI]}];
    $args ||= [];
    return [map(_call($_, $method, $args, $call_wrapper), @$q)];
}

sub do_filo {
    my($self, $method, $args, $call_wrapper) = @_;
    $args ||= [];
    foreach my $h (reverse(@{[@{$self->[$_IDI]}]})) {
        my($res) = _call($h, $method, $args, $call_wrapper);
        return $res
            if defined($res);
    }
    return;
}

sub new {
    my($self) = shift->SUPER::new;
    $self->[$_IDI] = [];
    return $self;
}

sub push_object {
    my($self, $object) = @_;
    $object = b_use($object)
        unless ref($object);
    my($q) = $self->[$_IDI];
    push(@$q, $object)
        unless grep($_ eq $object, @$q);
    return;
}

sub _call {
    my($object, $method, $args, $call_wrapper) = @_;
    $call_wrapper ||= sub {shift->()};
    return $call_wrapper->(
        sub {
            return $object->($method, @{_call_args($args)})
                if ref($object) eq 'CODE';
            return $object->$method(@{_call_args($args)})
                if $object->can($method);
            return;
        },
    );
}

sub _call_args {
    my($args) = @_;
    return [ref($args) eq 'CODE' ? @{$args->()} : @$args];
}

1;
