# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::t::UNIVERSAL::Clonee;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_NUM) = 1;

sub equals {
    my($self, $that) = @_;
    return $self->[$_IDI]->{num} == $that->[$_IDI]->{num} ? 1 : 0;
}

sub new {
    my($self) = shift->SUPER::new(@_);
    $self->[$_IDI] = {
        num => $_NUM++,
    };
    return $self;
}

1;
