# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::Font;
use strict;
$Bivio::UI::Font::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::Font::VERSION;

=head1 NAME

Bivio::UI::Font - named fonts

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::Font;

=cut

=head1 EXTENDS

L<Bivio::UI::FacadeComponent>

=cut

use Bivio::UI::FacadeComponent;
@Bivio::UI::Font::ISA = ('Bivio::UI::FacadeComponent');

=head1 DESCRIPTION

C<Bivio::UI::Font> is a map of font names to html values.

The configuration of a font is an array_ref.  The elements are
either C<key=value>, e.g. C<face=verdana,arial> and C<size=2>,
or simple tags, e.g. C<bold> or C<smaller>.

Here is a complete list of known tags.  All other tags will
be rejected.  The list is kept small to avoid specification
errors.  Feel free to add to the list in internal_initialize:

    family=list
    color=color-name
    size=string
    class=string
    id=string
    bold
    code
    italic
    larger
    smaller
    strike
    underline
    style=descriptor

Do not surround values to the right of the equals (=) with quotes.
The string following size can be a number as long as a style sheet
is not used.  For style sheets, should be "x-small", "large", etc.
These will be mapped into numeric sizes.

C<default> is a special font name which must exist.  It is used
to set the default font of the entire page.  B<Do not set the
color with this attribute.  Netscape doesn't handle color styles
correctly.>

The C<color> attribute is looked up implicitly if there is only one name in
a group and there is a color by that name.

Fonts behave differently depending on if the
L<Bivio::Type::UserAgent|Bivio::Type::UserAgent> is a
C<BROWSER> or C<BROWSER_HTML3>.

=head1 IMPLEMENTATION NOTES

The implementations of style sheets is pretty horrible for the most part.
Netscape is the worst.  The implementation is qualified by Netscape.
We "try" to do things as best we can.  If we fail, it will look ok.
This is the key.

The first problem is that Netscape reads the C<font-color> property
strangely, e.g.

    font-color: "#FF0000";

is green, not red as in IE.  This is why we don't allow the default
font to have a color.  It will be plain wrong in Netscape.  Instead
we assume C<page_text> will be set by
L<Bivio::UI::HTML::Widget::Page|Bivio::UI::HTML::Widget::Page>
correctly.

The next problem is that C<larger> and C<smaller> don't work in IE
for some reason.  Worse, of course, is Netscape which only allows
you to use C<larger> and C<smaller> and NOT C<small> and C<big>
tags if you have a style sheet in the header which sets C<font-size>--
got that?

The solution is tightly coupled with
L<Bivio::UI::HTML::Widget::Style|Bivio::UI::HTML::Widget::Style>.
We set the C<font-family> in the Style, if there is a style.

=cut

=head1 CONSTANTS

=cut

=for html <a name="UNDEF_CONFIG"></a>

=head2 UNDEF_CONFIG : array_ref

Returns config for no font.

=cut

sub UNDEF_CONFIG {
    return [];
}

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::Type::UserAgent;
use Bivio::UI::Color;
use Bivio::UI::Facade;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
# Map style names to numeric sizes
my(%_SIZE_MAP) = (
    'xx-small' => 1,
    'x-small' => 2,
    'small' => 3,
    'medium' => 4,
    'large' => 5,
    'x-large' => 6,
    'xx-large' => 7,
);
# Certain attributes map one to one to tags.  See refererences to
# _TAG_MAP below and _initialize_html
my(%_TAG_MAP) = (
    bold => 'b',
    italic => 'i',
    code => 'tt',
    # No one handles +1/-1 correctly with styles.  small
    # and big work everywhere, it seems.
    larger => 'big',
    smaller => 'small',
    strike => 'strike',
    underline => 'u',
);
# Attribute should only be used by this module
my($_CONFIG_ATTR) = '_config';

=head1 METHODS

=cut

=for html <a name="format_html"></a>

=head2 static format_html(string name, Bivio::Collection::Attributes req_or_facade) : array

=head2 format_html(string name) : array

Returns the font as prefix and suffix strings to surround the text with.

If I<thing> returns false (zero or C<undef>), returns two empty
strings.

See
L<Bivio::UI::FacadeComponent::internal_get_value|Bivio::UI::FacadeComponent/"internal_get_value">
for description of last argument.

=head2 REQUEST ATTRIBUTES

=over 4

=item font_with_style : boolean [0]

If set to true, the fonts will be rendered assuming the default font
was set in an inline style.

=back

=cut

sub format_html {
    my($proto, $name, $req) = @_;
    return ('', '') unless $name;

    # Lookup name
    my($v) = $proto->internal_get_value($name, $req);
    return ('', '') unless $v;

    # Figure out which form of html we have
    $req ||= Bivio::Agent::Request->get_current;
    return $req->unsafe_get('font_with_style') ? @{$v->{html_with_style}}
	    : @{$v->{html_no_style}};
}

=for html <a name="get_attrs"></a>

=head2 static get_attrs(string name, Bivio::Collection::Attributes req_or_facade) : hash_ref

=head2 get_attrs(string name) : hash_ref

Returns the font attributes.  B<Do not modify.>

May return C<undef> if no such font.

=cut

sub get_attrs {
    my($proto, $name, $req) = @_;
    return undef unless $name;
    my($v) = $proto->internal_get_value($name, $req);
    return $v ? $v->{attrs} : undef;
}

=for html <a name="handle_register"></a>

=head2 static handle_register()

Registers with Facade.

=cut

sub handle_register {
    my($proto) = @_;
    Bivio::UI::Facade->register($proto, ['Color']);
    return;
}

=for html <a name="initialization_complete"></a>

=head2 initialization_complete()

Verifies all standard fonts have been defined and converts
the values to html and such.

=cut

sub initialization_complete {
    my($self) = @_;

    # Initialize default first
    my($default) = $self->internal_get_value('default');
    $self->initialization_error(
	    {names => ['default']}, ': default font not defined')
	    unless $default;
    _initialize($self, $default, $default);
    $self->initialization_error(
	    $default, 'do not set color on default, use page_text')
	    if defined($default->{attrs}->{color});

    # Initialize the rest of the values
    foreach my $v (@{$self->internal_get_all}) {
	_initialize($self, $v, $default);
    }

    $self->SUPER::initialization_complete();
    return;
}

=for html <a name="internal_initialize_value"></a>

=head2 internal_initialize_value(hash_ref value)

Initializes the internal value from the configuration.

=cut

sub internal_initialize_value {
    my($self, $value) = @_;
    my($v) = $value->{config};
    unless (ref($v) eq 'ARRAY') {
	$self->initialization_error($value, 'not an array_ref');
	$value->{config} = [];
    }

    # Special case the UNDEF_CONFIG.  The names list is empty in this case.
    return if int(@{$value->{names}});

    $value->{attrs} = {};
    $value->{html_no_style} = ['', ''];
    $value->{html_with_style} = ['', ''];
    return;
}

#=PRIVATE METHODS

# _initialize(Bivio::UI::Font self, hash_ref value, hash_ref default)
#
# Intializes the value.
#
sub _initialize {
    my($self, $value, $default) = @_;
    # Already initialized?  (Happens for default)
    return if $value->{html};

    # Do we need to set the color implicitly?
    my(@c) = @{$value->{config}};
    if (int(@{$value->{names}}) == 1 && !grep(/^color=/, @c)) {
	my($name) = $value->{names}->[0];
	if ($self->get_facade->get('Color')->exists($name)) {
	    # Only set color if doesn't already exist.
	    push(@c, 'color='.$name);
	}
    }

    # Parse the config
    my(%attrs, @tags);
    $attrs{$_CONFIG_ATTR} = \@c;
    foreach my $a (@c) {
	if ($_TAG_MAP{$a}) {
	    $attrs{'tag_'.$_TAG_MAP{$a}} = 1;
	}
	elsif ($a =~ /^(family|size|class|id|style)=(.*)/) {
	    # May be blank
	    $attrs{$1} = $2;
	}
	elsif ($a =~ /^color=(.+)/) {
	    $attrs{color} = Bivio::UI::Color->format_html(
		    $1, '', $self->get_facade);
	}
	else {
	    $self->initialization_error($value, 'unknown attribute: ', $a);
	    %attrs = ();
	    last;
	}
    }
    $value->{attrs} = \%attrs;

    _initialize_html_no_style($value, $default);
    _initialize_html_with_style($value, $default);
    return;
}

# _initialize_html(hash attrs) : array_ref
#
# Returns the html (prefix, suffix) tuple for these attributes.
#
sub _initialize_html {
    my(%attrs) = @_;
    my($p, $s) = ('', '');

    # <FONT> attributes
    foreach my $k (qw(family size color class id style)) {
	# We don't allow "0" either.  This allows us to override
	# the default.
	next unless $attrs{$k};
	unless ($p) {
	    $p = '<font';
	    $s = '</font>';
	}
	my($n) = $k eq 'family' ? 'face' : $k;
	my($v) = $attrs{$k};
	# Map to numeric sizes, but only in <FONT> attributes
	$v = $_SIZE_MAP{$v} if $k eq 'size' && $_SIZE_MAP{$v};
	$p .= ' '.$n.'="'.$v.'"';
    }
    $p .= '>' if $p;

    # Copy the tag-based attributes
    foreach my $k (keys(%attrs)) {
	next unless $k =~ /^tag_(\w+)$/;
	$p .= "<$1>";
	$s = "</$1>".$s;
    }
    return [$p, $s];
}

# _initialize_html_no_style(hash_ref value, hash_ref default)
#
# Sets the html_no_style attributes based on attrs of value and default.
#
sub _initialize_html_no_style {
    my($value, $default) = @_;
    my(%attrs) = %{$value->{attrs}};

    while (my($k, $v) = each(%{$default->{attrs}})) {
	$attrs{$k} = $v unless defined($attrs{$k});
    }

    $value->{html_no_style} = _initialize_html(%attrs);
    return;
}

# _initialize_html_with_style(hash_ref value, hash_ref default)
#
# Sets the html_with_style attributes based on attrs of value and default.
#
sub _initialize_html_with_style {
    my($value, $default) = @_;
    # No defaulting needed.  This is handled by style sheet
    $value->{html_with_style} = _initialize_html(%{$value->{attrs}});
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
