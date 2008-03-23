# Copyright (c) 2002-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Reply;
use strict;
use Bivio::Base 'Bivio::Agent::Reply';


our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub delete_output {
    my($self) = @_;
    my($res) = $self->unsafe_get_output;
    $self->[$_IDI]->{output} = undef;
    return $res;
}

sub get_output {
    return shift->[$_IDI]->{output}
	or Bivio::Die->die('no output');
}

sub new {
    my($proto) = shift;
    my($self) = $proto->SUPER::new(@_);
    $self->[$_IDI] = {};
    return $self;
}

sub set_cache_private {
    my($self) = @_;
    $self->put(cache_private => 1);
    return;
}

sub set_header {
    my($self, $name, $value) = @_;
    my($fields) = $self->[$_IDI];
    ($fields->{headers} ||= {})->{$name} = $value;
    return;
}

sub set_output {
    my($self, $value) = @_;
    my($fields) = $self->[$_IDI];
    # Ignore duplicate calls, that's not what were testing
    $fields->{output} = ref($value) eq 'GLOB' || ref($value) eq 'IO::File'
        ? Bivio::IO::File->read($value)
	: ref($value) eq 'SCALAR' ? $value
	: Bivio::Die->die('not a GLOB or SCALAR reference');
    return $self;
}

sub unsafe_get_output {
    return shift->[$_IDI]->{output};
}

1;
