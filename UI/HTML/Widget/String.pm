# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::String;
use strict;
$Bivio::UI::HTML::Widget::String::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::String::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::String - renders a string with font decoration

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::String;
    Bivio::UI::HTML::Widget::String->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::String::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::String> draws a string with decoration.  Does no
alignment (see L<Bivio::UI::HTML::Widget::Grid|Bivio::UI::HTML::Widget::Grid>
for layout issues).

The string is html-escaped and newlines are converted to C<E<lt>br E<gt>>.

=head1 ATTRIBUTES

=over 4

=item escape_html : boolean [see description]

Should we escape HTML specials within the value?

True by default for non-widgets.  False by default if the value or the widget
value is a widget.

=item format : Bivio::UI::HTML::Format []

=item format : string []

The name of the formatter to use on I<value> before escaping the html.
Only valid if I<value> is not a widget.

=item hard_newlines : boolean [1]

Newlines force hard breaks in the text.  Only valid if
I<escape_html> is true.

=item pad_left : int [0]

Number of non-breaking spaces to pad on the left.

=item pad_right : int [0]

Number of non-breaking spaces to pad on the right.

=item string_font : string [] (inherited, dynamic)

The value to be passed to L<Bivio::UI::Font|Bivio::UI::Font>.

=item undef_value : string ['']

What to display if I<value> is C<undef>.
Not used if I<value> is a constant.

=item value : array_ref (required)

Dereferenced and passed to C<$source-E<gt>get_widget_value>
to get string to use (see below).  The return value of
get_widget_value may be widget in which case render is called.

=item value : string (required)

Text to render.

=item value : Bivio::UI::Widget (required)

The widget to render.  Typically, can only be
L<Bivio::UI::Widget::Join|Bivio::UI::Widget::Join>,
but may be any widget.  Purpose is to be able to set the
font on a collection of strings join.

The values returned by the widget are not "escaped".  The widget
must generate proper html.

=back

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::HTML;
use Bivio::UI::Font;
use Bivio::UI::HTML::Format;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(any value, string font, hash_ref attributes) : Bivio::UI::HTML::Widget::String

Create a C<String> widget with I<value> and I<font> (if supplied and defined).
Pass C<0> (zero) as I<font> to set "no font".  Will not set font, if C<undef>.
Optionally, pass other I<attributes>.

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::String

If I<attributes> supplied, creates with attribute (name, value) pairs.

=cut

sub new {
    my($self) = Bivio::UI::Widget::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes static information and child widgets.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if exists($fields->{value});
    $fields->{font} = $self->ancestral_get('string_font', undef);

    # -1 is default true which is handled differently in widget and
    # html cases.
    $fields->{escape} = $self->get_or_default('escape_html', -1);

    $fields->{hard_newlines} = $self->get_or_default('hard_newlines',
	    $fields->{escape});
    my($pad_left) = $self->get_or_default('pad_left', 0);
    $fields->{prefix} = $pad_left > 0 ? ('&nbsp;' x $pad_left) : '';
    my($pad_right) = $self->get_or_default('pad_right', 0);
    $fields->{suffix} = $pad_right > 0 ? ('&nbsp;' x $pad_right) : '';

    # Formatter
    my($f) = $self->unsafe_get('format', 0);
    $fields->{format} = Bivio::UI::HTML::Format->get_instance($f) if $f;

    $fields->{undef_value} = $self->get_or_default('undef_value', '');

    # Value
    $fields->{value} = $self->get('value');
    if ($fields->{is_literal} = !ref($fields->{value})) {
	# Format the constant once
	$fields->{value} = _format($fields, $fields->{value});
    }
    elsif ($fields->{is_widget} = ref($fields->{value}) ne 'ARRAY') {
	$fields->{value}->put_and_initialize(parent => $self);
    }
    return;
}

=for html <a name="internal_new_args"></a>

=head2 static internal_new_args(any arg, ...) : any

Implements positional argument parsing for L<new|"new">.

=cut

sub internal_new_args {
    my(undef, $value, $font, $attributes) = @_;
    return '"value" attribute must be defined' unless defined($value);
    return {
	value => $value,
	defined($font) ? (string_font => $font) : (),
	($attributes ? %$attributes : ()),
    };
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Render the object.  Outputs nothing if result is empty.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    Bivio::Die->die("String widget not initialized: ", $self->get('value'))
	    unless exists($fields->{value});

    my($b) = '';
    if ($fields->{is_literal}) {
	$b = $fields->{value};
    }
    elsif ($fields->{is_widget}) {
	$fields->{value}->render($source, \$b);
	# Note the special treatment of non-default true.
	$b = _escape($fields, $b) if $fields->{escape} == 1;
    }
    else {
	my($value) = $source->get_widget_value(@{$fields->{value}});
	$value = ref($fields->{undef_value})
		? $source->get_widget_value(@{$fields->{undef_value}})
			: $fields->{undef_value}
				unless defined($value);
	# Result may be a widget!
	if (ref($value) && UNIVERSAL::isa($value, 'Bivio::UI::Widget')) {
	    $value->render($source, \$b);
	    # Note the special treatment of non-default true.
	    $b = _escape($fields, $b) if $fields->{escape} == 1;
	}
	else {
	    $b .= _format($fields, $value);
	}
    }
    # Don't output anything if string is empty
    return unless length($b);

    # Render the font dynamically.  Don't call method unless there is a font
    # for performance reasons.
    my($p, $s) = $fields->{font} ? Bivio::UI::Font->format_html(
	    $fields->{font}, $source->get_request) : ('', '');
    $$buffer .= $p.$fields->{prefix}.$b.$fields->{suffix}.$s;
    return;
}

#=PRIVATE METHODS

# _escape(hash_ref fields, string value) : string
#
# Escapes the value.
#
sub _escape {
    my($fields, $value) = @_;
    $value = Bivio::HTML->escape($value);
    $value =~ s/\n/<br>/mg if $fields->{hard_newlines};
    $value =~ s/^\s+$/&nbsp;/s;
    return $value;
}

# _format(hash_ref fields, string value) : string
#
# Formats and escapes the string and replaces newlines with <br>.
# An all space string equates to a &nbsp;
#
sub _format {
    my($fields, $value) = @_;
    if ($fields->{format}) {
	$value = $fields->{format}->get_widget_value($value);
	return $value if $fields->{format}->result_is_html;
    }
    Bivio::Die->die('got ref where scalar expected: ', $value)
		if ref($value);
    # Note the treatment of escape when -1 or +1.
    return $fields->{escape} ? _escape($fields, $value) : $value;
}

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
