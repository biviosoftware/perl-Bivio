# Copyright (c) 2004 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::t::Delegator::I1;
use strict;
use Bivio::Base 'Bivio.Delegate';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub new {
    # (proto) : Delegator.I1
    # Does the new thing.
    my($proto) = shift;
    my($self) = $proto->SUPER::new;
    $self->[$_IDI] = {
	value => shift,
    };
    return $self;
}

sub static_echo {
    # (proto, any) : any
    # Echo arg.
    shift;
    return @_;
}

sub value {
    # (self) : any
    # Returns value passed in.
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return $fields->{value};
}

1;
