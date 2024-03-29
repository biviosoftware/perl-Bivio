# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Widget::Cond;
use strict;
use Bivio::Base 'Widget.LogicalOpBase';


sub initialize {
    my($self) = @_;
    my(@res) = shift->SUPER::initialize(@_);
    $self->die($self->get('values'), undef, 'number of elements must be even')
        unless @{$self->get('values')} % 2 == 0;
    return @res;
}

sub render {
    my($self, $source, $buffer) = @_;
    my($done) = 0;
    $self->do_by_two(
        sub {
            my($cond, $body, $index) = @_;
            return 1
                unless $self->render_simple_value($cond, $source);
            $self->render_value($index, $body, $source, $buffer);
            return 0;
        },
        $self->get('values'),
    );
    return;
}

1;
