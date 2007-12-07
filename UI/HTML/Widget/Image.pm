# Copyright (c) 1999-2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Image;
use strict;
$Bivio::UI::HTML::Widget::Image::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::Image::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::Image - renders an in-line image

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Image;

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget::ControlBase>

=cut

use Bivio::UI::HTML::Widget::ControlBase;
@Bivio::UI::HTML::Widget::Image::ISA = ('Bivio::UI::HTML::Widget::ControlBase');

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

=item alt : string (required)

The verbatim text to use for I<alt_text>.  No Facade.Text lookup is performed.

=item alt_text : string (required)

Text tag to use for C<ALT> attribute of C<IMG> tag.  Tag will be prefixed with
C<Image_alt> qualifier.  Resultant text will be passed to
L<Bivio::HTML->escape|Bivio::Util/"escape_html">.

=item alt_text : array_ref (required)

=item attributes : string []

Arbitrary HTML attributes to be applied to the begin tag.  Must begin
with leading space.

=item class : any []

The html CLASS for the table.  If exists, then border is not
defaulted.

=item hspace : int [0]

HSPACE attribute value.

=item border : int [0]

Set to zero by default, so you rarely need to set this.

=item height : int [src's height]

The (constant) height of the image.  Useful in combination with single pixel
clear gif for forcing dimensions of an area.  Both B<height> and
B<width> must be set.

For "real" gifs, the dimensions are extracted from the file.

=item id : any []

The html ID attribute.

=item src : array_ref (required)

Image to use for C<SRC> attribute of C<IMG> tag.  I<src>'s
get_widget_value returns a string,  which is looked up via
L<Bivio::UI::Icon|Bivio::UI::Icon> if it is a qualified name
or it is used verbatim if it is a URI.

=item src : string

Name of the L<Bivio::UI::Icon|Bivio::UI::Icon> to use.

=item width : int [src's width]

See B<height>.

=item vspace : int [0]

VSPACE attribute value.

=back

=cut

#=IMPORTS
use Bivio::UI::Align;

#=VARIABLES
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';
my($_OLD_HTML) =
    [qw(hspace vspace width height border align attributes)];

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes static information.  In this case, prefix, alt, and
src, and have_size.

=cut

sub initialize {
    my($self) = @_;
    $self->initialize_attr('src');
    $self->map_invoke(
	unsafe_initialize_attr => [
	    @$_OLD_HTML,
	    'alt',
	    'alt_text',
	]
    );
    return shift->SUPER::initialize(@_);
}

=for html <a name="internal_as_string"></a>

=head2 internal_as_string() : string

Returns I<src>.

See L<Bivio::UI::Widget::as_string|Bivio::UI::Widget/"as_string">.

=cut

sub internal_as_string {
    my($self) = @_;
    return ($self->unsafe_get('src'));
}

=for html <a name="internal_new_args"></a>

=head2 static internal_new_args(any arg, ...) : any

Implements positional argument parsing for L<new|"new">.

=cut

sub internal_new_args {
    return {
	alt_text => ref($_[2]) eq 'HASH' ? undef : [splice(@_, 2, 1)]->[0],
	%{shift->internal_compute_new_args([qw(src)], \@_)},
    };
}

=for html <a name="control_on_render"></a>

=head2 control_on_render(any source, string_ref buffer)

Render the image.

=cut

sub control_on_render {
    my($self, $source, $buffer) = @_;
    my($src) = ${$self->render_attr('src', $source)};
    my($src_is_uri) = $src =~ m{[/:]};
    my($src_name) = $src_is_uri ? $src =~ m{([^/]+)\.\w+$} || '' : $src;
    my($b) = '<img';
    $self->SUPER::control_on_render($source, \$b);
    $b .= qq{ class="$src_name"}
	if $b !~ /class=|id=/ && $_VS->vs_xhtml($source);
    $$buffer .= $b;
    my($alt) = $self->has_keys('alt')
	? $self->render_simple_attr('alt', $source)
	: Bivio::UI::Text->get_from_source($source)
	->unsafe_get_widget_value_by_name(
	    'Image_alt.'
	    . (defined($self->unsafe_get('alt_text'))
	        ? $self->render_simple_attr('alt_text', $source)
		: $src_name,
	    ),
	);
    $$buffer .= ' alt="' . Bivio::HTML->escape_attr_value($alt) . '"'
	if $alt;
    my($a) = {map(($_ => $self->render_simple_attr($_)), @$_OLD_HTML)};
    $a->{border} ||= '0'
	unless  $b =~ /class=|id=/;
    foreach my $k (qw(width height)) {
	$a->{$k} ||= '';
    }
    $$buffer .= join(
	'',
	Bivio::UI::Align->as_html(delete($a->{align})),
	delete($a->{attributes}),
	map((length($a->{$_}) ? qq{ $_="$a->{$_}"} : ()), sort(keys(%$a))),
    ) . (
	$src_is_uri ? qq{ src="$src"}
	    : defined($self->unsafe_get('width'))
	    ? (' src="' . Bivio::HTML->escape(
		Bivio::UI::Icon->get_value($src, $source)->{uri}) . '"')
	    : Bivio::UI::Icon->format_html($src, $source)
    ) . ' />';
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2005 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
