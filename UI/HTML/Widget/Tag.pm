# Copyright (c) 2005-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::Tag;
use strict;
use base 'Bivio::UI::HTML::Widget::ControlBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub control_on_render {
    my($self, $source, $buffer) = @_;
    my($b) = '';
    $self->can('render_tag_value') ? $self->render_tag_value($source, \$b)
	: $self->render_attr('value', $source, \$b);
    return unless length($b) || $self->render_simple_attr('tag_if_empty');
    my($t) = lc(${$self->render_attr('tag')});
    $self->die('tag', $source, $t, ': is not a valid HTML tag')
	unless $t =~ /^[a-z]+\d*$/;
    my($end) = "</$t>";
    $self->SUPER::control_on_render($source, \$t);
    $$buffer .= "<$t>$b$end";
    return;
}

sub initialize {
    my($self) = @_;
    $self->map_invoke(
	'unsafe_initialize_attr',
	[qw(tag value)],
    );
    return shift->SUPER::initialize(@_);
}

sub internal_as_string {
    return shift->unsafe_get('tag', 'value');
}

sub internal_new_args {
    return shift->internal_compute_new_args([qw(tag value)], \@_);
}

1;
