# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::ClearDot;
use strict;
use Bivio::Base 'Bivio::UI::Widget';
use Bivio::UI::Align;
use Bivio::UI::Icon;

# C<Bivio::UI::HTML::Widget::ClearDot> displays the clear dot
#
#
# A widget value of zero (0) will result in nothing being rendered,
# i.e. zero means "doesn't exist".
#
#
# align : string []
#
# How to align the image.  The allowed (case
# insensitive) values are defined in
# L<Bivio::UI::Align|Bivio::UI::Align>.
# The value affects the C<ALIGN> and C<VALIGN> attributes of the C<IMG> tag.
#
# height : int [1]
#
# height : array_ref []
#
# The (constant) height of the dot.
#
# width : int [1]
#
# width : array_ref []
#
# The (constant) width of the dot.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub as_html {
    # (self) : string
    # (proto, int, int) : string
    # Renders a clear dot and returns the string.  In the first case renders
    # this instance (must be initialized).  With arguments, renders a
    # constant string with the secified params.
    #
    # Don't use in rendering code, because dynamically creates a ClearDot widget.
    # Instead create a ClearDot widget and have it do the dynamic rendering.
    my($self, $width, $height) = @_;
    if (@_ > 1) {
#TODO: optimize
	$self = __PACKAGE__->new({width => $width, height => $height});
	$self->initialize;
    }
    elsif (!ref($self)) {
	die('must pass width and height if called statically');
    }
    return $self->[$_IDI]->{value};
}

sub initialize {
    # (self) : undef
    # Initializes static information.
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return if exists($fields->{value});
    $fields->{value} = '<img src="'
	    .Bivio::UI::Icon->get_clear_dot->{uri}
            .'" border="0"'
	    .Bivio::UI::Align->as_html($self->unsafe_get('align'));

    $fields->{is_constant} = 1;
    foreach my $f (qw(width height)) {
	my($fv) = $self->get_or_default($f, 1);
	if (ref($fv)) {
	    $fields->{is_constant} = 0;
	    $fields->{$f} = $fv;
	}
	elsif ($fv) {
	    $fields->{value} .= qq{ $f="$fv"};
	}
    }
    $fields->{value} .= ' />' if $fields->{is_constant};
    return;
}

sub new {
    # (proto, any, any, hash_ref) : Widget.ClearDot
    # (proto, hash_ref) : Widget.ClearDot
    # Creates a new ClearDot widget with I<width> and I<height> attributes.
    #
    #
    # Creates a new ClearDot widget using I<attributes>.
    my($proto, @args) = _new_args(@_);
    my($self) = $proto->SUPER::new(@args);
    $self->[$_IDI] = {};
    return $self;
}

sub render {
    # (self, any, string_ref) : undef
    # Render the clear dot.
    my($self, $source, $buffer) = @_;
    my($fields) = $self->[$_IDI];
    my($start) = length($$buffer);
    $$buffer .= $fields->{value};
    return if $fields->{is_constant};

    foreach my $f (qw(width height)) {
	next unless ref($fields->{$f});
	my($v) = $source->get_widget_value(@{$fields->{$f}});
	unless ($v) {
	    # Zero width or height means that it shouldn't be drawn.
	    substr($$buffer, $start) = '';
	    return;
	}
	$$buffer .= qq{ $f="$v"};
    }
    $$buffer .= ' />';
    return;
}

sub _new_args {
    # (proto, any, ...) : array
    # Returns arguments to be passed to Attributes::new.
    my($proto, $width, $height, $attributes) = @_;
    return ($proto, $width) if ref($width) eq 'HASH' || int(@_) == 1;
    return ($proto, {
	width => $width,
	height => $height,
	($attributes ? %$attributes : ()),
    }) if defined($width) || defined($height);
    $proto->die(undef, undef, 'invalid arguments to new');
    # DOES NOT RETURN
}

1;
