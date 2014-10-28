# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Widget::Equals;
use strict;
use Bivio::Base 'UI.Widget';

my($_S) = b_use('Type.String');

sub NEW_ARGS {
    return [qw(left right)];
}

sub initialize {
    my($self) = @_;
    $self->initialize_attr('left');
    $self->initialize_attr('right');
    return shift->SUPER::initialize(@_);
}

sub render {
    my($self, $source, $buffer) = @_;
    $$buffer .= '1'
	if $_S->is_equal(
	    $self->render_simple_attr('left', $source),
	    $self->render_simple_attr('right', $source),
	);
    return;
}

1;
