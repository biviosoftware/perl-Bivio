# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::TupleChoiceList;
use strict;
use Bivio::Base 'Type.TupleSlot';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub new {
    my($self) = shift->SUPER::new;
    my($choices) = @_;
    $self->[$_IDI] = $choices,
    return $self;
}

sub provide_select_choices {
    return shift->[$_IDI];
}

1;
