# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Icon;
use strict;
$Bivio::UI::HTML::Widget::Icon::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::Icon - renders an image and label link

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Icon;
    Bivio::UI::HTML::Widget::Icon->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::Widget::Director>

=cut

use Bivio::UI::Widget::Director;
@Bivio::UI::HTML::Widget::Icon::ISA = qw(Bivio::UI::Widget::Director);

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Icon> renders an image and, optionally, a label.
The link may not exist, e.g. no more messages, iwc an inactive
icon and grayed out text is rendered.

B<Note that C<Icon>s must be rendered within a table cell.>

=head1 ATTRIBUTES

=over 4

=item alt : array_ref (required)

Dereferenced and passed to C<$source-E<gt>get_widget_value>
to get string to use (see below).

=item alt : string (required)

Literal text to use for C<ALT> attribute of active C<IMG> tag.
Will be passed to L<Bivio::HTML->escape|Bivio::Util/"escape_html">
before rendering.

=item alt_ia : array_ref []

Dereferenced and passed to C<$source-E<gt>get_widget_value>
to get string to use (see below).

=item alt_ia : string []

Literal text to use for C<ALT> attribute of inactive C<IMG> tag.
Will be passed to L<Bivio::HTML->escape|Bivio::Util/"escape_html">
before rendering.

=item icon_font : string [] (inherited)

The font to be passed to
L<Bivio::UI::HTML::Widget::String|Bivio::UI::HTML::Widget::String>
to be applied to C<text_ia>.

=item icon_font_ia : string [icon_text_ia] (inherited)

The font to be passed to
L<Bivio::UI::HTML::Widget::String|Bivio::UI::HTML::Widget::String>
to be applied to C<text_ia>.

=item href : array_ref (required) (inherited)

Dereferenced and passed to C<$source-E<gt>get_widget_value>
to get string to use for href in links.  Must return C<undef>
if there is no link.

=item name : string (required) (inherited)

Name of the icon.  Inactive image is always, the name followed
by C<_ia> (inactive).  If there is no I<alt_ia> attribute, then
a blank icon will be drawn.

Attributes for
L<Bivio::UI::HTML::Widget::Image|Bivio::UI::HTML::Widget::Image>
will be applied through C<parent> inheritance.

=item text : array_ref []

Dereferenced and passed to C<$source-E<gt>get_widget_value>
to get string to use (see below).

=item text : string []

How to render the label.

Attributes for
L<Bivio::UI::HTML::Widget::String|Bivio::UI::HTML::Widget::String>
will be applied through C<parent> inheritance.

=item text_ia : array_ref []

Dereferenced and passed to C<$source-E<gt>get_widget_value>
to get string to use (see below).

=item text_ia : string []

How to render the label in inactive case.  There must be an
inactive icon for this case, i.e. I<alt_ia> must be defined.

Attributes for
L<Bivio::UI::HTML::Widget::String|Bivio::UI::HTML::Widget::String>
will be applied through C<parent> inheritance.  See also
I<font_ia>.

=back

=cut

#=IMPORTS
use Bivio::HTML;
use Bivio::UI::HTML::ViewShortcuts;

#=VARIABLES
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::Icon

Creates a new Icon widget.

=cut

sub new {
    my($self) = &Bivio::UI::Widget::Director::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Builds up the attributes for SUPER (Director).

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if $fields->{initialized};
    my($text, $alt_ia) = $self->unsafe_get(qw(text alt_ia));
    my($icon, $href) = $self->get(qw(name href));
    my($image) = Bivio::UI::HTML::Widget::Image->new({
	src => ['Bivio::UI::Icon', $icon],
	alt => $self->get('alt'),
    });
    my($font) = $self->ancestral_get('icon_font', undef);
    $self->put(
	control => $href,
	values => {},
	default_value => Bivio::UI::HTML::Widget::Link->new({
	    value => defined($text) ? Bivio::UI::Widget::Join->new({
		values => [
		    $image,
		    '<br>',
		    Bivio::UI::HTML::Widget::String->new({
			value => $text,
			$font ? (string_font => $font) : ()
		    }),
		],
	    })
	    : $image,
	    href => $href,
	}),
    );
    if (defined($alt_ia)) {
	my($image_ia) = Bivio::UI::HTML::Widget::Image->new({
	    src => ['Bivio::UI::Icon', $icon . '_ia'],
	    alt => $alt_ia,
	});
	my($text_ia) = $self->unsafe_get('text_ia');
	if (defined($text_ia)) {
	    my($font_ia) = $self->ancestral_get('icon_font_ia',
		    'icon_text_ia');
	    $self->put(
		undef_value => Bivio::UI::Widget::Join->new({
		    values => [
			$image_ia,
			'<br>',
			Bivio::UI::HTML::Widget::String->new({
			    value => $text_ia,
			    $font_ia ? (string_font => $font_ia) : ()
			}),
		    ],
		}),
	    );
	}
	else {
	    $self->put(undef_value => $image_ia);
	}
    }
    else {
    }
    $self->SUPER::initialize;
    $fields->{initialized} = 1;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
