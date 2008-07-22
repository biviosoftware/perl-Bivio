# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Registrar;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub call_fifo {
    my($self, $method, $args) = @_;
    my($q) = $self->[$_IDI];
    $args ||= [];
    foreach my $o (@$q) {
	$o->$method(ref($args) eq 'CODE' ? @{$args->()} : @$args)
	    if $o->can($method);
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
    my($q) = $self->[$_IDI];
    push(@$q, $object)
	unless grep($_ eq $object, @$q);
    return;
}

1;
