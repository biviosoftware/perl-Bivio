# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Agent::Embed::Reply;
use strict;
use base 'Bivio::Agent::Reply';
use Bivio::IO::File;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub set_output {
    my($self, $value) = @_;
    if (ref($value) eq 'GLOB') {
	$value = Bivio::IO::File->read($value);
    }
    elsif (ref($value) ne 'SCALAR') {
	Bivio::Die->die($value, ': not an SCALAR reference');
    }
    $self->get('parent_request')->put(ref($self) => $value);
    return shift->SUPER::set_output(@_);
}

1;
