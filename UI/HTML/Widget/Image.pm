# Copyright (c) 1999-2005 bivio Inc.  All rights reserved.
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
    Bivio::UI::HTML::Widget::Image->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::Image::ISA = qw(Bivio::UI::Widget);

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

=item alt_text : Bivio::UI::Widget (required)

Widget to render string to be used in C<ALT> attribute.
Will be passed to
L<Bivio::HTML::escape_attr_value|Bivio::HTML/"escape_attr_value">.

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
L<Bivio::UI::Icon|Bivio::UI::Icon>.

=item src : string

Name of the L<Bivio::UI::Icon|Bivio::UI::Icon> to use.

=item width : int [src's width]

See B<height>.

=item vspace : int [0]

VSPACE attribute value.

=back

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::HTML;
use Bivio::UI::Icon;
use Carp ();

#=VARIABLES

my($_IDI) = __PACKAGE__->instance_data_index;
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(any icon, any alt_text, hash_ref attributes) : Bivio::UI::HTML::Widget::Image

Passes I<icon> and I<alt_text> (or I<icon> as I<alt_text> if I<alt_text> is
undef) as attributes.  And optionally, set extra I<attributes>.

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::Image

Creates a new Image widget using I<attributes>.

=cut

sub new {
    my($self) = Bivio::UI::Widget::new(@_);
    $self->[$_IDI] = {};
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
    my($fields) = $self->[$_IDI];
    return if exists($fields->{prefix});

    # Both must be defined
    my($src) = $self->get('src');
#TODO: Need to ensure we set alt_text.  Maybe want to warn_deprecated?
    $fields->{alt} = $self->unsafe_initialize_attr('alt');
    $fields->{alt_text} = $self->initialize_attr('alt_text')
	    unless defined($fields->{alt});

    my($width, $height, $border) = $self->unsafe_get(qw(width height border));
    die('width and height must both be defined')
	unless defined($width) == defined($height);
    my($p) = '<img';
    my($a) = $self->unsafe_get('attributes');
    $p .= $a if $a;
    foreach my $f (qw(hspace vspace)) {
	my($v) = $self->unsafe_get($f);
	next unless $v;
	$p .= ' '.$f.'='.$v;
    }

    my($v) = $self->unsafe_get('align');
    $p .= Bivio::UI::Align->as_html($v) if $v;

    # Assume false until after first render.
    if (!ref($fields->{alt}) && defined($fields->{alt})) {
	$p .= ' alt="'.Bivio::HTML->escape($fields->{alt}).'"';
	delete($fields->{alt});
    }
    # If width defined, then height defined.
    if (defined($width)) {
	# Allow for 0 in either dimension
	$p .= qq{ width="$width"} if $width;
	$p .= qq{ height="$height"} if $height;
    }
    $border ||= 0
	unless $self->has_keys('class');
    $p .= qq{ border="$border"}
	if defined($border);
    $_VS->vs_html_attrs_initialize($self);
    $fields->{prefix} = $p;
    $fields->{have_size} = defined($width);
    $fields->{src} = $src;
    return;
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
    my(undef, $icon, $text, $attributes) = @_;
    return '"icon" attribute must be defined' unless defined($icon);
    return {
	src => $icon,
	alt_text => defined($text) ? $text : $icon,
	($attributes ? %$attributes : ()),
    };
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Render the image.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($req) = $source->get_request;
    my($fields) = $self->[$_IDI];

    $$buffer .= $fields->{prefix};
    $$buffer .= $_VS->vs_html_attrs_render($self, $source);
    $$buffer .= ' alt="'.Bivio::HTML->escape_attr_value(
	_render_alt($self, $fields, $source, $req)).'"'
	unless $fields->{prefix} =~ / alt=/;

    # May be a widget value
    my($src) = $fields->{src};
    $src = $source->get_widget_value(@$src)
	if ref($src) eq 'ARRAY';

    # Must return a string (used to return a hash)
    Bivio::Die->die($fields->{src}, ' return a ref: ', $src)
		if ref($src);

    unless ($fields->{have_size}) {
	# Normal case: icon is dynamic and size comes from Icon
	$$buffer .= Bivio::UI::Icon->format_html($src, $req).' />';
	return;
    }

    # Have a size, so must format explicitly.
    $src = Bivio::UI::Icon->get_value($src, $req);

    $$buffer .= ' src="'.Bivio::HTML->escape($src->{uri}).'"';
    $$buffer .= qq{ width="$src->{width}" height="$src->{height}"}
	if !$fields->{have_size} && defined($src->{width});
    $$buffer .= ' />';
    return;
}

#=PRIVATE METHODS

# _render_alt(self, hash_ref fields, any source, Bivio::Agent::Request req) : string
#
# Renders the alt_text or alt.
#
sub _render_alt {
    my($self, $fields, $source, $req) = @_;
#TODO: Deprecated
    return $source->get_widget_value(@{$fields->{alt}}) if $fields->{alt};
    return '' unless $fields->{alt_text};

    my($b) = $self->render_value('alt_text', $fields->{alt_text}, $source);
    return $$b if ref($fields->{alt_text});
    return Bivio::UI::Text->get_value('Image_alt', $$b, $req);
}

=head1 COPYRIGHT

Copyright (c) 1999-2005 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
