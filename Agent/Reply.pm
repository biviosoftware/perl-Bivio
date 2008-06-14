# Copyright (c) 1999-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Agent::Reply;
use strict;
use Bivio::Base 'Collection.Attributes';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub delete_output {
    my($self) = @_;
    my($output) = $self->unsafe_get('output');
    $self->delete('output');
    return $output;
}

sub get_output_type {
    return shift->get('output_type');
}

sub new {
    return shift->SUPER::new({
        output_type => 'text/plain',
    });
}

sub send {
    return;
}

sub set_header {
    my($self, $name, $value) = @_;
    $self->get_if_exists_else_put('headers', {})->{$name} = $value;
    return $self;
}

sub set_output {
    return shift->put(output => shift);
}

sub set_output_type {
    return shift->put(output_type => shift);
}

1;
