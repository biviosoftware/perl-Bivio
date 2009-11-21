# Copyright (c) 1999-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::String;
use strict;
use Bivio::Base 'UI.Widget';

# C<Bivio::UI::HTML::Widget::String> draws a string with decoration.  Does no
# alignment (see L<Bivio::UI::HTML::Widget::Grid|Bivio::UI::HTML::Widget::Grid>
# for layout issues).
#
# The string is html-escaped and newlines are converted to C<E<lt>brE<gt>>.
#
#
#
# escape_html : boolean [see description]
#
# Should we escape HTML specials within the value?
#
# True by default for non-widgets.  False by default if the value or the widget
# value is a widget.
#
# format : Bivio::UI::HTML::Format []
#
# format : string []
#
# The name of the formatter to use on I<value> before escaping the html.
# Only valid if I<value> is not a widget.
#
# hard_newlines : boolean [1]
#
# Newlines force hard breaks in the text.  Only valid if
# I<escape_html> is true.
#
# hard_spaces : boolean [0]
#
# Replace all spaces (not tabs or newlines) in the text with &nbsp;.
# Only valid if I<escape_html> is true.
#
# pad_left : int [0]
#
# Number of non-breaking spaces to pad on the left.
#
# pad_right : int [0]
#
# Number of non-breaking spaces to pad on the right.
#
# string_font : string [] (inherited, dynamic)
#
# The value to be passed to L<Bivio::UI::Font|Bivio::UI::Font>.
#
# undef_value : string ['']
#
# What to display if I<value> is C<undef>.
# Not used if I<value> is a constant.
#
# value : array_ref (required)
#
# Dereferenced and passed to C<$source-E<gt>get_widget_value>
# to get string to use (see below).  The return value of
# get_widget_value may be widget in which case render is called.
#
# value : string (required)
#
# Text to render.
#
# value : Bivio::UI::Widget (required)
#
# The widget to render.  Typically, can only be
# L<Bivio::UI::Widget::Join|Bivio::UI::Widget::Join>,
# but may be any widget.  Purpose is to be able to set the
# font on a collection of strings join.
#
# The values returned by the widget are not "escaped".  The widget
# must generate proper html.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_F) = b_use('UIHTML.Format');

sub initialize {
    my($self) = @_;
    # Initializes static information and child widgets.
    my($fields) = $self->[$_IDI];
    return if exists($fields->{value});
    $fields->{font} = $self->ancestral_get('string_font', undef);

    # -1 is default true which is handled differently in widget and
    # html cases.
    $fields->{escape} = $self->get_or_default('escape_html', -1);

    $fields->{hard_newlines} = $self->get_or_default('hard_newlines',
	    $fields->{escape});
    $fields->{hard_spaces} = $self->get_or_default('hard_spaces', 0);
    my($pad_left) = $self->get_or_default('pad_left', 0);
    $fields->{prefix} = $pad_left > 0 ? ('&nbsp;' x $pad_left) : '';
    my($pad_right) = $self->get_or_default('pad_right', 0);
    $fields->{suffix} = $pad_right > 0 ? ('&nbsp;' x $pad_right) : '';

    # Formatter
    my($f) = $self->unsafe_get('format', 0);
    $fields->{format} = $_F->get_instance($f) if $f;

    $fields->{undef_value} = $self->get_or_default('undef_value', '');

    # Value
    $fields->{value} = $self->get('value');
    if ($fields->{is_literal} = !ref($fields->{value})) {
        # do nothing, formatter may be dynamic
    }
    elsif ($fields->{is_widget} = $self->is_blessed(
	$fields->{value}, 'Bivio::UI::Widget')
    ) {
	$fields->{value}->initialize_with_parent($self);
    }
    Bivio::IO::Alert->warn('is_widget and has formatter')
            if $fields->{is_widget} && $fields->{format};
    return;
}

sub internal_new_args {
    my(undef, $value, $font, $attributes) = @_;
    # Implements positional argument parsing for L<new|"new">.
    return '"value" attribute must be defined' unless defined($value);
    if (ref($font) eq 'HASH' && !defined($attributes)) {
	$attributes = $font;
	$font = undef;
    }
    return {
	value => $value,
	(defined($font) ? (string_font => $font) : ()),
	($attributes ? %$attributes : ()),
    };
}

sub new {
    my($self) = shift->SUPER::new(@_);
    # Create a C<String> widget with I<value> and I<font> (if supplied and defined).
    # Pass C<0> (zero) as I<font> to set "no font".  Will not set font, if C<undef>.
    # Optionally, pass other I<attributes>.
    #
    #
    # If I<attributes> supplied, creates with attribute (name, value) pairs.
    $self->[$_IDI] = {};
    return $self;
}

sub render {
    my($self, $source, $buffer) = @_;
    # Render the object.  Outputs nothing if result is empty.
    my($fields) = $self->[$_IDI];
    Bivio::Die->die("String widget not initialized: ", $self->get('value'))
	    unless exists($fields->{value});

    my($b) = '';
    if ($fields->{is_literal}) {
        $b = _format($fields, $fields->{value});
    }
    elsif ($fields->{is_widget}) {
	$fields->{value}->render($source, \$b);
	# Note the special treatment of non-default true.
	$b = _escape($fields, $b) if $fields->{escape} == 1;
    }
    else {
	my($v) = $self->unsafe_resolve_widget_value($fields->{value}, $source);
	$v = $self->unsafe_resolve_widget_value(
	    $fields->{undef_value}, $source,
	) unless defined($v);
	# Result may be a widget!
	if (ref($v) && UNIVERSAL::isa($v, 'Bivio::UI::Widget')) {
	    $self->initialize_value($v);
	    $v->initialize_with_parent($self);
	    $v->render($source, \$b);
	    # Note the special treatment of non-default true.
	    $b = _escape($fields, $b) if $fields->{escape} == 1;
	}
	else {
	    $b .= _format($fields, $v);
	}
    }
    # Don't output anything if string is empty
    return unless length($b);

    # Render the font dynamically.  Don't call method unless there is a font
    # for performance reasons.
    my($f) = $fields->{font};
    if (ref($f)) {
	$f = '';
	$self->unsafe_render_value(
	    'string_font', $fields->{font}, $source, \$f);
    }
    my($p, $s) = $f ? Bivio::UI::Font->format_html($f, $source->get_request)
	: ('', '');
    $$buffer .= $p.$fields->{prefix}.$b.$fields->{suffix}.$s;
    return;
}

sub _escape {
    my($fields, $value) = @_;
    # Escapes the value.
    $value = Bivio::HTML->escape($value);
    $value =~ s/ /&nbsp;/sg if $fields->{hard_spaces};
    $value =~ s{\n}{<br />}mg if $fields->{hard_newlines};
    $value =~ s/^\s+$/&nbsp;/s;
    return $value;
}

sub _format {
    my($fields, $value) = @_;
    # Formats and escapes the string and replaces newlines with <br>.
    # An all space string equates to a &nbsp;
    if ($fields->{format}) {
	$value = $fields->{format}->get_widget_value($value);
	return $value if $fields->{format}->result_is_html;
    }
    if (ref($value)) {
	Bivio::Die->die('got ref where scalar expected: ', $value)
	    unless Bivio::UNIVERSAL->is_blessed($value)
	    && $value->can('as_html');
	return $value->as_html;
    }
    # Note the treatment of escape when -1 or +1.
    return $fields->{escape} ? _escape($fields, $value) : $value;
}

1;
