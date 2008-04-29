# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Widget::LogicalOpBase;
use strict;
use Bivio::Base 'UI.Widget';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    my($name) = 0;
    foreach my $v (@{$self->get('values')}) {
	$self->initialize_value($name++, $v);
    }
    return;
}

sub internal_new_args {
    my(undef, @values) = @_;
    return {values => \@values};
}

sub internal_render_end {
    return;
}

sub internal_render_start {
    return;
}

sub internal_render_true {
    my($self, $state, $value) = @_;
    ${$state->{buffer}} .= $value;
    return 0;
}

sub render {
    my($self, $source, $buffer) = @_;
    my($state) = {
	source => $source,
	buffer => $buffer,
    };
    $self->internal_render_start($state);
    my($last_value);
    foreach my $v (@{$self->get('values')}) {
	return unless $self->internal_render_operand(
	    $last_value = $self->render_simple_value($v, $source),
	    $state,
	);
    }
    $self->internal_render_end($state, $last_value);
    return;
}

1;
