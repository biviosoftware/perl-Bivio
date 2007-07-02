# Copyright (c) 1999-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Widget::Join;
use strict;
use Bivio::Base 'Bivio::UI::Widget';

# C<Bivio::UI::Widget::Join> is a sequence of widgets and literal text.
#
# join_separator : any []
#
# Widget which renders between values which render successfully
# (unsafe_render_value returns true).
#
# values : array_ref (required)
#
# The widgets, text, and widget_values which will be rendered as a part of the
# sequence.  The rendered values are unmodified.  If all the values are constant,
# the result of this widget will be constant.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    # Initializes widget state and children.
    my($name) = 0;
    foreach my $v (@{$self->get('values')}) {
	$self->initialize_value($name++, $v);
    }
    $self->unsafe_initialize_attr('join_separator');
    return;
}

sub internal_as_string {
    my($self) = @_;
    # Returns the first two values in the join
    #
    # See L<Bivio::UI::Widget::as_string|Bivio::UI::Widget/"as_string">.
    my($values) = $self->unsafe_get('values');
    # A little bit of safety.  Don't want to crash in "as_string".
    return ($values) unless ref($values) eq 'ARRAY';
    my(@res) = @$values;
    return int(@res) > 2 ? (splice(@res, 0, 2), '...') : @res;
}

sub internal_new_args {
    my(undef, $values, $join_separator, $attributes) = @_;
    # Implements positional argument parsing for L<new|"new">.
    return '"values" attribute must be an array_ref'
	unless ref($values) eq 'ARRAY';
    if (ref($join_separator) eq 'HASH') {
	$attributes = $join_separator;
	$join_separator = undef;
    }
    return {
	values => $values,
	($join_separator ? (join_separator => $join_separator) : ()),
	($attributes ? %$attributes : ()),
    };
}

sub render {
    my($self, $source, $buffer) = @_;
    my($name) = 0;
    if ($self->has_keys('join_separator')) {
	my($need_sep) = 0;
	foreach my $v (@{$self->get('values')}) {
	    my($b) = '';
	    my($next_sep)
		= $self->unsafe_render_value($name++, $v, $source, \$b)
		&& length($b);
	    if ($need_sep && $next_sep) {
		$self->unsafe_render_attr('join_separator', $source, $buffer);
	    }
	    $need_sep ||= $next_sep;
	    $$buffer .= $b;
	}
    }
    else {
	foreach my $v (@{$self->get('values')}) {
	    $self->unsafe_render_value($name++, $v, $source, $buffer);
	}
    }
    return;
}

1;
