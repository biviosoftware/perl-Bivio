# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Image;
use strict;
$Bivio::UI::HTML::Widget::Image::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::Image - renders an in-line image

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Image;
    Bivio::UI::HTML::Widget::Image->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::Image::ISA = qw(Bivio::UI::HTML::Widget);

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Image>

=head1 ATTRIBUTES

=over 4

=item align : string []

How to align the image.  The allowed (case
insensitive) values are defined in
L<Bivio::UI::Align|Bivio::UI::Align>.
The value affects the C<ALIGN> and C<VALIGN> attributes of the C<IMG> tag.

=item alt : array_ref (required)

Dereferenced and passed to C<$source-E<gt>get_widget_value>
to get string to use (see below).

=item alt : string (required)

Literal text to use for C<ALT> attribute of C<IMG> tag.
Will be passed to L<Bivio::Util::escape_html|Bivio::Util/"escape_html">
before rendering.

May be C<undef>.

=item hspace : int [0]

HSPACE attribute value.

=item image_border : int [0] (inherited)

Set to zero by default, so you rarely need to set this.

=item image_height : int [src's height] (inherited)

The (constant) height of the image.  Useful in combination with single pixel
clear gif for forcing dimensions of an area.  Both B<height> and
B<width> must be set.

For "real" gifs, the dimensions are extracted from the file.

=item src : array_ref (required)

Image to use for C<SRC> attribute of C<IMG> tag.  An "image" is
a hash_ref as returned, e.g. as returned by
L<Bivio::UI::Icon::get_widget_value|Bivio::UI::Icon/"get_widget_value">.

=item src : hash_ref (required)

Already been through lookup Icon.

=item image_width : int [src's width] (inherited)

See B<height>.

=item vspace : int [0]

VSPACE attribute value.

=back

=cut

#=IMPORTS
use Bivio::Util;
use Carp ();

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::Image

Creates a new Image widget.  Typically an image widget is a constant.
You should use a L<Bivio::UI::HTML::Director|Bivio::UI::HTML::Director>
widget to select between different Image widgets.

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

Initializes static information.  In this case, prefix, alt, and
src, and have_size.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if exists($fields->{is_constant});
    # Both must be defined
    my($src, $alt) = $self->get(qw(src alt));
    my($width, $height, $border) = $self->unsafe_get(
	    qw(image_width image_height image_border));
    $border = 0 unless defined($border);
    Carp::croak('only one of width and height defined')
		unless defined($width) == defined($height);
    my($p) = '<img';

    # hspace and vspace
    foreach my $f (qw(hspace vspace)) {
	my($v) = $self->unsafe_get($f);
	next unless $v;
	$p .= ' '.$f.'='.$v;
    }

    # align
    my($v) = $self->unsafe_get('align');
    $p .= Bivio::UI::Align->as_html($v) if $v;

    # Assume false until after first render.
    $fields->{is_constant} = 0;
    if (ref($alt)) {
	$fields->{alt} = $alt;
    }
    elsif (defined($alt)) {
	$p .= ' alt="'.Bivio::Util::escape_html($alt).'"';
    }
    # If width defined, then height defined.
    if (defined($width)) {
	# Allow for 0 in either dimension
	$p .= " width=$width" if $width;
	$p .= " height=$height" if $height;
    }
    $p .= " border=$border";
    $fields->{prefix} = $p;
    $fields->{have_size} = defined($width);
    # Source is always requested.  If it is a constant, Bivio::UI::Icon
    # will say so and we'll end up returning a single constant string.
    $fields->{src} = $src;
    $fields->{is_first_render} = 1;
    $fields->{is_constant} = 0;
    return;
}

=for html <a name="is_constant"></a>

=head2 is_constant : boolean

Is this instance a constant?


=cut

sub is_constant {
    my($fields) = shift->{$_PACKAGE};
    Carp::croak('can only be called after first render')
		if $fields->{is_first_render};
    return $fields->{is_constant};
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Render the image.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    # Optimization: only if both src and alt are constants
    $$buffer .= $fields->{value}, return if $fields->{is_constant};
    $$buffer .= $fields->{prefix};
    $$buffer .= ' alt="'.Bivio::Util::escape_html(
	    $source->get_widget_value(@{$fields->{alt}})).'"'
		    if $fields->{alt};
    if ($fields->{is_first_render}) {
	my($src) = $fields->{src};
	$src = $source->get_widget_value(@$src) unless ref($src) eq 'HASH';
	my($img) = ' src="'.Bivio::Util::escape_html($src->{uri}).'"';
	$img .= " width=$src->{width} height=$src->{height}"
		if !$fields->{have_size} && defined($src->{width});
	# Only look up once, if is a constant
	if ($src->{is_constant}) {
	    $fields->{prefix} .= $img;
	    unless ($fields->{alt}) {
		$fields->{is_constant} = 1;
		$fields->{value} = $fields->{prefix} . '>';
		delete($fields->{prefix});
	    }
	    delete($fields->{src});
	}
	$$buffer .= $img;
	$fields->{is_first_render} = 0;
    }
    $$buffer .= '>';
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
