# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::HTTPStatus;
use strict;
use Bivio::Base 'Bivio.Type';

# Maps statuses to Text.  Eventually will replace
# Ext.ApacheConstants

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_MAP) = {
#TODO: Fill this out
    401 => 'Authorization required',
    403 => 'Access forbidden',
    404 => 'Not found',
};

sub as_facade_text_default {
    my($self) = @_;
    return $_MAP->{$self->[$_IDI]} || ('Server error (' . $self->[$_IDI] . ')');
}

sub as_facade_text_tag {
    return shift->[$_IDI];
}

sub new {
    my($self) = shift->SUPER::new;
    b_die($self->[$_IDI], ': must be defined')
	unless defined($self->[$_IDI] = shift);
    return $self;
}

1;
