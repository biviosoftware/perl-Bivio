# Copyright (c) 1999-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Agent::Reply;
use strict;
use Bivio::Base 'Collection.Attributes';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_AC) = b_use('Ext.ApacheConstants');

sub delete_output {
    my($self) = @_;
    my($output) = $self->unsafe_get('output');
    $self->delete('output');
    return $output;
}

sub get_output {
    my($self) = @_;
    my($o) = shift->get('output');
    return ref($o) eq 'SCALAR' ? $o : Bivio::IO::File->read($o);
}

sub get_output_type {
    return shift->get('output_type');
}

sub is_status_ok {
    my($self) = @_;
    # No status does mean ok
    return 1
	unless defined(my $s = $self->unsafe_get('status'));
#TODO: need to share with something
    return $s == $_AC->OK ? 1 : 0;
}

sub new {
    return shift->SUPER::new({
        output_type => 'text/plain',
    });
}

sub send {
    return;
}

sub set_cache_private {
    return;
}

sub set_header {
    my($self, $name, $value) = @_;
    $self->get_if_exists_else_put('headers', {})->{$name} = $value;
    return $self;
}

sub set_http_status {
    my($self, $status) = @_;
    # It is error prone keeping a list up to date, so we just check
    # a reasonable range.
    b_die($status, ': unknown HTTP status')
        unless defined($status) && $status =~ /^\d+$/
	&& 100 <= $status && $status < 600;
    return $self->put(status => $status);
}

sub set_output {
    return shift->put(output => shift);
}

sub set_output_type {
    return shift->put(output_type => shift);
}

sub unsafe_get_output {
    return shift->unsafe_get('output');
}

1;
