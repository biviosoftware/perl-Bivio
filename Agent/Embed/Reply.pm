# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Agent::Embed::Reply;
use strict;
use Bivio::Base 'Agent.Reply';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_F) = b_use('IO.File');

sub set_output {
    my($self, $value) = @_;
    $value = $_F->read($value)
	unless ref($value) eq 'SCALAR';
    $self->get('parent_request')->put(ref($self) => $value);
    return shift->SUPER::set_output(@_);
}

1;
