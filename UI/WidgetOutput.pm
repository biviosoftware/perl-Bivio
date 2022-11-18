# Copyright (c) 2013 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::WidgetOutput;
use strict;
use Bivio::Base 'Collection.Attributes';
b_use('IO.ClassLoaderAUTOLOAD');

my($_IDI) = __PACKAGE__->instance_data_index;

sub append_buffer {
    my($self) = shift;
    my($buffer) = $self->[$_IDI]->{buffer};
    while (@_) {
        # OPTIMIZATION: Could be a very large string.  Simpler code this way, too.
        my($ref) = ref($_[0]) ? $_[0] : \$_[0];
        b_die(ref($ref), ': must be string or scalar')
            if ref($ref) ne 'SCALAR';
        $$buffer .= $$ref
            if defined($$ref);
        shift(@_);
    }
    return;
}

sub new {
    b_die('call new_from_buffer');
}

sub new_from_buffer {
    my($proto, $buffer) = @_;
    return $buffer
        if $proto->is_blesser_of($buffer);
    my($self) = shift->SUPER::new(@_);
    $self->[$_IDI] = {
        buffer => $buffer,
    };
    return $self;

}

1;
