# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::String;
use strict;
$Bivio::UI::HTML::Widget::String::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::String - renders a string with font decoration

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::String;
    Bivio::UI::HTML::Widget::String->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::String::ISA = qw(Bivio::UI::HTML::Widget);

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::String> draws a string with decoration.  Does no
alignment (see L<Bivio::UI::HTML::Widget::Grid|Bivio::UI::HTML::Widget::Grid>
for layout issues).

The string is html-escaped and newlines are converted to C<E<lt>br E<gt>>.

=head1 ATTRIBUTES

=over 4

=item format : Bivio::UI::HTML::Format []

=item format : string []

The name of the formatter to use on I<value> before escaping the html.
Only valid if I<value> is not a widget.

=item pad_left : int [0]

Number of non-breaking spaces to pad on the left.

=item string_font : string [] (inherited)

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

=item value : Bivio::UI::HTML::Widget (required)

The widget to render.  Typically, can only be
L<Bivio::UI::HTML::Widget::Join|Bivio::UI::HTML::Widget::Join>,
but may be any widget.  Purpose is to be able to set the
font on a collection of strings join.

The values returned by the widget are not "escaped".  The widget
must generate proper html.

=back

=cut

#=IMPORTS
use Bivio::IO::Alert;
use Bivio::UI::Font;
use Bivio::UI::HTML::Format;
use Bivio::Util;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::String

Creates a new String widget.

=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes static information.  In this case, prefix and suffix
field values.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if exists($fields->{value});
    my($font) = $self->ancestral_get('string_font', undef);
    my($p, $s) = $font ? Bivio::UI::Font->as_html($font) : ('', '');
    my($pad_left) = $self->get_or_default('pad_left', 0);
    $p .= '&nbsp;' x $pad_left if $pad_left > 0;

    # Formatter
    my($f) = $self->unsafe_get('format', 0);
    $fields->{format} = Bivio::UI::HTML::Format->get_instance($f) if $f;

    $fields->{undef_value} = $self->get_or_default('undef_value', '');

    # Value
    $fields->{value} = $self->get('value');
    if ($fields->{is_constant} = !ref($fields->{value})) {
    	$fields->{value} = $p._format($fields->{format}, $fields->{value}).$s;
    }
    else {
	$fields->{prefix} = $p;
	$fields->{suffix} = $s;
	if ($fields->{is_widget} = ref($fields->{value}) ne 'ARRAY') {
	    $fields->{value}->put(parent => $self);
	    $fields->{value}->initialize;
	}
    }
    return;
}

=for html <a name="is_constant"></a>

=head2 is_constant : boolean

Will return true if always renders exactly the same way.

=cut

sub is_constant {
    return shift->{$_PACKAGE}->{is_constant};
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Render the object.  Outputs nothing if result is empty.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    die("String not initialized: ".$self->get('value'))
	    unless exists($fields->{value});

    $$buffer .= $fields->{value}, return if $fields->{is_constant};
    my($b) = '';
    if ($fields->{is_widget}) {
	$fields->{value}->render($source, \$b);
    }
    else {
	my($value) = $source->get_widget_value(@{$fields->{value}});
	$value = ref($fields->{undef_value})
		? $source->get_widget_value(@{$fields->{undef_value}})
			: $fields->{undef_value}
				unless defined($value);
	# Result may be a widget!
	if (ref($value) && UNIVERSAL::isa($value, 'Bivio::UI::HTML::Widget')) {
	    $value->render($source, \$b);
	}
	else {
	    $b .= _format($fields->{format}, $value);
	}
    }
    # Don't output anything if nothing passed
    $$buffer .= $fields->{prefix}.$b.$fields->{suffix} if length($b);
    return;
}

#=PRIVATE METHODS

# _format(Bivio::UI::HTML::Format format, string value) : string
#
# Formats and escapes the string and replaces newlines with <br>.
# An all space string equates to a &nbsp;
#
sub _format {
    my($format, $value) = @_;
    if ($format) {
	$value = $format->get_widget_value($value);
	return $value if $format->result_is_html;
    }
    Bivio::IO::Alert->die('got ref where scalar expected: ', $value)
		if ref($value);
    $value = Bivio::Util::escape_html($value);
    $value =~ s/\n/<br>/mg || $value =~ s/^\s+$/&nbsp;/s;
    return $value;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
